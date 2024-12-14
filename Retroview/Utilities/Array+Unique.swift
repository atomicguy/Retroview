//
//  Array+Unique.swift
//  Retroview
//
//  Created by Adam Schuster on 12/13/24.
//

import Foundation

extension Array where Element: Hashable {
    /// Returns a new array with all duplicate elements removed while preserving order
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
