//
//  SubjectsView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/28/24.
//

import SwiftData
import SwiftUI

struct SubjectsView: View {
    @Query(sort: \SubjectSchemaV1.Subject.name) private var subjects:
        [SubjectSchemaV1.Subject]
    @State private var selectedSubject: SubjectSchemaV1.Subject?
    @State private var selectedCard: CardSchemaV1.StereoCard?

    var body: some View {
        BrowseLayout(
            listContent: { subjectsList },
            gridContent: { subjectGrid },
            selectedCard: $selectedCard
        )
        .onChange(of: selectedSubject) { _, _ in
            selectedCard = nil
        }
        .platformNavigationTitle("Subjects")
    }

    private var subjectsList: some View {
        List(subjects) { subject in
            SubjectRow(
                subject: subject,
                isSelected: selectedSubject?.id == subject.id,
                action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedSubject = subject
                    }
                }
            )
        }
    }

    private var subjectGrid: some View {
        Group {
            if let subject = selectedSubject {
                CardGridView(
                    cards: subject.cards,
                    selectedCard: $selectedCard,
                    currentCollection: nil,
                    title: "\(subject.name) (\(subject.cards.count) cards)"
                )
                .id(subject.id)
            } else {
                ContentUnavailableView(
                    "No Subject Selected",
                    systemImage: "tag",
                    description: Text("Select a subject to view its cards")
                )
            }
        }
        .animation(.easeInOut(duration: 0.3), value: selectedCard)
        .transition(.move(edge: .trailing))
    }
}

// MARK: - Supporting Views

private struct SubjectRow: View {
    let subject: SubjectSchemaV1.Subject
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        HStack {
            Text(subject.name)

            if !subject.cards.isEmpty {
                Text("\(subject.cards.count)")
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
    }
}

#Preview {
    SubjectsView()
        .withPreviewContainer()
        .frame(width: 1200, height: 800)
}
