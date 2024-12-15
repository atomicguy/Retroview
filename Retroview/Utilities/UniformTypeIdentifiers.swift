//
//  UniformTypeIdentifiers.swift
//  Retroview
//
//  Created by Adam Schuster on 12/14/24.
//

import UniformTypeIdentifiers

extension UTType {
    static var retroviewDatabase: UTType {
        UTType(exportedAs: "net.atompowered.retroview.database",
               conformingTo: .data)
    }
}
