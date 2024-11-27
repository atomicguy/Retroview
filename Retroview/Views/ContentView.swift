//
//  ContentView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/24/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    enum Category: String, CaseIterable, Identifiable {
        case title = "Title"
        case author = "Author"
        case subject = "Subject"
        case date = "Date"
        
        var id: String { self.rawValue }
    }
    
    @State private var selectedCategory: Category? = .title
    @State private var selectedItem: UUID?
    @State private var selectedCards: [CardSchemaV1.StereoCard] = []
    
    // Fetch all StereoCards
    @Query(sort: \.uuid)
    private var stereoCards: [CardSchemaV1.StereoCard]
    
    var body: some View {
        NavigationSplitView {
            // First Column: Categories
            List(Category.allCases, selection: $selectedCategory) { category in
                Text(category.rawValue)
            }
            .navigationTitle("Categories")
        } content: {
            // Second Column: Items based on selected category
            List(selection: $selectedItem) {
                switch selectedCategory {
                case .title:
                    ForEach(getUniqueTitles()) { title in
                        Text(title.name)
                            .tag(title.id)
                    }
                case .author:
                    ForEach(getUniqueAuthors()) { author in
                        Text(author.name)
                            .tag(author.id)
                    }
                case .subject:
                    ForEach(getUniqueSubjects()) { subject in
                        Text(subject.name)
                            .tag(subject.id)
                    }
                case .date:
                    ForEach(getUniqueDates()) { date in
                        Text(date.text)
                            .tag(date.id)
                    }
                case .none:
                    Text("Select a Category")
                }
            }
            .navigationTitle("Items")
        } detail: {
            // Third Column: Card Details
            if !selectedCards.isEmpty {
                CardDetailView(cards: selectedCards)
            } else {
                Text("Select an Item")
                    .navigationTitle("Details")
            }
        }
        .onChange(of: selectedItem) { _ in
            updateSelectedCards()
        }
        .onChange(of: selectedCategory) { _ in
            selectedItem = nil
            selectedCards = []
        }
    }
    
    // Helper functions to get unique items
    private func getUniqueTitles() -> [TitleSchemaV1.Title] {
        let allTitles = stereoCards.flatMap { $0.titles }
        return Array(Set(allTitles))
    }
    
    private func getUniqueAuthors() -> [AuthorSchemaV1.Author] {
        let allAuthors = stereoCards.flatMap { $0.authors }
        return Array(Set(allAuthors))
    }
    
    private func getUniqueSubjects() -> [SubjectSchemaV1.Subject] {
        let allSubjects = stereoCards.flatMap { $0.subjects }
        return Array(Set(allSubjects))
    }
    
    private func getUniqueDates() -> [DateSchemaV1.Date] {
        let allDates = stereoCards.flatMap { $0.dates }
        return Array(Set(allDates))
    }
    
    // Update selectedCards based on selectedItem and category
    private func updateSelectedCards() {
        switch selectedCategory {
        case .title:
            if let titleID = selectedItem,
               let title = getUniqueTitles().first(where: { $0.id == titleID }) {
                selectedCards = title.cards
            } else {
                selectedCards = []
            }
        case .author:
            if let authorID = selectedItem,
               let author = getUniqueAuthors().first(where: { $0.id == authorID }) {
                selectedCards = author.cards
            } else {
                selectedCards = []
            }
        case .subject:
            if let subjectID = selectedItem,
               let subject = getUniqueSubjects().first(where: { $0.id == subjectID }) {
                selectedCards = subject.cards
            } else {
                selectedCards = []
            }
        case .date:
            if let dateID = selectedItem,
               let date = getUniqueDates().first(where: { $0.id == dateID }) {
                selectedCards = date.cards
            } else {
                selectedCards = []
            }
        case .none:
            selectedCards = []
        }
    }
}
