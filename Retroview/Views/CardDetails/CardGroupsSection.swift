//
//  CardGroupsSection.swift
//  Retroview
//
//  Created by Adam Schuster on 1/26/25.
//

import SwiftUI
import SwiftData

protocol GroupMetadata: PersistentModel {
    var name: String { get }
    var cards: [CardSchemaV1.StereoCard] { get }
}

extension SubjectSchemaV1.Subject: GroupMetadata {}
extension AuthorSchemaV1.Author: GroupMetadata {}
extension DateSchemaV1.Date: GroupMetadata {}

struct CardGroupsSection<T: GroupMetadata>: View {
    let items: [T]
    let title: String
    
    var body: some View {
        MetadataSection(title: title) {
            FlowLayout {
                ForEach(items) { item in
                    NavigationLink(value: item) {
                        GroupItemBadge(name: item.name)
                    }
                    .modifier(SerifFontModifier())
                }
            }
        }
    }
}

struct GroupItemBadge: View {
    let name: String
    
    var body: some View {
        Text(name)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .clipShape(Capsule())
    }
}

struct SubjectsSection: View {
    let subjects: [SubjectSchemaV1.Subject]
    
    var body: some View {
        CardGroupsSection(items: subjects, title: "Subjects")
    }
}

struct AuthorsSection: View {
    let authors: [AuthorSchemaV1.Author]
    
    var body: some View {
        CardGroupsSection(items: authors, title: "Authors")
    }
}

struct DatesSection: View {
    let dates: [DateSchemaV1.Date]
    
    var body: some View {
        CardGroupsSection(items: dates, title: "Dates")
    }
}

#Preview("Card Groups Section") {
    let subjects = [SubjectSchemaV1.Subject(name: "Mountains")]
    return CardGroupsSection(items: subjects, title: "Subjects")
        .padding()
}
