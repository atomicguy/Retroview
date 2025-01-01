//
//  PreviewApplication+Cards.swift
//  Retroview
//
//  Created by Adam Schuster on 12/29/24.
//

#if os(visionOS)
    import OSLog
    import QuickLook
    import SwiftUI

    extension PreviewApplication {
        static func openCards(
            _ cards: [CardSchemaV1.StereoCard],
            selectedCard: CardSchemaV1.StereoCard? = nil,
            imageLoader: CardImageLoader
        ) async throws -> PreviewSession? {
            guard let firstCard = cards.first else { return nil }

            _ = SpatialPhotoManager(
                modelContext: firstCard.modelContext!)
            var previewItems: [PreviewItem] = []
            var selectedIndex = 0

            for (index, card) in cards.enumerated() {
                if let sourceImage = try await imageLoader.loadImage(
                    for: card, side: .front, quality: .ultra)
                {
                    let previewItem = try await card.getOrCreatePreviewItem(
                        sourceImage: sourceImage)
                    previewItems.append(previewItem)

                    if card.id == selectedCard?.id {
                        selectedIndex = index
                    }
                }
            }

            if !previewItems.isEmpty {
                return PreviewApplication.open(
                    items: previewItems,
                    selectedItem: previewItems[selectedIndex])
            }

            return nil
        }
    }

    extension Logger {
        /// Log a debug message with file and line information
        func debugWithContext(
            _ message: String, file: String = #file, line: Int = #line
        ) {
            let filename = file.split(separator: "/").last ?? ""
            self.log(level: .debug, "\(message) [\(filename):\(line)]")
        }

        /// Log an error message with file and line information
        func errorWithContext(
            _ message: String, file: String = #file, line: Int = #line
        ) {
            let filename = file.split(separator: "/").last ?? ""
            self.log(level: .error, "\(message) [\(filename):\(line)]")
        }

        /// Log an info message with file and line information
        func infoWithContext(
            _ message: String, file: String = #file, line: Int = #line
        ) {
            let filename = file.split(separator: "/").last ?? ""
            self.log(level: .info, "\(message) [\(filename):\(line)]")
        }

        //    /// Log a warning message with file and line information
        //    func warningWithContext(_ message: String, file: String = #file, line: Int = #line) {
        //        let filename = file.split(separator: "/").last ?? ""
        //        self.log(level: .warning, "\(message) [\(filename):\(line)]")
        //    }
    }
#endif
