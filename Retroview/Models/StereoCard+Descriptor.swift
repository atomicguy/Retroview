//
//  StereoCard+Indexes.swift
//  Retroview
//
//  Created by Adam Schuster on 1/26/25.
//

import SwiftData
import Foundation

extension CardSchemaV1.StereoCard {
    static var fetchDescriptor: FetchDescriptor<CardSchemaV1.StereoCard> {
        var descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
        descriptor.propertiesToFetch = [
            \.uuid,
            \.imageFrontId,
            \.titlePick
        ]
        return descriptor
    }
}
