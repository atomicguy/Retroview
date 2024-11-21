//
//  GroupState.swift
//  Retroview
//
//  Created by Adam Schuster on 11/20/24.
//

import Foundation

struct GroupState {
    var isCreating: Bool = false
    var isImporting: Bool = false
    var isExporting: Bool = false
    var error: Error?
    var selectedGroupId: UUID?

    static var initial: GroupState {
        GroupState()
    }
}
