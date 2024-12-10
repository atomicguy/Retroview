//
//  MODSParsingService.swift
//  Retroview
//
//  Created by Adam Schuster on 12/8/24.
//

import Foundation

// MARK: - MODS Parsing Service
final class MODSParsingService {
    static func convertMODSToStereoCard(_ modsData: Data) throws -> StereoCardJSON {
        let decoder = JSONDecoder()
        
        let modsContainer = try decoder.decode(MODSRoot.self, from: modsData)
        guard let response = modsContainer.card?.nyplAPI?.response else {
            throw MODSError.invalidMODSData
        }
        
        // Extract UUID from the capture data
        guard let uuid = response.capture?.first?.uuid.x_ else {
            throw MODSError.missingRequiredField("UUID")
        }
        
        // Extract titles
        let titles = extractTitles(from: response.mods?.titleInfo)
        
        // Extract subjects
        let subjects = extractSubjects(from: response.mods?.subject)
        
        // Extract image IDs
        guard let captures = response.capture,
              captures.count >= 2 else {
            throw MODSError.missingRequiredField("Image IDs")
        }
        
        let imageIds = ImageIDs(
            front: captures[0].imageID.x_,
            back: captures[1].imageID.x_
        )
        
        // Extract dates
        let dates = extractDates(from: response.mods?.originInfo)
        
        // Extract authors
        let authors = extractAuthors(from: response.mods)
        
        // Since crops are not in MODS, we'll need to get them from elsewhere
        // Using placeholder values for now
        let leftCrop = CropData(
            x0: 0.05, y0: 0.05,
            x1: 0.95, y1: 0.45,
            score: 0.99,
            side: "left"
        )
        
        let rightCrop = CropData(
            x0: 0.05, y0: 0.55,
            x1: 0.95, y1: 0.95,
            score: 0.99,
            side: "right"
        )
        
        return StereoCardJSON(
            uuid: uuid,
            titles: titles,
            subjects: subjects,
            authors: authors,
            dates: dates,
            imageIds: imageIds,
            left: leftCrop,
            right: rightCrop
        )
    }
    
    // MARK: - Private Extraction Methods
    
    private static func extractTitles(from titleInfos: [[TitleInfo]]?) -> [String] {
        titleInfos?.flatMap { titleInfoArray in
            titleInfoArray.compactMap { titleInfo in
                titleInfo.title?.x_
            }
        } ?? []
    }
    
    private static func extractSubjects(from subjects: [MODSSubject]?) -> [String] {
        subjects?.compactMap { subject in
            if let topic = subject.topic?.x_ {
                return topic
            }
            if let geographic = subject.geographic?.x_ {
                return geographic
            }
            return nil
        } ?? []
    }
    
    private static func extractDates(from originInfo: [OriginInfo]?) -> [String] {
        originInfo?.compactMap { info in
            info.dateCreated?.first?.x_
        } ?? []
    }
    
    private static func extractAuthors(from mods: MODSData?) -> [String] {
        // Extract authors based on your MODS data structure
        // This would need to be implemented based on where author information is stored
        ["Unknown"]
    }
}

// MARK: - MODS Data Structures
private struct MODSRoot: Codable {
    let card: CardData?
}

private struct CardData: Codable {
    let nyplAPI: NYPLAPI?
}

private struct NYPLAPI: Codable {
    let request: RequestData?
    let response: Response?
}

private struct RequestData: Codable {
    let uuid: UUIDContainer?
    let request: Request?
    
    struct Request: Codable {
        let uuid: UUIDContainer?
        let perPage: StringContainer?
        let page: StringContainer?
        let totalPages: StringContainer?
        
        enum CodingKeys: String, CodingKey {
            case uuid
            case perPage = "perPage"
            case page
            case totalPages = "totalPages"
        }
    }
}

private struct Response: Codable {
    let headers: Headers?
    let mods: MODSData?
    let numResults: StringContainer?
    let capture: [Capture]?
}

private struct Headers: Codable {
    let status: StringContainer?
    let code: StringContainer?
    let message: StringContainer?
}

private struct MODSData: Codable {
    let version: String?
    let schemaLocation: String?
    let titleInfo: [[TitleInfo]]?
    let typeOfResource: StringContainer?
    let genre: Genre?
    let subject: [MODSSubject]?
    let originInfo: [OriginInfo]?
    let identifier: [Identifier]?
}

private struct Genre: Codable {
    let authority: String?
    let usage: String?
    let valueURI: String?
    let x_: String?
}

private struct TitleInfo: Codable {
    let supplied: String?
    let usage: String?
    let title: Title?
}

private struct Title: Codable {
    let x_: String?
}

private struct MODSSubject: Codable {
    let topic: TopicOrGeographic?
    let geographic: TopicOrGeographic?
}

private struct TopicOrGeographic: Codable {
    let authority: String?
    let x_: String?
}

private struct OriginInfo: Codable {
    let dateCreated: [DateInfo]?
}

private struct DateInfo: Codable {
    let x_: String?
    let encoding: String?
    let keyDate: String?
    let point: String?
}

private struct Identifier: Codable {
    let displayLabel: String?
    let type: String?
    let x_: String?
}

private struct Capture: Codable {
    let uuid: StringContainer
    let imageID: StringContainer
    let apiUri: StringContainer?
    let itemLink: StringContainer?
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case imageID = "imageID"
        case apiUri = "apiUri"
        case itemLink = "itemLink"
    }
}

private struct StringContainer: Codable {
    let x_: String
}

private struct UUIDContainer: Codable {
    let x_: String
}

// MARK: - Errors
enum MODSError: LocalizedError {
    case invalidMODSData
    case missingRequiredField(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidMODSData:
            return "Invalid MODS data format"
        case .missingRequiredField(let field):
            return "Missing required field: \(field)"
        }
    }
}
