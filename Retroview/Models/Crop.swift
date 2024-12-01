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
        case left
        case right
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
            // First card's crops (left and right)
            Crop(
                x0: 0.03353559970855713,
                y0: 0.08207376301288605,
                x1: 0.8589106798171997,
                y1: 0.4951629042625427,
                score: 0.999935507774353,
                side: Side.left.rawValue
            ),
            Crop(
                x0: 0.03493055701255798,
                y0: 0.49972599744796753,
                x1: 0.8583910465240479,
                y1: 0.9113591313362122,
                score: 0.999541163444519,
                side: Side.right.rawValue
            ),
            // Second card's crops
            Crop(
                x0: 0.05269774794578552,
                y0: 0.08212341368198395,
                x1: 0.846436619758606,
                y1: 0.4963873028755188,
                score: 0.9999606609344482,
                side: Side.left.rawValue
            ),
            Crop(
                x0: 0.058870553970336914,
                y0: 0.49953702092170715,
                x1: 0.8493868708610535,
                y1: 0.9116054773330688,
                score: 0.9997797608375549,
                side: Side.right.rawValue
            ),
            // Third card's crops
            Crop(
                x0: 0.046574532985687256,
                y0: 0.09084399044513702,
                x1: 0.8685169816017151,
                y1: 0.495430052280426,
                score: 0.9999599456787109,
                side: Side.left.rawValue
            ),
            Crop(
                x0: 0.04931667447090149,
                y0: 0.4972994327545166,
                x1: 0.8737567663192749,
                y1: 0.9005938768386841,
                score: 0.9993842840194702,
                side: Side.right.rawValue
            ),
            // Fourth card's crops
            Crop(
                x0: 0.08226048946380615,
                y0: 0.11780217289924622,
                x1: 0.875549852848053,
                y1: 0.4918394386768341,
                score: 0.9998470544815063,
                side: Side.left.rawValue
            ),
            Crop(
                x0: 0.07813882827758789,
                y0: 0.49538975954055786,
                x1: 0.8701637983322144,
                y1: 0.8689450621604919,
                score: 0.999481737613678,
                side: Side.right.rawValue
            ),
            Crop(
                x0: 0.033246755599975586,
                y0: 0.08684591948986053,
                x1: 0.9074361324310303,
                y1: 0.5030806064605713,
                score: 0.9992239475250244,
                side: Side.left.rawValue
            ),
            Crop(
                x0: 0.03239387273788452,
                y0: 0.5045199990272522,
                x1: 0.9126836657524109,
                y1: 0.9137648940086365,
                score: 0.9971144199371338,
                side: Side.right.rawValue
            ),
            Crop(
                x0: 0.05379113554954529,
                y0: 0.06941801309585571,
                x1: 0.8979833126068115,
                y1: 0.48938190937042236,
                score: 0.9999513626098633,
                side: Side.left.rawValue
            ),
            Crop(
                x0: 0.05642902851104736,
                y0: 0.49445831775665283,
                x1: 0.9010132551193237,
                y1: 0.9146627187728882,
                score: 0.9984322190284729,
                side: Side.right.rawValue
            ),
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
