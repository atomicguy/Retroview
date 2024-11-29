//
//  NavigationState.swift
//  Retroview
//
//  Created by Adam Schuster on 11/27/24.
//

import Foundation

enum NavigationDestination: Hashable {
    case library
    case collection(UUID, String) // Added name parameter

    var label: String {
        switch self {
        case .library:
            return "Library"
        case .collection(_, let name):
            return name
        }
    }

    var systemImage: String {
        switch self {
        case .library:
            return "photo.on.rectangle.angled"
        case .collection(_, let name):
            return name == CollectionDefaults.favoritesName
                ? "heart.fill" : "folder"
        }
    }
}
