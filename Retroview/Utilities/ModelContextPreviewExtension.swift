//
//  ModelContextPreviewExtension.swift
//  Retroview
//
//  Created by Adam Schuster on 11/28/24.
//

import SwiftData
import Foundation

extension ModelContext {
    func previewCollection() -> CollectionSchemaV1.Collection? {
        let descriptor = FetchDescriptor<CollectionSchemaV1.Collection>()
        return try? fetch(descriptor).first
    }
}

extension CollectionSchemaV1.Collection {
    static var preview: CollectionSchemaV1.Collection {
        CollectionSchemaV1.Collection(name: "Preview Collection")
    }
}
