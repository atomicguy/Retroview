//
//  MODSBaseModels.swift
//  Retroview
//
//  Created by Adam Schuster on 12/11/24.
//

import Foundation

/// Base protocol for XML-derived text content
protocol XMLTextContent {
    var x_: String { get }
}

/// Represents a flattened XML text node
struct XMLText: XMLTextContent, Codable {
    let x_: String
}

