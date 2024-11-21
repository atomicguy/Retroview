//
//  GroupError.swift
//  Retroview
//
//  Created by Adam Schuster on 11/20/24.
//

import Foundation

enum GroupError: LocalizedError {
    case invalidName
    case emptySelection
    case importFailed(String)
    case exportFailed(String)
    case saveFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidName:
            return "Group name cannot be empty"
        case .emptySelection:
            return "No cards selected for group"
        case .importFailed(let reason):
            return "Failed to import group: \(reason)"
        case .exportFailed(let reason):
            return "Failed to export group: \(reason)"
        case .saveFailed(let reason):
            return "Failed to save group: \(reason)"
        }
    }
}
