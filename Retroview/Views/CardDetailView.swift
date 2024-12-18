//
//  CardDetailView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/15/24.
//

import SwiftData
import SwiftUI

struct CardDetailView: View {
    let card: CardSchemaV1.StereoCard
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(card.titlePick?.text ?? "Untitled")
                        .font(.title)
                    
                    if !card.authors.isEmpty {
                        Text(card.authors.map(\.name).joined(separator: ", "))
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Images
                if card.imageFrontId != nil {
                    CardImageSection(card: card, side: .front, title: "Front")
                }
                
                if card.imageBackId != nil {
                    CardImageSection(card: card, side: .back, title: "Back")
                }
                
                // Metadata
                if !card.subjects.isEmpty {
                    metadataSection("Subjects") {
                        FlowLayout {
                            ForEach(card.subjects, id: \.name) { subject in
                                NavigationLink(value: subject) {
                                    Text(subject.name)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(.secondary.opacity(0.1))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                }
                
                if !card.titles.isEmpty {
                    metadataSection("Titles") {
                        ForEach(card.titles, id: \.text) { title in
                            Text(title.text)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(card.titlePick?.text ?? "Untitled Card")
    }
    
    private func metadataSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content()
        }
    }
}
