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
            "MyStereoviews", schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(windowStateManager)
        }
        .modelContainer(sharedModelContainer)

        WindowGroup(id: "stereo-detail", for: StereoCardIdentifier.self) { $cardIdentifier in
            if let identifier = cardIdentifier,
               let card = try? sharedModelContainer.mainContext.fetch(FetchDescriptor<CardSchemaV1.StereoCard>(
                   predicate: #Predicate<CardSchemaV1.StereoCard> { card in
                       card.uuid == identifier.uuid
                   }
               )).first
            {
                NavigationStack {
                    StereoView(card: card)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button(action: {
                                    windowStateManager.clearSelection()
                                    $cardIdentifier.wrappedValue = nil
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            if let title = card.titlePick?.text {
                                ToolbarItem(placement: .principal) {
                                    Text(title)
                                        .font(.headline)
                                }
                            }
                        }
                        .environmentObject(windowStateManager)
                }
            }
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 1200, height: 800)
        .modelContainer(sharedModelContainer)
        .windowStyle(.plain)
    }
}
