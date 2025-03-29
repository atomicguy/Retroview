//
//  ImportType.swift
//  Retroview
//
//  Created by Adam Schuster on 12/14/24.
//

enum ImportType: String, CaseIterable, Identifiable {
    case mods = "MODS Data"
    case crops = "Crop Updates"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .mods:
            "Import new cards from MODS library data"
        case .crops:
            "Update existing cards with new crop information"
        }
    }
    
    var icon: String {
        switch self {
        case .mods:
            "square.stack.3d.up.fill"
        case .crops:
            "crop"
        }
    }
}
