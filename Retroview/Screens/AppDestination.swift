//
//  NavigationDestination.swift
//  Retroview
//
//  Created by Adam Schuster on 12/7/24.
//

import SwiftUI

enum AppDestination: Hashable {
    case library
    case subjects
    case authors
    case dates
    case favorites
    case collections
    case collection(UUID, String)
    case dailyDiscovery

    var label: String {
        switch self {
        case .library: "Library"
        case .subjects: "Subjects"
        case .authors: "Authors"
        case .dates: "Dates"
        case .favorites: "Favorites"
        case .collections: "Collections"
        case let .collection(_, name): name
        case .dailyDiscovery: "Daily Discovery"
        }
    }

    var systemImage: String {
        switch self {
        case .library: "photo.on.rectangle.angled"
        case .subjects: "tag"
        case .authors: "person"
        case .dates: "calendar"
        case .favorites: "heart.fill"
        case .collections: "folder"
        case let .collection(_, name):
            name == CollectionDefaults.favoritesName ? "heart.fill" : "folder"
        case .dailyDiscovery: "star.circle"
        }
    }
}
