//
//  SetTransformer.swift
//  Retroview
//
//  Created by Adam Schuster on 12/11/24.
//

import Foundation
import SwiftData

@propertyWrapper
struct TransformableSet<T: Hashable & Codable>: Codable {
    var wrappedValue: Set<T>
    
    init(wrappedValue: Set<T>) {
        self.wrappedValue = wrappedValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let array = try container.decode([T].self)
        wrappedValue = Set(array)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(Array(wrappedValue))
    }
}
