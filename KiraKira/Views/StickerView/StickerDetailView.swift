//
//  StickerDetailView.swift
//  KiraKira
//
//  Created by 大場史温 on 2026/06/09.
//

import SwiftUI
import SwiftData

struct StickerDetailView: View {
    let sticker: StickerModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            if let image = sticker.image {
                StickerView(imageData: image)
                    .frame(maxWidth: 350, maxHeight: 500)
                    .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .navigationTitle(sticker.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let image = sticker.image {
                    ShareLink(
                        item: renderSticker(image: image),
                        preview: SharePreview("Sticker", image: renderSticker(image: image))
                    ) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
    
    @MainActor
    private func renderSticker(image: UIImage) -> Image {
        // 効果を適用した状態でレンダリング
        let renderer = ImageRenderer(content: 
            StickerView(imageData: image)
                .frame(width: image.size.width, height: image.size.height)
        )
        
        // 背景を透明にする
        renderer.proposedSize = .init(width: image.size.width, height: image.size.height)
        
        if let uiImage = renderer.uiImage {
            return Image(uiImage: uiImage)
        }
        
        return Image(uiImage: image)
    }
}
