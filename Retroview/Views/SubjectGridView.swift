//
//  SubjectGridView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/28/24.
//

import SwiftData
import SwiftUI

struct SubjectGridView: View {
    @Environment(\.modelContext) private var modelContext
    let subject: SubjectSchemaV1.Subject
    @Binding var selectedCard: CardSchemaV1.StereoCard?

    var cards: [CardSchemaV1.StereoCard] {
        let cardCount = subject.cards.count
        print("⚠️ Debug: Subject '\(subject.name)' has \(cardCount) cards")
        print("⚠️ Debug: Subject ID: \(ObjectIdentifier(subject))")
        print(
            "⚠️ Debug: First few card titles: \(subject.cards.prefix(3).compactMap { $0.titlePick?.text })"
        )
        return subject.cards
    }

    private let columns = [
        GridItem(.adaptive(minimum: 250, maximum: 300), spacing: 10)
    ]

    var body: some View {
        ScrollView {
            if cards.isEmpty {
                ContentUnavailableView(
                    "No Cards",
                    systemImage: "photo.on.rectangle.angled",
                    description: Text(
                        "This subject has no associated cards yet")
                )
            } else {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(cards) { card in
                        SquareCropView(card: card)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedCard = card
                            }
                            .overlay {
                                if selectedCard?.uuid == card.uuid {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.accentColor, lineWidth: 3)
                                }
                            }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("\(subject.name) (\(cards.count) cards)")
        .onChange(of: subject) { oldValue, newValue in
            print(
                "⚠️ Debug: Subject changed from \(oldValue.name) to \(newValue.name)"
            )
            print("⚠️ Debug: New card count: \(newValue.cards.count)")
        }
    }
}

#Preview("Grid - Wide") {
    let container = PreviewContainer.shared.modelContainer
    let subject = try! container.mainContext.fetch(
        FetchDescriptor<SubjectSchemaV1.Subject>()
    ).first!
    return SubjectGridView(subject: subject, selectedCard: .constant(nil))
        .frame(width: 800, height: 600)
        .modelContainer(container)
}
