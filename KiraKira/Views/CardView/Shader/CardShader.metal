//
//  CardShader.metal
//  KiraKira
//
//  Created by 大場史温 on 2026/06/09.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;


[[ stitchable ]] half4 CardShader(
                                  float2 position,
                                  SwiftUI::Layer layer,
                                  float2 viewSize,
                                  float time
                                  ){
    float2 uv = position / viewSize;
    float lineDirection = uv.x + uv.y;
    float targetPos = time * 3.0 - 0.25;
    
    float2 offset = float2(0.0);
    float highlightDecay = 0.0;
    
    if (lineDirection < targetPos) {
        float distFromLine = abs(targetPos - lineDirection);
        float fadeIn = metal::smoothstep(0.0, 0.08, distFromLine);
        float fadeOut = metal::smoothstep(1.0, 0.08, distFromLine);
        
        float highlightFadeOut = smoothstep(0.7, 0.01, distFromLine);
        highlightDecay = fadeIn * highlightFadeOut;

        float waveValue = sin(lineDirection * 5.0 - time * 2.0) * 0.015 * (fadeIn * fadeOut);
        offset = float2(waveValue, waveValue);
    }
    
    float2 distortedUV = uv + offset;
    float2 distortedPosition = distortedUV * viewSize;
    
    half4 color = layer.sample(distortedPosition);
    
    half3 rainbow = half3(sin(distortedUV.x), cos(distortedUV.y), 0.5);
    half3 lineColor = color.rgb + (rainbow * half(highlightDecay * 1.5)) * color.a;

    return half4(lineColor, color.a);
}
