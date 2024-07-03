//
//  StereoShader.metal
//  Retroview
//
//  Created by Adam Schuster on 6/29/24.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[attribute(0)]];
    float2 texCoords [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 texCoords;
};

struct Uniforms {
    float4 leftEyeRect;  // x, y, width, height
    float4 rightEyeRect; // x, y, width, height
};

[[vertex]]
VertexOut vertexShader(VertexIn in [[stage_in]],
                       constant Uniforms &uniforms [[buffer(0)]],
                       uint vid [[vertex_id]]) {
    VertexOut out;
    out.position = float4(in.position, 1.0);
    out.texCoords = in.texCoords;
    return out;
}

[[fragment]]
float4 fragmentShader(VertexOut in [[stage_in]],
                      constant Uniforms &uniforms [[buffer(0)]],
                      texture2d<float> spriteSheet [[texture(0)]],
                      uint eye_index [[render_target_array_index]]) {
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    
    float4 rect = (eye_index == 1) ? uniforms.rightEyeRect : uniforms.leftEyeRect;
    float2 adjustedTexCoords = rect.xy + in.texCoords * rect.zw;
    
    return spriteSheet.sample(textureSampler, adjustedTexCoords);
}
