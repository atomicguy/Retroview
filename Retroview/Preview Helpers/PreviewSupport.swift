//
//  PreviewSupport.swift
//  Retroview
//
//  Created by Adam Schuster on 12/7/24.
//

import SwiftUI
import SwiftData

// MARK: - Preview Support
struct PreviewContainerModifier: ViewModifier {
    let populate: Bool
    
    init(populate: Bool = true) {
        self.populate = populate
    }
    
    func body(content: Content) -> some View {
        content
            .task {
                if populate {
                    do {
                        try await PreviewDataManager.shared.populatePreviewData()
                    } catch {
                        print("Failed to populate preview data: \(error)")
                    }
                }
            }
            .modelContainer(try! PreviewDataManager.shared.container())
    }
}

extension View {
    func withPreviewData(populate: Bool = true) -> some View {
        modifier(PreviewContainerModifier(populate: populate))
    }
}

@propertyWrapper
struct Previewable<T> {
    let wrappedValue: T
    
    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
}
