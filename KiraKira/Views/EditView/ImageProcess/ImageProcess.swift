//
//  ImageProcess.swift
//  KiraKira
//
//  Created by 大場史温 on 2026/06/09.
//

import Foundation
import VisionKit
import UIKit
import Vision
import AVFoundation

@MainActor
class ImageProcess: NSObject {
    private let analyzer = ImageAnalyzer()
    let interaction = ImageAnalysisInteraction()
    
    // 物体検出
    func analyzeImage(_ image: UIImage) async throws -> Set<ImageAnalysisInteraction.Subject> {
        let config = ImageAnalyzer.Configuration([.visualLookUp])
        let analysis = try await analyzer.analyze(image, configuration: config)
        interaction.analysis = analysis
        let detectedSubjects = await interaction.subjects
        return detectedSubjects
    }
    
    // 検出されたobj一個を画像として出力
    func getDetectedObject(objects: Set<ImageAnalysisInteraction.Subject>) async -> UIImage {
        var obj: UIImage = UIImage()
        for subject in objects {
            if let objectImage = try? await subject.image {
                obj = objectImage
                break
            }
        }
        return obj
    }
}
