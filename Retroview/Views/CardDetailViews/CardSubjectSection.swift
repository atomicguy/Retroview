//
//  CardSubjectSection.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftUI

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
