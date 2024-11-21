//
//  GroupManager.swift
//  Retroview
//
//  Created by Adam Schuster on 11/19/24.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class GroupManager: ObservableObject {
    @Published private(set) var state = GroupState.initial

    var selectedGroup: CardGroupSchemaV1.Group? {
        get { _selectedGroup }
        set { selectGroup(newValue) }
    }

    private var _selectedGroup: CardGroupSchemaV1.Group?

    // MARK: - Group Management

    func createGroup(
        name: String, cards: Set<CardSchemaV1.StereoCard>, context: ModelContext
    ) throws {
        guard !name.isEmpty else {
            throw GroupError.invalidName
        }

        guard !cards.isEmpty else {
            throw GroupError.emptySelection
        }

        state.isCreating = true
        defer { state.isCreating = false }

        let group = CardGroupSchemaV1.Group(name: name, cards: Array(cards))
        context.insert(group)

        do {
            try context.save()
            selectedGroup = group
        } catch {
            throw GroupError.saveFailed(error.localizedDescription)
        }
    }

    func addCards(
        _ cards: [CardSchemaV1.StereoCard], to group: CardGroupSchemaV1.Group
    ) {
        group.cards.append(contentsOf: cards)
    }

    func removeCards(
        _ cards: [CardSchemaV1.StereoCard], from group: CardGroupSchemaV1.Group
    ) {
        group.cards.removeAll(where: { cards.contains($0) })
    }

    // MARK: - Import/Export

    func importGroup(from data: Data, into context: ModelContext) throws {
        state.isImporting = true
        defer { state.isImporting = false }

        do {
            let group = try GroupSerializer.deserialize(data, into: context)
            context.insert(group)
            try context.save()
            selectedGroup = group
        } catch {
            throw GroupError.importFailed(error.localizedDescription)
        }
    }

    func exportGroup(_ group: CardGroupSchemaV1.Group) throws -> Data {
        state.isExporting = true
        defer { state.isExporting = false }

        do {
            return try GroupSerializer.serialize(group)
        } catch {
            throw GroupError.exportFailed(error.localizedDescription)
        }
    }

    // MARK: - Private Methods

    private func selectGroup(_ group: CardGroupSchemaV1.Group?) {
        _selectedGroup = group
        state.selectedGroupId = group?.persistentModelID.id as? UUID
    }
}
