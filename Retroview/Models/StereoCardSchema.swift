//
//  CardSchema.swift
//  Retroview
//
//  Created by Adam Schuster on 12/8/24.
//

// CardSchema.swift

import SwiftData
import Foundation

enum StereoCardSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [StereoCard.self, StereoCrop.self, Collection.self,
         Author.self, Subject.self, DateReference.self]
    }
}
