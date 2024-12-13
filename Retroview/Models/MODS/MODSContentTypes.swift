//
//  MODSContentTypes.swift
//  Retroview
//
//  Created by Adam Schuster on 12/11/24.
//

import Foundation

struct TitleInfoContent: Codable {
    let title: XMLText?
    let supplied: String?
    let usage: String?
    
    init(title: XMLText?, supplied: String?, usage: String?) {
        self.title = title
        self.supplied = supplied
        self.usage = usage
    }
    
    private enum CodingKeys: String, CodingKey {
        case title, supplied, usage
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let titleDict = try? container.decodeIfPresent(XMLText.self, forKey: .title) {
            title = titleDict
        } else if let titleArray = try? container.decodeIfPresent([XMLText].self, forKey: .title) {
            title = titleArray.first
        } else {
            title = nil
        }
        
        supplied = try container.decodeIfPresent(String.self, forKey: .supplied)
        usage = try container.decodeIfPresent(String.self, forKey: .usage)
    }
}

struct NameContent: Codable {
    let namePart: XMLText?
    let type: String?
    let authority: String?
    let valueURI: String?
}

struct SubjectContent: Codable {
    let topic: TopicContent?
    let geographic: GeographicContent?
    let authority: String?
    let valueURI: String?
    
    private enum CodingKeys: String, CodingKey {
        case topic, geographic, authority, valueURI
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle topic that could be dictionary or array
        if let topicDict = try? container.decodeIfPresent(TopicContent.self, forKey: .topic) {
            topic = topicDict
        } else if let topicArray = try? container.decodeIfPresent([TopicContent].self, forKey: .topic) {
            topic = topicArray.first
        } else {
            topic = nil
        }
        
        // Similarly handle geographic
        if let geoDict = try? container.decodeIfPresent(GeographicContent.self, forKey: .geographic) {
            geographic = geoDict
        } else if let geoArray = try? container.decodeIfPresent([GeographicContent].self, forKey: .geographic) {
            geographic = geoArray.first
        } else {
            geographic = nil
        }
        
        authority = try container.decodeIfPresent(String.self, forKey: .authority)
        valueURI = try container.decodeIfPresent(String.self, forKey: .valueURI)
    }
}

struct TopicContent: Codable {
    let x_: String?
    let authority: String?
    let valueURI: String?
}

struct GeographicContent: Codable {
    let x_: String?
    let authority: String?
    let valueURI: String?
}

struct NoteContent: Codable {
    let x_: String?
    let type: String?
}

struct IdentifierContent: Codable {
    let type: String?
    let x_: String?
}

struct OriginInfoContent: Codable {
    let dateCreated: [DateInfoContent]?
    
    private enum CodingKeys: String, CodingKey {
        case dateCreated
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let singleDate = try? container.decode(DateInfoContent.self, forKey: .dateCreated) {
            dateCreated = [singleDate]
        } else if let dateArray = try? container.decode([DateInfoContent].self, forKey: .dateCreated) {
            dateCreated = dateArray
        } else {
            dateCreated = nil
        }
    }
}

struct DateInfoContent: Codable {
    let x_: String?
    let encoding: String?
    let point: String?
    let qualifier: String?
}

