//
//  Array+StringNormalization.swift
//  Retroview
//
//  Created by Adam Schuster on 12/14/24.
//

import Foundation

extension Array where Element == String {
    /// Normalizes and removes duplicates from an array of strings while preserving order.
    /// Normalization includes:
    /// - Trimming external whitespace
    /// - Normalizing internal whitespace (converting multiple spaces/tabs/newlines to single spaces)
    /// - Removing trailing periods
    /// - Case-insensitive comparison
    ///
    /// Example:
    /// ```swift
    /// let subjects = ["Colorado.", "colorado", " Colorado", "New    Mexico", "New\nMexico"]
    /// let normalized = subjects.normalizedUnique() // ["Colorado", "New Mexico"]
    /// ```
    func normalizedUnique() -> [String] {
        // Create a set to track seen values (case-insensitive)
        var seen = Set<String>()
        
        return filter { string in
            // Normalize the string
            let normalized = string
                // First trim external whitespace
                .trimmingCharacters(in: .whitespacesAndNewlines)
                // Replace multiple whitespace characters with a single space
                .components(separatedBy: .whitespaces)
                .filter { !$0.isEmpty }
                .joined(separator: " ")
            
            // Remove trailing period if present
            let withoutPeriod = normalized.hasSuffix(".") ?
                String(normalized.dropLast()) : normalized
            
            // Convert to lowercase for case-insensitive comparison
            let lowercase = withoutPeriod.lowercased()
            
            // Only keep this string if we haven't seen it before
            return seen.insert(lowercase).inserted
        }.map { string in
            // Return the normalized version of the string
            let normalized = string
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .components(separatedBy: .whitespaces)
                .filter { !$0.isEmpty }
                .joined(separator: " ")
            
            return normalized.hasSuffix(".") ?
                String(normalized.dropLast()) : normalized
        }
    }
}
