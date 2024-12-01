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
    case authors
    case collection(UUID, String)

    var label: String {
        switch self {
        case .library:
            "Library"
        case .subjects:
            "Subjects"
        case .authors:
            "Authors"
        case let .collection(_, name):
            name
        }
    }

    var systemImage: String {
        switch self {
        case .library:
            "photo.on.rectangle.angled"
        case .subjects:
            "tag"
        case .authors:
            "person"
        case let .collection(_, name):
            name == CollectionDefaults.favoritesName
                ? "heart.fill" : "folder"
        }
    }
}
