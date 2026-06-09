//
//  ObjectPickableImageView.swift
//  KiraKira
//
//  Created by 大場史温 on 2026/06/09.
//

import Foundation
import SwiftUI
import VisionKit

struct ObjectPickableImageView: UIViewRepresentable {
    typealias UIViewType = UIImageView
    
    @Binding var imageObject: UIImage
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.image = imageObject
        imageView.contentMode = .scaleAspectFit
        let imageProcess = ImageProcess()
        imageProcess.interaction.preferredInteractionTypes = [.imageSubject]
        imageView.addInteraction(imageProcess.interaction)
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {}
}
