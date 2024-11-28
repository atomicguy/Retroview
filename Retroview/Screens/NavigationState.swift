//
//  NavigationState.swift
//  Retroview
//
//  Created by Adam Schuster on 11/27/24.
//

import Foundation

enum NavigationDestination: String, Identifiable {
    case library
    // Future destinations can be added here

    var id: String { rawValue }

    var label: String {
        switch self {
        case .library:
            return "Library"
        }
    }

    var systemImage: String {
        switch self {
        case .library:
            return "photo.on.rectangle.angled"
        }
    }
}
