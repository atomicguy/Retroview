//
//  ModelPredicates.swift
//  Retroview
//
//  Created by Adam Schuster on 12/21/24.
//

// ModelPredicates.swift

import SwiftData
import Foundation

enum ModelPredicates {
    // MARK: - Card Predicates
    enum Card {
        static func withUUID(_ uuid: UUID) -> Predicate<CardSchemaV1.StereoCard> {
            #Predicate<CardSchemaV1.StereoCard> { card in
                card.uuid == uuid
            }
        }
        
        static func withUUIDString(_ uuidString: String) -> Predicate<CardSchemaV1.StereoCard>? {
            guard let uuid = UUID(uuidString: uuidString) else { return nil }
            return withUUID(uuid)
        }
    }
    
    // MARK: - Title Predicates
    enum Title {
        static func matching(_ text: String) -> Predicate<TitleSchemaV1.Title> {
            #Predicate<TitleSchemaV1.Title> { title in
                title.text == text
            }
        }
    }
    
    // MARK: - Author Predicates
    enum Author {
        static func withName(_ name: String) -> Predicate<AuthorSchemaV1.Author> {
            #Predicate<AuthorSchemaV1.Author> { author in
                author.name == name
            }
        }
    }
    
    // MARK: - Subject Predicates
    enum Subject {
        static func withName(_ name: String) -> Predicate<SubjectSchemaV1.Subject> {
            #Predicate<SubjectSchemaV1.Subject> { subject in
                subject.name == name
            }
        }
    }
    
    // MARK: - Date Predicates
    enum Date {
        static func matching(_ text: String) -> Predicate<DateSchemaV1.Date> {
            #Predicate<DateSchemaV1.Date> { date in
                date.text == text
            }
        }
    }
    
    // MARK: - Collection Predicates
    enum Collection {
        static func withName(_ name: String) -> Predicate<CollectionSchemaV1.Collection> {
            #Predicate<CollectionSchemaV1.Collection> { collection in
                collection.name == name
            }
        }
        
        static var favorites: Predicate<CollectionSchemaV1.Collection> {
            withName(CollectionDefaults.favoritesName)
        }
    }
}

// MARK: - Descriptor Extensions
extension FetchDescriptor {
    static func forUUID<ModelType>(uuid: UUID) -> FetchDescriptor<ModelType> where ModelType: PersistentModel {
        FetchDescriptor<ModelType>(predicate: #Predicate<ModelType> { model in
            (model as? CardSchemaV1.StereoCard)?.uuid == uuid
        })
    }
}
