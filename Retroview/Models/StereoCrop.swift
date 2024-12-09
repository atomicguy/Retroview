//
//  StereoCrop.swift
//  Retroview
//
//  Created by Adam Schuster on 12/8/24.
//

import SwiftData
import Foundation

@Model
final class StereoCrop {
    // MARK: - Types
    enum Side: String, Codable {
        case left, right
    }
    
    // MARK: - Properties
    var x0: Float
    var y0: Float
    var x1: Float
    var y1: Float
    var score: Float
    var side: Side
    
    @Relationship(deleteRule: .nullify, inverse: \StereoCard.crops) var card: StereoCard?
    
    // MARK: - Computed Properties
    var width: Float { x1 - x0 }
    var height: Float { y1 - y0 }
    var aspectRatio: Float { width / height }
    
    // MARK: - Initialization
    init(x0: Float,
         y0: Float,
         x1: Float,
         y1: Float,
         score: Float,
         side: Side) {
        self.x0 = x0
        self.y0 = y0
        self.x1 = x1
        self.y1 = y1
        self.score = score
        self.side = side
    }
}
