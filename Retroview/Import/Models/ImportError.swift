//
//  ImportError.swift
//  Retroview
//
//  Created by Adam Schuster on 11/20/24.
//

import Foundation

enum ImportError: LocalizedError {
    case fileReadError(String)
    case invalidJSON(String)
    case modelCreationError(String)
    case saveError(String)
    
    var errorDescription: String? {
        switch self {
        case .fileReadError(let details): return "Failed to read file: \(details)"
        case .invalidJSON(let details): return "Invalid JSON format: \(details)"
        case .modelCreationError(let details): return "Failed to create model: \(details)"
        case .saveError(let details): return "Failed to save: \(details)"
        }
    }
}
