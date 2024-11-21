//
//  RetroviewApp.swift
//  Retroview
//
//  Created by Adam Schuster on 4/6/24.
//

import SwiftData
import SwiftUI

@main
struct RetroviewApp: App {
    @StateObject private var windowStateManager = WindowStateManager.shared

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CardSchemaV1.StereoCard.self,
            TitleSchemaV1.Title.self,
            AuthorSchemaV1.Author.self,
            SubjectSchemaV1.Subject.self,
            DateSchemaV1.Date.self,
        ])
        let config = ModelConfiguration(
            "MyStereoviews", schema: schema, isStoredInMemoryOnly: false
        )
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(windowStateManager)
        }
        #if os(macOS)
        .defaultSize(width: 1200, height: 800)
        .commands {
            CommandGroup(after: .newItem) {
                Button("Import Cards...") {
                    NotificationCenter.default.post(
                        name: .importRequested,
                        object: nil
                    )
                }
                .keyboardShortcut("i", modifiers: .command)

                Button("Import Group...") {
                    NotificationCenter.default.post(
                        name: .importGroupRequested,
                        object: nil
                    )
                }
                .keyboardShortcut("i", modifiers: [.command, .option])

                Button("Export Selected Group...") {
                    NotificationCenter.default.post(
                        name: .exportGroupRequested,
                        object: nil
                    )
                }
                .keyboardShortcut("e", modifiers: [.command, .option])
            }
        }
        #endif
        .modelContainer(sharedModelContainer)
    }
}

extension Notification.Name {
    static let importRequested = Notification.Name("importRequested")
    static let importGroupRequested = Notification.Name("importGroupRequested")
    static let exportGroupRequested = Notification.Name("exportGroupRequested")
}
