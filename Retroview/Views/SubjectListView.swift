//
//  SubjectListView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/28/24.
//

import SwiftData
import SwiftUI

struct SubjectsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SubjectSchemaV1.Subject.name) private var subjects:
        [SubjectSchemaV1.Subject]
    @Binding var selectedSubject: SubjectSchemaV1.Subject?

    var body: some View {
        List(subjects) { subject in
            HStack {
                Text(subject.name)

                if !subject.cards.isEmpty {
                    Text("\(subject.cards.count)")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                print("⚠️ Debug: Tapped subject: \(subject.name)")
                selectedSubject = subject
            }
            .background(
                selectedSubject?.id == subject.id
                    ? Color.accentColor.opacity(0.1) : Color.clear)
        }
        .navigationTitle("Subjects")
    }
}

#Preview {
    NavigationSplitView {
        SubjectsListView(selectedSubject: .constant(nil))
            .withPreviewContainer()
    } detail: {
        Text("Detail")
    }
}
