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
    case collection(UUID, String)
    
    var label: String {
        switch self {
        case .library: "Library"
        case .subjects: "Subjects"
        case .authors: "Authors"
        case let .collection(_, name): name
        }
    }
    
    var systemImage: String {
        switch self {
        case .library: "photo.on.rectangle.angled"
        case .subjects: "tag"
        case .authors: "person"
        case let .collection(_, name):
            name == CollectionDefaults.favoritesName ? "heart.fill" : "folder"
        }
    }
    
    var id: String {
        switch self {
        case .library: "library"
        case .subjects: "subjects"
        case .authors: "authors"
        case let .collection(id, _): id.uuidString
        }
    }
}
