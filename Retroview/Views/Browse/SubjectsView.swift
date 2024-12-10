//
//  SubjectsView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftData
import SwiftUI

struct SubjectsView: View {
    @Query private var subjects: [SubjectSchemaV1.Subject]
    @State private var selectedSubject: SubjectSchemaV1.Subject?
    @State private var selectedCard: CardSchemaV1.StereoCard?
    
    var body: some View {
        HStack(spacing: 0) {
            List(subjects, selection: $selectedSubject) { subject in
                Text(subject.name)
            }
            .frame(width: 200)
            
            if let subject = selectedSubject {
                HStack(spacing: 0) {
                    BrowseGrid(
                        cards: subject.cards,
                        selectedCard: $selectedCard
                    )
                    
                    if let card = selectedCard {
                        Divider()
                        CardContentView(card: card)
                            .frame(width: 300)
                    }
                }
            } else {
                ContentUnavailableView(
                    "No Subject Selected",
                    systemImage: "tag",
                    description: Text("Select a subject to view its cards")
                )
            }
            
            Divider()
        }
    }
}
