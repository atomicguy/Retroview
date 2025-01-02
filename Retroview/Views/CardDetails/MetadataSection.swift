//
//  MetadataSection.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftUI

struct MetadataSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(.headline, design: .serif))
            content()
        }
    }
}

#Preview("Metadata Section") {
    MetadataSection(title: "Preview Section") {
        Text("Some content")
        Text("More content")
    }
    .withPreviewStore()
    .padding()
}
