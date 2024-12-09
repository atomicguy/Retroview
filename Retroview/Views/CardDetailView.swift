//
//  CardDetailView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/8/24.
//

import SwiftData
import SwiftUI

struct CardDetailView: View {
    let card: StereoCard
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Titles
                ForEach(card.titles, id: \.self) { title in
                    Text(title)
                        .font(.title)
                }
                
                // Authors
                if !card.authors.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Authors")
                            .font(.headline)
                        ForEach(card.authors, id: \.name) { author in
                            Text(author.name)
                        }
                    }
                }
                
                // Subjects
                if !card.subjects.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Subjects")
                            .font(.headline)
                        ForEach(card.subjects, id: \.name) { subject in
                            Text(subject.name)
                        }
                    }
                }
                
                // Image IDs
                VStack(alignment: .leading) {
                    Text("Image IDs")
                        .font(.headline)
                    if let frontId = card.imageFrontId {
                        Text("Front: \(frontId)")
                    }
                    if let backId = card.imageBackId {
                        Text("Back: \(backId)")
                    }
                }
            }
            .padding()
        }
    }
}
