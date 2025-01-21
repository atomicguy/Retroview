//
//  CatalogItemProtocol.swift
//  Retroview
//
//  Created by Adam Schuster on 12/23/24.
//

import SwiftData
import Foundation

protocol CatalogItem: PersistentModel, Identifiable, StackDisplayable {
    var name: String { get }
    var cards: [CardSchemaV1.StereoCard] { get }
    var thumbnailData: Data? { get set }
}

// Existing conformances remain the same since they now get StackDisplayable through CatalogItem
extension AuthorSchemaV1.Author: CatalogItem {}
extension SubjectSchemaV1.Subject: CatalogItem {}
extension DateSchemaV1.Date: CatalogItem {}
