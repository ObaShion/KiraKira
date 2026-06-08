//
//  ContentView.swift
//  KiraKira
//
//  Created by 大場史温 on 2026/06/09.
//

import SwiftUI

struct ContentView: View {
    @State private var imageData: UIImage?
    @State private var isShowPhotoPicker: Bool = false
    @State private var isShowAddView: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Button("画像を選ぶ") {
                    isShowPhotoPicker = true
                }
            }
            .sheet(isPresented: $isShowPhotoPicker) {
                PhotoPickView(imageData: $imageData, onSelected: {
                    isShowAddView = true
                })
            }
            .fullScreenCover(isPresented: $isShowAddView, content: {
                CardView(imageData: $imageData)
            })
            .navigationTitle("KiraKira")
        }
    }
}

#Preview {
    ContentView()
}
