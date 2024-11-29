//
//  SubjectsView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/28/24.
//

import SwiftData
import SwiftUI

struct SubjectsView: View {
    @State private var selectedSubject: SubjectSchemaV1.Subject?
    @State private var selectedCard: CardSchemaV1.StereoCard?
    @State private var isChangingSubject = false

    private let subjectsWidth: CGFloat = 220
    private let detailWidth: CGFloat = 300

    var body: some View {
        HStack(spacing: 0) {
            SubjectsListView(selectedSubject: $selectedSubject)
                .frame(width: subjectsWidth)

            Divider()

            // Center section with transitions
            Group {
                if let subject = selectedSubject {
                    SubjectGridView(
                        subject: subject, selectedCard: $selectedCard
                    )
                    .frame(maxWidth: .infinity)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .top).combined(
                                with: .opacity),
                            removal: .move(edge: .bottom).combined(
                                with: .opacity)
                        )
                    )
                    .id(subject.id)
                } else {
                    ContentUnavailableView(
                        "No Subject Selected",
                        systemImage: "tag",
                        description: Text("Select a subject to view its cards")
                    )
                    .frame(maxWidth: .infinity)
                    .transition(.opacity)
                }
            }
            .animation(.smooth, value: selectedSubject)

            Divider()

            // Detail section with transitions
            Group {
                if let card = selectedCard {
                    CardContentView(card: card)
                        .id(card.uuid)
                        .transition(.move(edge: .top).combined(with: .opacity))
                } else {
                    ContentUnavailableView(
                        "No Card Selected",
                        systemImage: "photo.on.rectangle",
                        description: Text("Select a card to view its details")
                    )
                    .transition(.opacity)
                }
            }
            .animation(.smooth, value: selectedCard)
            .frame(width: detailWidth)
        }
        .onChange(of: selectedSubject) { _, _ in
            selectedCard = nil
        }
    }
}

#Preview("Subjects View") {
    SubjectsView()
        .withPreviewContainer()
        .frame(width: 1200, height: 800)
}
