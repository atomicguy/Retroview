//
//  GroupItemProtocol.swift
//  Retroview
//
//  Created by Adam Schuster on 12/23/24.
//

import SwiftData
import Foundation

protocol GroupItem: PersistentModel, Identifiable, StackDisplayable {
    var name: String { get }
    var cards: [CardSchemaV1.StereoCard] { get }
    var thumbnailData: Data? { get set }
}

// Existing conformances remain the same since they now get StackDisplayable through GroupItem
extension AuthorSchemaV1.Author: GroupItem {}
extension SubjectSchemaV1.Subject: GroupItem {}
extension DateSchemaV1.Date {
    var name: String { text.isEmpty ? "Unknown" : text  }
}
extension DateSchemaV1.Date: GroupItem {}
extension CollectionSchemaV1.Collection: GroupItem {}
