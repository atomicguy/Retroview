//
//  StackThumbnailManager.swift
//  Retroview
//
//  Created by Adam Schuster on 1/20/25.
//

import SwiftData
import SwiftUI

@Observable
final class StackThumbnailManager {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    @MainActor
    func updateThumbnail(for item: any (StackDisplayable & PersistentModel))
        async throws
    {
        // Generate new thumbnail
        let thumbnailData =
            try await StackThumbnailGenerator.generateThumbnailData(for: item)

        // Ensure we're on the main actor for SwiftData updates
        await MainActor.run {
            // Update the model with new thumbnail
            switch item {
            case let collection as CollectionSchemaV1.Collection:
                collection.collectionThumbnail = thumbnailData
            case let author as AuthorSchemaV1.Author:
                author.thumbnailData = thumbnailData
            case let subject as SubjectSchemaV1.Subject:
                subject.thumbnailData = thumbnailData
            case let date as DateSchemaV1.Date:
                date.thumbnailData = thumbnailData
            default:
                break
            }

            // Save context
            try? context.save()
        }
    }

    func needsThumbnailUpdate(_ item: any StackDisplayable) -> Bool {
        item.thumbnailData == nil
    }
}

// Environment key for the thumbnail manager
private struct StackThumbnailManagerKey: EnvironmentKey {
    static let defaultValue: StackThumbnailManager? = nil
}

extension EnvironmentValues {
    var stackThumbnailManager: StackThumbnailManager? {
        get { self[StackThumbnailManagerKey.self] }
        set { self[StackThumbnailManagerKey.self] = newValue }
    }
}

// View modifier for automatic thumbnail updates
struct AutoThumbnailUpdateModifier: ViewModifier {
    @Environment(\.stackThumbnailManager) private var thumbnailManager
    let item: any (StackDisplayable & PersistentModel)

    func body(content: Content) -> some View {
        content.task {
            guard let manager = thumbnailManager,
                manager.needsThumbnailUpdate(item)
            else {
                return
            }

            try? await manager.updateThumbnail(for: item)
        }
    }
}

// Convenience extension for views
extension View {
    func withAutoThumbnailUpdate(
        _ item: any (StackDisplayable & PersistentModel)
    ) -> some View {
        modifier(AutoThumbnailUpdateModifier(item: item))
    }
}
