//
//  StickerView.swift
//  KiraKira
//
//  Created by 大場史温 on 2026/06/09.
//

import SwiftUI
import Sticker

struct StickerView: View {
    var imageData: UIImage
    
    var body: some View {
        Image(uiImage: imageData)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .stickered()
            .stickerEffect()
            .stickerScale(4)
            .stickerColorIntensity(0.03)
            .stickerCheckerScale(100)
            .stickerMotionEffect(.accelerometer(intensity: 1.0, maxRotation: .radians(0.5), updateInterval: 0.02))
            .animation(.easeOut(duration: 0.2), value: true)
            .shadow(radius: 1)
            .background(Color.clear)
            .drawingGroup()
    }
}

#Preview {
    StickerView(imageData: UIImage(named: "syon")!)
}
