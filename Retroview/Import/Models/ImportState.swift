//
//  ImportState.swift
//  Retroview
//
//  Created by Adam Schuster on 11/20/24.
//

import Foundation

struct ImportState {
    var isImporting: Bool = false
    var progress: Double = 0
    var error: Error?
    
    static var initial: ImportState {
        ImportState()
    }
}
