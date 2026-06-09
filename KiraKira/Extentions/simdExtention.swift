//
//  simdExtention.swift
//  KiraKira
//
//  Created by 大場史温 on 2026/06/09.
//

import Foundation

// https://youtu.be/60VoL-F-jIQ
func smoothstep(edge0: Float, edge1: Float, x: Float) -> Float {
    let t = max(0.0, min(1.0, (x - edge0) / (edge1 - edge0)))
    return t * t * (3.0 - 2.0 * t)
}
