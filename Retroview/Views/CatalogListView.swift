//
//  CatalogListView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftData
import SwiftUI

protocol CatalogItem: PersistentModel, Identifiable {
    var name: String { get }
    var cards: [CardSchemaV1.StereoCard] { get }
}

// Conform existing types to CatalogItem
extension AuthorSchemaV1.Author: CatalogItem {}
extension SubjectSchemaV1.Subject: CatalogItem {}

// CatalogListView.swift
struct CatalogListView<Item: CatalogItem>: View {
    @Query private var items: [Item]
    @Binding var selection: Item?
    let title: String
    let icon: String

    init(
        sortBy: SortDescriptor<Item>,
        selection: Binding<Item?>,
        title: String,
        icon: String
    ) {
        _items = Query(sort: [sortBy])
        _selection = selection
        self.title = title
        self.icon = icon
    }

    var body: some View {
        List(items, selection: $selection) { item in
            NavigationLink(value: item) {
                VStack(alignment: .leading) {
                    Text(item.name)
                        .font(.headline)
                    Text("\(item.cards.count) cards")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(title)
    }
}

// CatalogDetailView.swift
struct CatalogDetailView<Item: CatalogItem>: View {
    let item: Item
    @State private var selectedCard: CardSchemaV1.StereoCard?
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            NavigableCardGrid(
                cards: item.cards,
                emptyTitle: "No Cards",
                emptyDescription: "No cards found"
            ) {
                EmptyView()
            }
            .navigationTitle(item.name)
            .navigationDestination(for: CardSchemaV1.StereoCard.self) { card in
                CardDetailView(card: card)
                    .platformNavigationTitle(
                        card.titlePick?.text ?? "Card Details",
                        displayMode: .inline)
            }
        }
    }
}

// CatalogContainerView.swift
struct CatalogContainerView<Item: CatalogItem>: View {
    @State private var selectedItem: Item?
    let title: String
    let icon: String
    let sortDescriptor: SortDescriptor<Item>

    var body: some View {
        NavigationSplitView {
            CatalogListView(
                sortBy: sortDescriptor,
                selection: $selectedItem,
                title: title,
                icon: icon
            )
        } detail: {
            if let item = selectedItem {
                CatalogDetailView(item: item)
            } else {
                ContentUnavailableView {
                    Label("No \(title.dropLast()) Selected", systemImage: icon)
                } description: {
                    Text(
                        "Select a \(title.dropLast().lowercased()) to see their cards"
                    )
                }
            }
        }
    }
}

// AuthorsView.swift
struct AuthorsView: View {
    var body: some View {
        CatalogContainerView<AuthorSchemaV1.Author>(
            title: "Authors",
            icon: "person",
            sortDescriptor: SortDescriptor(\AuthorSchemaV1.Author.name)
        )
    }
}

// SubjectsView.swift
struct SubjectsView: View {
    var body: some View {
        CatalogContainerView<SubjectSchemaV1.Subject>(
            title: "Subjects",
            icon: "tag",
            sortDescriptor: SortDescriptor(\SubjectSchemaV1.Subject.name)
        )
    }
}
