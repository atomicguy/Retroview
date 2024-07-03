//
//  VisionOSStereoView.swift
//  Retroview
//
//  Created by Adam Schuster on 7/1/24.
//

import SwiftUI
import RealityKit

@available(visionOS 2.0, *)
struct VisionOSStereoView: View {
    @ObservedObject var viewModel: StereoCardViewModel
    
    var body: some View {
        if let cgImage = viewModel.frontCGImage {
            RealityView { content in
                let leftEyeTexture = try! TextureResource(image: createTextureFromCGImage(cgImage, crop: viewModel.leftEyeRect), options: .init(semantic: .color))
                let rightEyeTexture = try! TextureResource(image: createTextureFromCGImage(cgImage, crop: viewModel.rightEyeRect), options: .init(semantic: .color))
                print("made lefteyetexture and righteyetexture", leftEyeTexture)
                
                var leftMaterial = UnlitMaterial()
                leftMaterial.color = .init(tint: .white, texture: MaterialParameters.Texture(leftEyeTexture))
                var rightMaterial = UnlitMaterial()
                rightMaterial.color = .init(tint: .white, texture: MaterialParameters.Texture(rightEyeTexture))
                
                let leftPlane = ModelEntity(mesh: .generatePlane(width: 0.5, height: 0.5), materials: [leftMaterial])
                let rightPlane = ModelEntity(mesh: .generatePlane(width: 0.5, height: 0.5), materials: [rightMaterial])
                
                leftPlane.components[ImageComponentController.self] = .init(eyeToShow: .left)
                rightPlane.components[ImageComponentController.self] = .init(eyeToShow: .right)
                
                content.add(leftPlane)
                content.add(rightPlane)
                
                leftPlane.position = SIMD3(-0.25, 0, 0)
                rightPlane.position = SIMD3(0.25, 0, 0)
            }
            .frame(width: 500, height: 500)
        } else {
            Text("Loading...")
        }
    }
    
    private func createTextureFromCGImage(_ image: CGImage, crop: CGRect) -> CGImage {
        let width = Int(CGFloat(image.width) * crop.width)
        let height = Int(CGFloat(image.height) * crop.height)
        let bitsPerComponent = 8
        let bytesPerRow = width * 4
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        
        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo) else {
            fatalError("Unable to create CGContext")
        }
        
        context.draw(image, in: CGRect(x: -crop.origin.x * CGFloat(image.width),
                                       y: -crop.origin.y * CGFloat(image.height),
                                       width: CGFloat(image.width),
                                       height: CGFloat(image.height)))
        
        guard let croppedImage = context.makeImage() else {
            fatalError("Unable to create cropped image")
        }
        
        return croppedImage
    }
}

struct ImageComponentController: Component {
    var eyeToShow: Eye
    
    enum Eye {
        case left
        case right
    }
}
