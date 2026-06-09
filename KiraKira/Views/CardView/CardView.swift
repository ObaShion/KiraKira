//
//  CardView.swift
//  KiraKira
//
//  Created by 大場史温 on 2026/06/09.
//

import SwiftUI
import Photos

struct CardView: View {
    @Binding var imageData: UIImage?
    @Binding var isShowToolbar: Bool
    @State private var time: Float = 0.0
    
    var body: some View {
        NavigationStack {
            let time = time
            if let imageData = imageData {
                Image(uiImage: imageData)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 500)
                    .clipped()
                    .allowedDynamicRange(.high)
                    .visualEffect({ content, proxy in
                        content
                            .layerEffect(ShaderLibrary.CardShader(
                                .float2(proxy.size), // viewSize
                                .float(time) // time
                            ),maxSampleOffset: CGSize(width: 20, height: 20))
                    })
                    .modifier(CardAnimationModifier(time: time))
                    .onAppear {
                        self.time = 0.0
                        self.isShowToolbar = false
                        withAnimation(.bouncy(duration: 2.0)) {
                            self.time = 1.0
                        } completion: {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                isShowToolbar = true
                            }
                        }

                    }
            }
        }
    }
}

#Preview {
    CardView(imageData: .constant(UIImage(named: "syon")!),
             isShowToolbar: .constant(false))
}
