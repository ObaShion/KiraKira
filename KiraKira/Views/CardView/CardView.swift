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
    @State private var time: Float = 0.0
    @State private var isShowToolbar: Bool = false
    @Environment(\.dismiss) private var dismiss
    
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
                        withAnimation(.bouncy(duration: 5.0)) {
                            self.time = 1.0
                        } completion: {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                isShowToolbar = true
                            }
                        }

                    }
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
                                dismiss()
                            } label: {
                                HStack {
                                    Text("collection")
                                }
                            }
                            .buttonStyle(.glassProminent)
                            .opacity(isShowToolbar ? 1.0 : 0.0)
                            .disabled(!isShowToolbar)
                        }
                    }
            }
        }
    }
}

#Preview {
    CardView(imageData: .constant(UIImage()))
}
