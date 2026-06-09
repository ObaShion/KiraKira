//
//  EditView.swift
//  KiraKira
//
//  Created by 大場史温 on 2026/06/09.
//

import SwiftUI
import VisionKit
import MapKit
import SwiftData

struct EditView: View {
    @Binding var imageData: UIImage?
    @Binding var location: CLLocation?
    
    // state
    @State private var isShowToolbar: Bool = false
    @State private var isObjectDetected: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    // 画像処理
    let imageProcess = ImageProcess()
    @State private var detectedObjects: Set<ImageAnalysisInteraction.Subject> = []
    @State private var extractedObjectImage: UIImage?
    
    // sticker
    @State private var stickerData: StickerModel = StickerModel(title: "", image: UIImage(), location: CLLocation())
    
    // swiftData
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            ZStack {
                CardView(
                    imageData: $imageData,
                    isShowToolbar: $isShowToolbar
                )
                .opacity(
                    (isObjectDetected && isShowToolbar) ? 0.0 : 1.0
                )
                .transition(.scale.combined(with: .blurReplace))
                
                if isObjectDetected && isShowToolbar {
                    if let objectImage = extractedObjectImage {
                        VStack {
                            Spacer()
                            StickerView(imageData: objectImage)
                                .transition(
                                    .scale.combined(with: .blurReplace)
                                )
                            Spacer()
                        }
                    } else {
                        Text("Nothing><")
                            .monospaced()
                    }
                }
            }
            .animation(
                .easeInOut(duration: 0.5),
                value: (isObjectDetected&&isShowToolbar)
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .opacity(isShowToolbar ? 1.0 : 0.0)
                    .disabled(!isShowToolbar)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if extractedObjectImage != nil {
                            stickerAdd()
                        }
                        dismiss()
                    } label: {
                        HStack {
                            Text("collection")
                        }
                    }
                    .buttonStyle(.glassProminent)
                    .opacity(
                        (isShowToolbar&&isObjectDetected) ? 1.0 : 0.0
                    )
                    .disabled(!isShowToolbar && !isObjectDetected)
                }
            }
            .task(id: imageData) {
                await detection()
            }
        }
    }
    
    // obj検出
    func detection() async {
        guard let imageData = imageData else { return }
        do {
            detectedObjects = try await imageProcess.analyzeImage(imageData)
            extractedObjectImage = await imageProcess.getDetectedObject(objects: detectedObjects)
            isObjectDetected = true
        } catch {
            print("visionError: \(error)")
        }
    }
    
    // sticker追加
    func stickerAdd() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        guard let imageToSave = extractedObjectImage else { return }
        
        let finalLocation = location ?? CLLocation(latitude: 35.6812, longitude: 139.7671)
        let newSticker = StickerModel(
            title: dateFormatter.string(from: Date()),
            image: imageToSave,
            location: finalLocation)
        
        context.insert(newSticker)
        
        do {
            try context.save()
            print("Successfully saved sticker")
        } catch {
            print("Failed to save sticker: \(error)")
        }
    }
}

#Preview {
    EditView(imageData: .constant(UIImage(named: "syon")!), location: .constant(nil))
}
