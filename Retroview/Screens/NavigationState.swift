//
//  NavigationState.swift
//  Retroview
//
//  Created by Adam Schuster on 11/27/24.
//

import Foundation

enum NavigationDestination: Hashable {
    case library
    case collection(UUID)
    
    var label: String {
        switch self {
        case .library:
            return "Library"
        case .collection:
            return "Collection"
        }
    }
    
    var systemImage: String {
        switch self {
        case .library:
            return "photo.on.rectangle.angled"
        case .collection:
            return "folder"
        }
    }
}
