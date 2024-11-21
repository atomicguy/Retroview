//
//  GroupDocument.swift
//  Retroview
//
//  Created by Adam Schuster on 11/20/24.
//

import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct GroupDocument: FileDocument {
    let group: CardGroupSchemaV1.Group

    static var readableContentTypes: [UTType] { [.json] }

    init(group: CardGroupSchemaV1.Group) {
        self.group = group
    }

    init(configuration: ReadConfiguration) throws {
        // We don't need to implement this as we're only using this for export
        fatalError("Import not supported")
    }

    nonisolated func fileWrapper(configuration: WriteConfiguration) throws
        -> FileWrapper
    {
        // Create serializable version and encode on a new actor
        return try Task.sync {
            let serializableGroup = await SerializableGroup(from: group)
            let data = try JSONEncoder().encode(serializableGroup)
            return .init(regularFileWithContents: data)
        }
    }
}

// Helper extension for synchronous actor-isolated work
extension Task where Success == Void, Failure == Never {
    static func sync<T>(
        priority: TaskPriority? = nil, operation: @escaping () async throws -> T
    ) throws -> T {
        let group = DispatchGroup()
        var result: Result<T, Error>?

        group.enter()
        Task(priority: priority) {
            do {
                result = try .success(await operation())
            } catch {
                result = .failure(error)
            }
            group.leave()
        }

        group.wait()

        return try result!.get()
    }
}
