//
//  CardSide.swift
//  Retroview
//
//  Created by Adam Schuster on 12/15/24.
//

import Foundation

enum CardSide: String, CaseIterable {
    case front
    case back
    
    var suffix: String {
        switch self {
        case .front: return "F"
        case .back: return "B"
        }
    }
}
