//
//  VisionSubjectsView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/1/24.
//

import SwiftData
import SwiftUI

#if os(visionOS)
    struct VisionSubjectsView: View {
        @Query(sort: \SubjectSchemaV1.Subject.name) private var subjects:
            [SubjectSchemaV1.Subject]
        @State private var selectedSubject: SubjectSchemaV1.Subject?
        @State private var selectedCard: CardSchemaV1.StereoCard?

        var body: some View {
            NavigationSplitView {
                List(subjects, selection: $selectedSubject) { subject in
                    SubjectRow(subject: subject)
                        .tag(subject)
                }
                .navigationTitle("Subjects")
            } detail: {
                if let subject = selectedSubject {
                    LibraryView()
                        .navigationTitle(
                            "\(subject.name) (\(subject.cards.count) cards)")
                } else {
                    ContentUnavailableView(
                        "No Subject Selected",
                        systemImage: "tag",
                        description: Text("Select a subject to view its cards")
                    )
                }
            }
        }
    }

    private struct SubjectRow: View {
        let subject: SubjectSchemaV1.Subject

        var body: some View {
            HStack {
                Text(subject.name)

                if !subject.cards.isEmpty {
                    Text("\(subject.cards.count)")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
        }
    }

    #Preview {
        VisionSubjectsView()
            .withPreviewContainer()
    }
#endif
