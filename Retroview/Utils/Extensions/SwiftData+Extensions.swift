//
//  SwiftData+Extensions.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftUI
import SwiftData

extension ModelContext {
    @MainActor
    static var shared: ModelContext = {
        do {
            let container = try StoreManager.shared.createContainer()
            return container.mainContext
        } catch {
            fatalError("Failed to create ModelContext: \(error)")
        }
    }()
    
    static func getShared() async -> ModelContext {
        await MainActor.run {
            shared
        }
    }
}
