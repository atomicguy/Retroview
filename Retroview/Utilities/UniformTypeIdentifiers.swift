//
//  UniformTypeIdentifiers.swift
//  Retroview
//
//  Created by Adam Schuster on 12/14/24.
//

import UniformTypeIdentifiers

extension UTType {
    static var retroviewStore: UTType {
        UTType(exportedAs: "net.atompowered.retroview.store")
    }
}
