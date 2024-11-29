//
//  NavigationState.swift
//  Retroview
//
//  Created by Adam Schuster on 11/27/24.
//

import Foundation

enum NavigationDestination: Hashable {
    case library
    case subjects
    case collection(UUID, String)

    var label: String {
        switch self {
        case .library:
            return "Library"
        case .subjects:
            return "Subjects"
        case let .collection(_, name):
            return name
        }
    }

    var systemImage: String {
        switch self {
        case .library:
            return "photo.on.rectangle.angled"
        case .subjects:
            return "tag"
        case let .collection(_, name):
            return name == CollectionDefaults.favoritesName
                ? "heart.fill" : "folder"
        }
    }
}
