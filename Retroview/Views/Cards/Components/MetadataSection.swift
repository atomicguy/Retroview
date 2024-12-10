//
//  MetadataSection.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftUI

struct MetadataSection: View {
    let title: String
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            
            if items.isEmpty {
                Text("No \(title.lowercased()) available")
                    .italic()
                    .foregroundStyle(.secondary)
            } else {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 20) {
        MetadataSection(
            title: "Authors",
            items: ["John Smith", "Jane Doe"]
        )
        
        MetadataSection(
            title: "Subjects",
            items: []
        )
    }
    .padding()
}
