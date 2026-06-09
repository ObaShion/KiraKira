//
//  CardAnimationModifier.swift
//  KiraKira
//
//  Created by 大場史温 on 2026/06/09.
//

import Foundation
import SwiftUI
import simd

struct CardAnimationModifier: ViewModifier, Animatable {
    var time: Float
    
    var animatableData: Float {
        get { time }
        set { time = newValue }
    }
    
    func body(content: Content) -> some View {
        let normalizedTime = min(time / 0.8, 1.0)
        let factor = CGFloat(sin(smoothstep(edge0: 0.0, edge1: 1.0, x: normalizedTime) * .pi))
        content
            .scaleEffect(1.0 + factor * 0.1)
            .shadow(
                color: Color.black.opacity(Double(sin(time * .pi) * 0.3)),
                radius: CGFloat(factor * 15),
                x: CGFloat(factor * 10),
                y: CGFloat(factor * 10)
            )
    }
}
