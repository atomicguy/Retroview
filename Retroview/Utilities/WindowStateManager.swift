//
//  WindowManager.swift
//  Retroview
//
//  Created by Adam Schuster on 11/11/24.
//

import SwiftUI
import Combine

final class WindowStateManager: ObservableObject {
    static let shared = WindowStateManager()
    
    @Published var selectedCardId: UUID?
    @Published var isDetailWindowOpen = false
    
    private init() {}
    
    func selectCard(_ card: CardSchemaV1.StereoCard) {
        selectedCardId = card.uuid
    }
    
    func clearSelection() {
        selectedCardId = nil
        isDetailWindowOpen = false
    }
}
