//
//  SubjectsView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftData
import SwiftUI

struct SubjectsView: View {
    @Binding var navigationPath: NavigationPath
    @Query(sort: \SubjectSchemaV1.Subject.name) private var subjects: [SubjectSchemaV1.Subject]
    
    var body: some View {
        List(subjects) { subject in
            NavigationLink(value: subject) {
                VStack(alignment: .leading) {
                    Text(subject.name)
                        .font(.headline)
                    Text("\(subject.cards.count) cards")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Subjects")
    }
}
