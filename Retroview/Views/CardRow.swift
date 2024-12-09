//
//  CardRow.swift
//  Retroview
//
//  Created by Adam Schuster on 12/8/24.
//

import SwiftUI

struct CardRow: View {
    let card: StereoCard
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(card.primaryTitle)
                .font(.headline)
            
            if let author = card.authors.first {
                Text(author.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if !card.subjects.isEmpty {
                Text(card.subjects.map(\.name).joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
