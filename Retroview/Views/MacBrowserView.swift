//
//  MacBrowserView.swift
//  Retroview
//

import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct MacBrowserView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \CardGroupSchemaV1.Group.createdAt, order: .reverse) private
    var groups: [CardGroupSchemaV1.Group]
    @Query private var cards: [CardSchemaV1.StereoCard]
    @Query private var authors: [AuthorSchemaV1.Author]
    @Query private var dates: [DateSchemaV1.Date]
    @Query private var subjects: [SubjectSchemaV1.Subject]

    @StateObject private var groupManager = GroupManager()
    @StateObject private var importViewModel = ImportViewModel()
    @State private var filter = CardFilter()
    @State private var selectedCards: Set<CardSchemaV1.StereoCard> = []
    @State private var showingCreateGroup = false
    @State private var showingImporter = false
    @State private var showingGroupImporter = false
    @State private var showingGroupExporter = false
    @State private var newGroupName = ""

    var filteredCards: [CardSchemaV1.StereoCard] {
        cards.filter { filter.applies(to: $0) }
    }

    var body: some View {
        NavigationSplitView {
            // Sidebar with filters and groups
            List(
                selection: Binding(
                    get: { groupManager.selectedGroup },
                    set: { groupManager.selectedGroup = $0 }
                )
            ) {
                Section("Filters") {
                    filterSection
                }

                Section("Groups") {
                    groupsSection
                }
            }
            .frame(minWidth: 200)
            .navigationTitle("Collections")
        } content: {
            // Main content area
            CardBrowserView(
                cards: filteredCards,
                selectedCards: $selectedCards,
                onCreateGroup: { showingCreateGroup = true }
            )
            .frame(minWidth: 400)
            .toolbar {
                ToolbarItem {
                    Button(action: { showingImporter = true }) {
                        Label(
                            "Import Cards", systemImage: "square.and.arrow.down"
                        )
                    }
                }
            }
        } detail: {
            // Detail view
            detailContent
        }
        .sheet(isPresented: $showingCreateGroup) {
            CreateGroupSheet(
                name: $newGroupName,
                selectedCards: selectedCards,
                onCreate: {
                    selectedCards.removeAll()
                    newGroupName = ""
                }
            )
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.json],
            allowsMultipleSelection: true
        ) { result in
            handleImport(result)
        }
        .fileImporter(
            isPresented: $showingGroupImporter,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleGroupImport(result)
        }
        .fileExporter(
            isPresented: $showingGroupExporter,
            document: groupManager.selectedGroup.map {
                GroupDocument(group: $0)
            },
            contentType: .json,
            defaultFilename: groupManager.selectedGroup?.name
        ) { result in
            handleGroupExport(result)
        }
        .toolbar {
            ToolbarItem {
                Button(action: { showingImporter = true }) {
                    Label("Import Cards", systemImage: "square.and.arrow.down")
                }
            }
        }
        // Notification handlers
        .onReceive(NotificationCenter.default.publisher(for: .importRequested)) { _ in
            showingImporter = true
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .importGroupRequested)
        ) { _ in
            showingGroupImporter = true
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .exportGroupRequested)
        ) { _ in
            if groupManager.selectedGroup != nil {
                showingGroupExporter = true
            }
        }
    }

    // MARK: - View Components

    private var filterSection: some View {
        Group {
            TextField("Search", text: $filter.searchText)

            Picker("Author", selection: $filter.selectedAuthor) {
                Text("Any").tag(nil as AuthorSchemaV1.Author?)
                ForEach(authors) { author in
                    Text(author.name).tag(author as AuthorSchemaV1.Author?)
                }
            }

            Picker("Date", selection: $filter.selectedDate) {
                Text("Any").tag(nil as DateSchemaV1.Date?)
                ForEach(dates) { date in
                    Text(date.text).tag(date as DateSchemaV1.Date?)
                }
            }

            Picker("Subject", selection: $filter.selectedSubject) {
                Text("Any").tag(nil as SubjectSchemaV1.Subject?)
                ForEach(subjects) { subject in
                    Text(subject.name).tag(subject as SubjectSchemaV1.Subject?)
                }
            }
        }
    }

    private var groupsSection: some View {
        ForEach(groups) { group in
            NavigationLink(value: group) {
                HStack {
                    Text(group.name)
                    Spacer()
                    Text("\(group.cards.count)")
                        .foregroundStyle(.secondary)
                }
            }
            .contextMenu {
                Button("Export Group...") {
                    groupManager.selectedGroup = group
                    showingGroupExporter = true
                }
            }
        }
    }

    private var detailContent: some View {
        Group {
            if let group = groupManager.selectedGroup {
                GroupDetailView(group: group)
            } else if let card = selectedCards.first {
                CardDetailView(card: card)
            } else {
                Text("Select a card or group")
            }
        }
    }

    private var createGroupSheet: some View {
        NavigationStack {
            Form {
                TextField("Group Name", text: $newGroupName)
                Text("\(selectedCards.count) cards selected")
            }
            .navigationTitle("Create New Group")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingCreateGroup = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createGroup()
                    }
                    .disabled(newGroupName.isEmpty)
                }
            }
        }
        .frame(minWidth: 300, minHeight: 200)
    }

    // MARK: - Actions

    private func createGroup() {
        do {
            try groupManager.createGroup(
                name: newGroupName,
                cards: selectedCards,
                context: context
            )
            // Reset state after successful creation
            newGroupName = ""
            selectedCards.removeAll()
            showingCreateGroup = false
        } catch {
            print("Failed to create group: \(error.localizedDescription)")
            // Here you might want to show an error alert to the user
        }
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            for url in urls {
                importViewModel.importData(fromFile: url, context: context)
            }
        case .failure(let error):
            print("Error importing cards: \(error.localizedDescription)")
        }
    }

    private func handleGroupImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            do {
                let data = try Data(contentsOf: url)
                try groupManager.importGroup(from: data, into: context)
            } catch {
                print("Error importing group: \(error.localizedDescription)")
            }
        case .failure(let error):
            print("Error importing group: \(error.localizedDescription)")
        }
    }

    private func handleGroupExport(_ result: Result<URL, Error>) {
        if case .failure(let error) = result {
            print("Error exporting group: \(error.localizedDescription)")
        }
    }
}
