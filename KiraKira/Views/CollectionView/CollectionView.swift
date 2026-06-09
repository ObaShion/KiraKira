//
//  CollectionView.swift
//  KiraKira
//
//  Created by 大場史温 on 2026/06/09.
//

import SwiftUI
import SwiftData

struct CollectionView: View {
    @Query(sort: \StickerModel.timestamp, order: .reverse) private var stickers: [StickerModel]
    @Environment(\.modelContext) private var modelContext
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(stickers) { sticker in
                    NavigationLink(value: sticker) {
                        VStack(spacing: 8) {
                            if let image = sticker.image {
                                StickerView(imageData: image)
                                    .frame(maxWidth: .infinity)
                                    .aspectRatio(1, contentMode: .fit)
                            }
                            
                            Text(sticker.title)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            modelContext.delete(sticker)
                        } label: {
                            Label("削除", systemImage: "trash")
                        }
                    }
                }
            }
            .padding()
        }
    }
}
