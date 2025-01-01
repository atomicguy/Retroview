//
//  DiagnosticCollectionButton.swift
//  Retroview
//
//  Created by Adam Schuster on 12/21/24.
//

import OSLog
import SwiftData
import SwiftUI

private let logger = Logger(
    subsystem: "com.example.retroview", category: "CollectionPerformance")

struct DiagnosticCollectionButton: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<CollectionSchemaV1.Collection> { collection in
            collection.name != "Favorites"
        },
        sort: \.name
    ) private var collections: [CollectionSchemaV1.Collection]

    let card: CardSchemaV1.StereoCard

    var body: some View {
        Button {
            Task {
                await toggleFirstCollection()
            }
        } label: {
            Text("Test Collection Add")
        }
        .task {
            logger.debug("Initial collections count: \(collections.count)")
        }
    }

    private func toggleFirstCollection() async {
        await MainActor.run {
            guard let collection = collections.first else { return }

            let startTime = CACurrentMediaTime()
            logger.debug("Starting collection toggle operation")

            // Time the contains check
            let containsStartTime = CACurrentMediaTime()
            let contains = collection.hasCard(card)
            let containsDuration = CACurrentMediaTime() - containsStartTime
            logger.debug("hasCard check took \(containsDuration) seconds")

            // Time the actual operation
            let operationStartTime = CACurrentMediaTime()
            if contains {
                collection.removeCard(card, context: modelContext)
            } else {
                collection.addCard(card, context: modelContext)
            }
            let operationDuration = CACurrentMediaTime() - operationStartTime
            logger.debug(
                "Collection operation took \(operationDuration) seconds")

            // Time the save
            let saveStartTime = CACurrentMediaTime()
            do {
                try modelContext.save()
                let saveDuration = CACurrentMediaTime() - saveStartTime
                logger.debug("Save operation took \(saveDuration) seconds")
            } catch {
                logger.error("Save failed: \(error.localizedDescription)")
            }

            let totalDuration = CACurrentMediaTime() - startTime
            logger.debug("Total operation took \(totalDuration) seconds")
        }
    }
}
