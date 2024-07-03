//
//  StereoMetalShader.swift
//  Retroview
//
//  Created by Adam Schuster on 6/30/24.
//

import SwiftUI
import Metal
import MetalKit

struct StereoMetalView: UIViewRepresentable {
    var cgImage: CGImage
    var leftEyeRect: CGRect
    var rightEyeRect: CGRect

    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.framebufferOnly = false
        mtkView.delegate = context.coordinator
        
        context.coordinator.setupMetal(view: mtkView)
        context.coordinator.loadTexture(image: cgImage)
        context.coordinator.updateUniforms(leftEyeRect: leftEyeRect, rightEyeRect: rightEyeRect)
        
        return mtkView
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
        context.coordinator.updateUniforms(leftEyeRect: leftEyeRect, rightEyeRect: rightEyeRect)
        uiView.setNeedsDisplay()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MTKViewDelegate {
        var parent: StereoMetalView
        var device: MTLDevice!
        var commandQueue: MTLCommandQueue!
        var pipelineState: MTLRenderPipelineState!
        var texture: MTLTexture!
        var vertices: MTLBuffer!
        var uniforms: MTLBuffer!

        init(_ parent: StereoMetalView) {
            self.parent = parent
        }

        func setupMetal(view: MTKView) {
            device = view.device!
            commandQueue = device.makeCommandQueue()!

            let library = device.makeDefaultLibrary()!
            let vertexFunction = library.makeFunction(name: "vertexShader")
            let fragmentFunction = library.makeFunction(name: "fragmentShader")

            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat

            do {
                pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            } catch {
                fatalError("Failed to create pipeline state: \(error)")
            }

            let quadVertices: [Float] = [
                -1, -1, 0, 1,  0, 1,
                 1, -1, 0, 1,  1, 1,
                -1,  1, 0, 1,  0, 0,
                 1,  1, 0, 1,  1, 0,
            ]
            vertices = device.makeBuffer(bytes: quadVertices, length: quadVertices.count * MemoryLayout<Float>.stride, options: [])

            uniforms = device.makeBuffer(length: MemoryLayout<Uniforms>.stride, options: [])
        }

        func loadTexture(image: CGImage) {
            let textureLoader = MTKTextureLoader(device: device)
            do {
                texture = try textureLoader.newTexture(cgImage: image, options: nil)
            } catch {
                fatalError("Failed to load texture: \(error)")
            }
        }

        func updateUniforms(leftEyeRect: CGRect, rightEyeRect: CGRect) {
            let uniformsData = uniforms.contents().assumingMemoryBound(to: Uniforms.self)
            uniformsData.pointee.leftEyeRect = SIMD4<Float>(Float(leftEyeRect.origin.x), Float(leftEyeRect.origin.y), Float(leftEyeRect.width), Float(leftEyeRect.height))
            uniformsData.pointee.rightEyeRect = SIMD4<Float>(Float(rightEyeRect.origin.x), Float(rightEyeRect.origin.y), Float(rightEyeRect.width), Float(rightEyeRect.height))
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable,
                  let commandBuffer = commandQueue.makeCommandBuffer(),
                  let renderPassDescriptor = view.currentRenderPassDescriptor,
                  let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
                return
            }

            renderEncoder.setRenderPipelineState(pipelineState)
            renderEncoder.setVertexBuffer(vertices, offset: 0, index: 0)
            renderEncoder.setVertexBuffer(uniforms, offset: 0, index: 1)
            renderEncoder.setFragmentBuffer(uniforms, offset: 0, index: 0)
            renderEncoder.setFragmentTexture(texture, index: 0)
            renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            renderEncoder.endEncoding()

            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}

struct Uniforms {
    var leftEyeRect: SIMD4<Float>
    var rightEyeRect: SIMD4<Float>
}
