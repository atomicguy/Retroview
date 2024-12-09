//
//  MODSIdentifier.swift
//  Retroview
//
//  Created by Adam Schuster on 12/8/24.
//

import SwiftData
import Foundation

struct MODSIdentifier {
    // MARK: - Types
    
    struct Identifier {
        let type: String
        let value: String
        let displayLabel: String?
    }
    
    enum IdentifierError: Error {
        case missingUUID
        case invalidUUID(String)
    }
    
    // MARK: - UUID Extraction
    
    static func extractUUID(from identifiers: [[String: Any]]) throws -> UUID {
        // Find the identifier with type "uuid"
        guard let uuidIdentifier = identifiers.first(where: { identifier in
            guard let type = identifier["type"] as? String else { return false }
            return type == "uuid"
        }) else {
            throw IdentifierError.missingUUID
        }
        
        // Extract the value
        guard let uuidString = uuidIdentifier["x_"] as? String,
              let uuid = UUID(uuidString: uuidString) else {
            throw IdentifierError.invalidUUID(String(describing: uuidIdentifier["x_"]))
        }
        
        return uuid
    }
    
    // MARK: - Parsing
    
    static func parseIdentifiers(_ raw: [[String: Any]]) -> [Identifier] {
        return raw.compactMap { identifier -> Identifier? in
            guard let value = identifier["x_"] as? String else { return nil }
            
            return Identifier(
                type: identifier["type"] as? String ?? "",
                value: value,
                displayLabel: identifier["displayLabel"] as? String
            )
        }
    }
}

// MARK: - Usage Example

// MODSIdentifier.swift

extension MODSIdentifier {
    static func example(context: ModelContext) {
        let sampleIdentifiers: [[String: Any]] = [
            [
                "displayLabel": "NYPL catalog ID (B-number)",
                "type": "local_bnumber",
                "x_": "b11708958"
            ],
            [
                "type": "uuid",
                "x_": "0a3eccb0-c56b-012f-54cb-58d385a7bc34"
            ]
        ]
        
        do {
            let uuid = try MODSIdentifier.extractUUID(from: sampleIdentifiers)
            print("Found UUID: \(uuid)")
            
            // Check if card already exists
            let descriptor = FetchDescriptor<StereoCard>(
                predicate: #Predicate<StereoCard> { $0.uuid == uuid }
            )
            
            if let existingCard = try? context.fetch(descriptor).first {
                print("Found existing card: \(existingCard.uuid)")
            } else {
                // Create new card if it doesn't exist
                let newCard = StereoCard(uuid: uuid)
                context.insert(newCard)
                print("Created new card: \(newCard.uuid)")
            }
            
            // Parse and store other identifiers
            let identifiers = MODSIdentifier.parseIdentifiers(sampleIdentifiers)
            for identifier in identifiers {
                print("Type: \(identifier.type), Value: \(identifier.value)")
            }
        } catch {
            print("Error processing identifiers: \(error)")
        }
    }
}
