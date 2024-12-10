//
//  CardMetadataView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftUI

struct CardMetadataView: View {
    let card: CardSchemaV1.StereoCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !card.titles.isEmpty {
                MetadataSection(title: "Titles", items: card.titles.map(\.text))
            }
            
            if !card.authors.isEmpty {
                MetadataSection(title: "Authors", items: card.authors.map(\.name))
            }
            
            if !card.subjects.isEmpty {
                MetadataSection(title: "Subjects", items: card.subjects.map(\.name))
            }
            
            if !card.dates.isEmpty {
                MetadataSection(title: "Dates", items: card.dates.map(\.text))
            }
        }
    }
}

