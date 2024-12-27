//
//  CardSubjectSection.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftUI
#if DEBUG
import SwiftData
#endif

struct CardSubjectSection: View {
    let subjects: [SubjectSchemaV1.Subject]
    
    var body: some View {
        MetadataSection(title: "Subjects") {
            FlowLayout {
                ForEach(subjects) { subject in
                    NavigationLink(value: subject) {
                        SubjectBadge(name: subject.name)
                    }
                }
            }
        }
    }
}

#Preview("Card Subject Section") {
    let previewContainer = try! PreviewDataManager.shared.container()
    let card = try! previewContainer.mainContext.fetch(FetchDescriptor<CardSchemaV1.StereoCard>()).first!
    
    return CardSubjectSection(subjects: card.subjects)
        .withPreviewStore()
        .padding()
}
