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
    @State private var exportingGroup: CardGroupSchemaV1.Group?
    @State private var newGroupName = ""

    var filteredCards: [CardSchemaV1.StereoCard] {
        cards.filter { filter.applies(to: $0) }
    }

    var body: some View {
        NavigationSplitView {
            List(
                selection: Binding(
                    get: { groupManager.selectedGroup },
                    set: { groupManager.selectedGroup = $0 }
                )
            ) {
                Section("Filters") {
                    TextField("Search", text: $filter.searchText)

                    Picker("Author", selection: $filter.selectedAuthor) {
                        Text("Any").tag(nil as AuthorSchemaV1.Author?)
                        ForEach(authors) { author in
                            Text(author.name).tag(
                                author as AuthorSchemaV1.Author?)
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
                            Text(subject.name).tag(
                                subject as SubjectSchemaV1.Subject?)
                        }
                    }
                }

                Section("Groups") {
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
                                exportingGroup = group
                                showingGroupExporter = true
                            }
                        }
                    }
                }
            }
            .frame(minWidth: 200)
            .navigationTitle("Collections")
        } content: {
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
            if let group = groupManager.selectedGroup {
                GroupDetailView(group: group)
            } else if let card = selectedCards.first {
                CardDetailView(card: card)
            } else {
                Text("Select a card or group")
            }
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
            document: exportingGroup.map { @MainActor group in
                GroupDocument(group: group)
            },
            contentType: .json,
            defaultFilename: exportingGroup?.name
        ) { result in
            Task { @MainActor in
                if case .failure(let error) = result {
                    print(
                        "Error exporting group: \(error.localizedDescription)")
                }
                exportingGroup = nil
            }
        }
        .sheet(isPresented: $showingCreateGroup) {
            CreateGroupSheet(
                name: $newGroupName,
                selectedCards: selectedCards,
                onCreate: createNewGroup
            )
        }
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
            if let selectedGroup = groupManager.selectedGroup {
                exportingGroup = selectedGroup
                showingGroupExporter = true
            }
        }
    }

    private func createNewGroup() {
        guard !newGroupName.isEmpty else { return }

        // Create new group
        let group = CardGroupSchemaV1.Group(
            name: newGroupName,
            cards: Array(selectedCards)
        )

        // Insert into context
        context.insert(group)

        // Try to save context
        do {
            try context.save()
            // Select the newly created group
            groupManager.selectedGroup = group
        } catch {
            print("Error saving group: \(error.localizedDescription)")
        }

        // Reset state
        newGroupName = ""
        selectedCards.removeAll()
        showingCreateGroup = false
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
}

struct SidebarView: View {
    @Binding var filter: CardFilter
    let groups: [CardGroupSchemaV1.Group]
    let selectedGroup: CardGroupSchemaV1.Group?
    let onGroupSelect: (CardGroupSchemaV1.Group) -> Void

    @Query private var authors: [AuthorSchemaV1.Author]
    @Query private var dates: [DateSchemaV1.Date]
    @Query private var subjects: [SubjectSchemaV1.Subject]

    var body: some View {
        List(selection: .constant(selectedGroup)) {
            Section("Filters") {
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
                        Text(subject.name).tag(
                            subject as SubjectSchemaV1.Subject?)
                    }
                }
            }

            Section("Groups") {
                ForEach(groups) { group in
                    HStack {
                        Text(group.name)
                        Spacer()
                        Text("\(group.cards.count)")
                            .foregroundStyle(.secondary)
                    }
                    .tag(group)
                    .onTapGesture {
                        onGroupSelect(group)
                    }
                }
            }
        }
    }
}

struct CardBrowserView: View {
    let cards: [CardSchemaV1.StereoCard]
    @Binding var selectedCards: Set<CardSchemaV1.StereoCard>
    let onCreateGroup: () -> Void

    var body: some View {
        VStack {
            toolbar
            ScrollView {
                LazyVGrid(columns: [.init(.adaptive(minimum: 300))]) {
                    ForEach(cards) { card in
                        UnifiedCardView(card: card)
                            .overlay(selectionOverlay(for: card))
                            .onTapGesture {
                                toggleSelection(card)
                            }
                    }
                }
                .padding()
            }
        }
    }

    private var toolbar: some View {
        HStack {
            Text("\(selectedCards.count) selected")
            Spacer()
            if !selectedCards.isEmpty {
                Button("Create Group", action: onCreateGroup)
            }
        }
        .padding()
    }

    private func selectionOverlay(for card: CardSchemaV1.StereoCard)
        -> some View
    {
        Group {
            if selectedCards.contains(card) {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.blue, lineWidth: 2)
                    .overlay(
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.blue)
                            .padding(8),
                        alignment: .topTrailing
                    )
            }
        }
    }

    private func toggleSelection(_ card: CardSchemaV1.StereoCard) {
        if selectedCards.contains(card) {
            selectedCards.remove(card)
        } else {
            selectedCards.insert(card)
        }
    }
}

struct CreateGroupSheet: View {
    @Binding var name: String
    let selectedCards: Set<CardSchemaV1.StereoCard>
    let onCreate: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextField("Group Name", text: $name)
                Text("\(selectedCards.count) cards selected")
            }
            .navigationTitle("Create New Group")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        onCreate()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
        .frame(minWidth: 300, minHeight: 200)
    }
}

struct GroupDetailView: View {
    @Bindable var group: CardGroupSchemaV1.Group

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(group.name)
                .font(.title)

            Text("Created \(group.createdAt.formatted())")
                .foregroundStyle(.secondary)

            Text("\(group.cards.count) cards")
                .foregroundStyle(.secondary)

            ScrollView {
                LazyVGrid(columns: [.init(.adaptive(minimum: 300))]) {
                    ForEach(group.cards) { card in
                        UnifiedCardView(card: card)
                    }
                }
                .padding()
            }
        }
        .padding()
    }
}

// Helper for exporting groups
struct GroupDocument: @preconcurrency FileDocument {
    let group: CardGroupSchemaV1.Group

    static var readableContentTypes: [UTType] { [.json] }

    init(group: CardGroupSchemaV1.Group) {
        self.group = group
    }

    init(configuration: ReadConfiguration) throws {
        // We don't need to implement this as we're only using this for export
        fatalError("Import not supported")
    }

    @MainActor
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        // Create serializable version without GroupManager
        let serializableGroup = SerializableGroup(from: group)
        let data = try JSONEncoder().encode(serializableGroup)
        return .init(regularFileWithContents: data)
    }
}
