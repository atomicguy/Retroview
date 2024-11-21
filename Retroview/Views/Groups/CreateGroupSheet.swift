//
//  CreateGroupSheet.swift
//  Retroview
//
//  Created by Adam Schuster on 11/20/24.
//

//
//  CreateGroupSheet.swift
//  Retroview
//

import SwiftData
import SwiftUI

struct CreateGroupSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @StateObject private var groupManager = GroupManager()

    @Binding var name: String
    let selectedCards: Set<CardSchemaV1.StereoCard>
    let onCreate: () -> Void

    @State private var errorMessage: String?
    @State private var showingError = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Group Name", text: $name)
                }

                Section {
                    cardsSummary
                }
            }
            .navigationTitle("Create New Group")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createGroup()
                    }
                    .disabled(name.isEmpty || selectedCards.isEmpty)
                }
            }
        }
        .alert(
            "Error Creating Group", isPresented: $showingError,
            presenting: errorMessage
        ) { _ in
            Button("OK") {}
        } message: { message in
            Text(message)
        }
        .frame(minWidth: 300, minHeight: 200)
    }

    private var cardsSummary: some View {
        VStack(alignment: .leading) {
            Text("\(selectedCards.count) cards selected")
                .foregroundStyle(.secondary)

            if selectedCards.isEmpty {
                Text("Select at least one card to create a group")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func createGroup() {
        do {
            try groupManager.createGroup(
                name: name,
                cards: selectedCards,
                context: context
            )
            onCreate()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}

// MARK: - Preview

#Preview {
    CreateGroupSheet(
        name: .constant("New Group"),
        selectedCards: Set(PreviewHelper.shared.previewCards.prefix(2)),
        onCreate: {}
    )
    .modelContainer(PreviewHelper.shared.modelContainer)
}
