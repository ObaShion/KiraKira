//
//  ContentView.swift
//  KiraKira
//
//  Created by 大場史温 on 2026/06/09.
//

import SwiftUI
import SwiftData
import CoreLocation

struct ContentView: View {
    @Query(sort: \StickerModel.timestamp, order: .reverse) private var stickers: [StickerModel]
    @Environment(\.modelContext) private var modelContext
    
    @State private var imageData: UIImage?
    @State private var location: CLLocation?
    @State private var isShowPhotoPicker: Bool = false
    @State private var isShowAddView: Bool = false
    
    @State private var selectedTab: Int = 0
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                Group {
                    if stickers.isEmpty {
                        ContentUnavailableView("ステッカーがありません", systemImage: "photo.on.rectangle.angled", description: Text("右上の＋ボタンから画像を追加してください"))
                    } else {
                        CollectionView()
                    }
                }
                .tabItem {
                    Label("コレクション", systemImage: "square.grid.2x2")
                }
                .tag(0)
                
                StickerMapView()
                    .tabItem {
                        Label("地図", systemImage: "map")
                    }
                    .tag(1)
            }
            .navigationTitle("KiraKira")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: StickerModel.self) { sticker in
                StickerDetailView(sticker: sticker)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowPhotoPicker = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowPhotoPicker) {
                PhotoPickView(imageData: $imageData, location: $location, onSelected: {
                    isShowAddView = true
                })
            }
            .fullScreenCover(isPresented: $isShowAddView, content: {
                EditView(imageData: $imageData, location: $location)
                    .background(.white)
            })
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: StickerModel.self, inMemory: true)
}
