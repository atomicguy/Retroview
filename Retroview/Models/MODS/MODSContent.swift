//
//  MODSContent.swift
//  Retroview
//
//  Created by Adam Schuster on 12/10/24.
//

import Foundation

struct MODSContent: Codable {
    let titleInfo: TitleInfoContent
    let name: NameContent?
    let note: [[NoteContent]]?
    let identifier: [[IdentifierContent]]?
    let originInfo: [OriginInfoContent]?
    let subject: [[SubjectContent]]?

    private enum CodingKeys: String, CodingKey {
        case titleInfo, name, subject, note, identifier, originInfo
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle titleInfo which can be either single or array
        do {
            titleInfo = try container.decode(TitleInfoContent.self, forKey: .titleInfo)
        } catch {
            let array = try container.decode([TitleInfoContent].self, forKey: .titleInfo)
            guard let first = array.first else {
                throw DecodingError.dataCorrupted(.init(
                    codingPath: container.codingPath,
                    debugDescription: "Empty titleInfo array"
                ))
            }
            titleInfo = first
        }
        
        // Handle optional name
        name = try container.decodeIfPresent(NameContent.self, forKey: .name)
        
        // Handle subject that could be single dictionary or array
        if let singleSubject = try? container.decode(SubjectContent.self, forKey: .subject) {
            subject = [[singleSubject]]
        } else {
            subject = try container.decodeIfPresent([[SubjectContent]].self, forKey: .subject)
        }
        
        // Handle remaining optional arrays
        note = try container.decodeIfPresent([[NoteContent]].self, forKey: .note)
        identifier = try container.decodeIfPresent([[IdentifierContent]].self, forKey: .identifier)
        originInfo = try container.decodeIfPresent([OriginInfoContent].self, forKey: .originInfo)
    }
}
