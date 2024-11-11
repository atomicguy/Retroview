//
//  Crop.swift
//  Retroview
//
//  Created by Adam Schuster on 4/21/24.
//

import Foundation
import SwiftData

enum CropSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Crop.self]
    }

    enum Side: String {
        case left = "left"
        case right = "right"
    }

    @Model
    class Crop {
        var x0: Float
        var y0: Float
        var x1: Float
        var y1: Float
        var score: Float
        var side: String

        @Relationship(deleteRule: .cascade)
        var card: CardSchemaV1.StereoCard?

        init(
            x0: Float,
            y0: Float,
            x1: Float,
            y1: Float,
            score: Float,
            side: String
        ) {
            self.x0 = x0
            self.y0 = y0
            self.x1 = x1
            self.y1 = y1
            self.score = score
            self.side = side
        }

        static let sampleData = [
            Crop(
                x0: 0.05299678444862366,
                y0: 0.07310159504413605,
                x1: 0.8640091419219971,
                y1: 0.4875648021697998,
                score: 0.9998635053634644,
                side: Side.left.rawValue
            ),
            Crop(
                x0: 0.05890658497810364,
                y0: 0.489278107881546,
                x1: 0.861069917678833,
                y1: 0.9071069955825806,
                score: 0.9980714917182922,
                side: Side.right.rawValue
            ),
            Crop(
                x0: 0.04484763741493225,
                y0: 0.0854133665561676,
                x1: 0.8568880558013916,
                y1: 0.4988066256046295,
                score: 0.9999356269836426,
                side: Side.left.rawValue
            ),
            Crop(
                x0: 0.041730403900146484,
                y0: 0.4985104203224182,
                x1: 0.8540880084037781,
                y1: 0.9136133790016174,
                score: 0.9982233643531799,
                side: Side.right.rawValue
            ),
        ]
    }
}

extension CropSchemaV1.Crop {
    var description: String {
        "(\(x0),\(y0))->(\(x1),\(y1))"
    }
}
