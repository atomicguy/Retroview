//
//  ImageServiceFactory.swift
//  Retroview
//
//  Created by Assistant on 12/9/24.
//

import Foundation

final class ImageServiceFactory {
    static let shared = ImageServiceFactory()

    private init() {}

    func getService() async -> ImageService {
        return await ImageService(
            cache: ImageCache(sizeLimit: 500 * 1024 * 1024),
            loader: DefaultImageLoader()
        )
    }
}
