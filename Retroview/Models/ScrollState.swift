//
//  ScrollState.swift
//  Retroview
//
//  Created by Adam Schuster on 1/29/25.
//

import SwiftData
import Foundation

@Model
class ScrollState {
    var viewIdentifier: String
    var position: Double
    var timestamp: Date
    
    init(viewIdentifier: String, position: Double) {
        self.viewIdentifier = viewIdentifier
        self.position = position
        self.timestamp = Date()
    }
}
