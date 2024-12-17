//
//  ImageServiceFactory.swift
//  Retroview
//
//  Created by Adam Schuster on 12/7/24.
//

import Foundation

// Singleton factory to manage the image service instance
// ImageServiceFactory.swift

import Foundation

// Singleton factory to manage the image service instance
final class ImageServiceFactory {
    static let shared = ImageServiceFactory()
    
    private var service: ImageServiceProtocol?
    
    private init() {}
    
    func getService(
        configuration: ImageServiceConfiguration = .default
    ) -> ImageServiceProtocol {
        if let existingService = service {
            return existingService
        }
        
        let newService = ImageService(configuration: configuration)
        service = newService
        return newService
    }
    
    func reset() {
        service?.clearCache()
        service = nil
    }
}
