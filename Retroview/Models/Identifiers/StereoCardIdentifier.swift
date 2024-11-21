//
//  StereoCardIdentifier.swift
//  Retroview
//
//  Created by Adam Schuster on 11/10/24.
//

import Foundation

struct StereoCardIdentifier: Codable, Hashable {
    let uuid: UUID

    init(from card: CardSchemaV1.StereoCard) {
        uuid = card.uuid
    }

    // Required by Codable
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        uuid = try container.decode(UUID.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(uuid)
    }
}
