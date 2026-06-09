//
//  StickerMapView.swift
//  KiraKira
//
//  Created by 大場史温 on 2026/06/09.
//

import SwiftUI
import MapKit
import SwiftData

struct DragState {
    var position: CGPoint?
    var previousPosition: CGPoint?
    var edge: Edge?
    var isDragging: Bool = false
    
    enum Edge { case left, right }
}

struct AnimatedGlassModifier: AnimatableModifier {
    var isDragging: Bool
    var progress: CGFloat
    var midPointX: CGFloat
    var midPointY: CGFloat
    let edgeX: CGFloat
    let height: CGFloat
    let screenCornerRadius: CGFloat
    let midOffset: CGSize
    
    var animatableData: AnimatablePair<CGFloat, AnimatablePair<CGFloat, CGFloat>> {
        get {
            AnimatablePair(progress, AnimatablePair(midPointX, midPointY))
        }
        set {
            progress = newValue.first
            midPointX = newValue.second.first
            midPointY = newValue.second.second
        }
    }
    
    var path: Path {
        Path { path in
            let mountainHeight: CGFloat = 300
            let startY = midPointY - (mountainHeight / 2) * progress
            let endY = midPointY + (mountainHeight / 2) * progress
            
            // Fix x-axis stretch by using a constant offset instead of midPointX
            let direction: CGFloat = (edgeX == 0) ? 1 : -1
            let peakX = edgeX + (40 * progress) * direction
            let midPoint = CGPoint(x: peakX, y: midPointY)
            
            let cp1 = CGPoint(x: edgeX, y: startY + (midPointY - startY) / 2)
            let cp2 = CGPoint(x: midPoint.x, y: midPointY - 70 * progress)
            let cp3 = CGPoint(x: midPoint.x, y: midPointY + 70 * progress)
            let cp4 = CGPoint(x: edgeX, y: midPointY + (endY - midPointY) / 2)
            
            path.move(to: CGPoint(x: edgeX, y: startY))
            path.addCurve(to: midPoint, control1: cp1, control2: cp2)
            path.addCurve(to: CGPoint(x: edgeX, y: endY), control1: cp3, control2: cp4)
        }
    }
    
    func body(content: Content) -> some View {
        content.mask(path)
            .background {
                path
                    .fill(.black)
                    .shadow(color: .black.opacity(0.125), radius: 4)
            }
    }
}

struct StickerMapView: View {
    @Query private var stickers: [StickerModel]
    @State private var position: MapCameraPosition = .automatic
    @State private var mapZoomLevel: CGFloat = 0.01
    @State private var mapCenter: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671)
    @State private var isInitialCenterSet = false
    @State private var dragState = DragState()
    @State private var pathProgress: CGFloat = 0
    
    private let edgeThreshold: CGFloat = 44
    private let screenCornerRadius: CGFloat = 63
    
    private var cameraPositionBinding: Binding<MapCameraPosition> {
        Binding<MapCameraPosition>(
            get: {
                .region(
                    .init(
                        center: mapCenter,
                        span: .init(latitudeDelta: mapZoomLevel, longitudeDelta: mapZoomLevel)
                    )
                )
            },
            set: { newValue in
                if let region = newValue.region {
                    let latDiff = abs(region.center.latitude - mapCenter.latitude)
                    let lonDiff = abs(region.center.longitude - mapCenter.longitude)
                    let spanDiff = abs(region.span.latitudeDelta - mapZoomLevel)
                    
                    if latDiff > 0.000001 || lonDiff > 0.000001 || (spanDiff > 0.000001 && !dragState.isDragging) {
                        DispatchQueue.main.async {
                            self.mapCenter = region.center
                            if !dragState.isDragging {
                                self.mapZoomLevel = max(region.span.latitudeDelta, region.span.longitudeDelta)
                            }
                        }
                    }
                }
            }
        )
    }
    
    var body: some View {
        ZStack {
            Map(position: cameraPositionBinding) {
                ForEach(stickers) { sticker in
                    Annotation("", coordinate: sticker.location.coordinate) {
                        NavigationLink(value: sticker) {
                            if let image = sticker.image {
                                StickerView(imageData: image)
                                    .frame(width: 80, height: 80)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .mapStyle(.imagery)
            .onAppear {
                if !isInitialCenterSet, let firstSticker = stickers.first {
                    mapCenter = firstSticker.location.coordinate
                    isInitialCenterSet = true
                }
            }
            .onMapCameraChange(frequency: .continuous) { context in
                mapCenter = context.region.center
            }
            
            GeometryReader { geometry in
                let w = geometry.size.width
                let h = geometry.size.height
                let edgeX: CGFloat = (dragState.edge == .left) ? 0 : w
                let mid = dragState.position ?? CGPoint(x: edgeX, y: h / 2)
                
                ZStack {
                    Rectangle()
                        .fill(.clear)
                        .modifier(
                            AnimatedGlassModifier(
                                isDragging: dragState.isDragging,
                                progress: pathProgress,
                                midPointX: mid.x - 24,
                                midPointY: mid.y,
                                edgeX: edgeX,
                                height: h,
                                screenCornerRadius: screenCornerRadius,
                                midOffset: CGSize(width: 0, height: -70)
                            )
                        )
                        .animation(.bouncy(duration: 0.3), value: pathProgress)
                        .animation(.snappy(duration: 0.1), value: mid)
                        .contentShape(Rectangle())
                }
                .allowsHitTesting(false)
                
                HStack {
                    Spacer()
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: edgeThreshold)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if !dragState.isDragging {
                                        dragState.edge = .right
                                        // Set position immediately without animation to avoid starting from center
                                        var transaction = Transaction()
                                        transaction.disablesAnimations = true
                                        withTransaction(transaction) {
                                            dragState.position = CGPoint(x: geometry.size.width - edgeThreshold + value.location.x, y: value.location.y)
                                            dragState.isDragging = true
                                        }
                                        withAnimation(.snappy(duration: 0.5)) {
                                            pathProgress = 1
                                        }
                                    }
                                    dragState.position = CGPoint(x: geometry.size.width - edgeThreshold + value.location.x, y: value.location.y)
                                    let deltaY = (dragState.previousPosition?.y ?? value.location.y) - value.location.y
                                    let xDistance: CGFloat = geometry.size.width - (geometry.size.width - edgeThreshold + value.location.x)
                                    let span = mapZoomLevel
                                    let newSpan = span - (deltaY / 20000 * span * (geometry.size.width - xDistance))
                                    mapZoomLevel = min(max(newSpan, 0.002), 100)
                                    dragState.previousPosition = value.location
                                }
                                .onEnded { _ in
                                    let lastY = dragState.position?.y ?? (geometry.size.height / 2)
                                    let resetX = geometry.size.width
                                    dragState.previousPosition = nil
                                    dragState.isDragging = false
                                    withAnimation(.spring(duration: 1.0)) {
                                        pathProgress = 0
                                        dragState.position = CGPoint(x: resetX, y: lastY)
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        if !dragState.isDragging {
                                            dragState.edge = nil
                                            // Keep the last position so it doesn't reset to center
                                        }
                                    }
                                }
                        )
                }
            }
            .ignoresSafeArea()
        }
    }
}
