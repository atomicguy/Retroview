//
//  MODSParsingService.swift
//  Retroview
//
//  Created by Adam Schuster on 12/8/24.
//

import Foundation

struct MODSParsingService {
    enum MODSParsingError: LocalizedError {
        case invalidJSON(String)
        case missingRequiredField(String)
        case unexpectedDataStructure(String)

        var errorDescription: String? {
            switch self {
            case .invalidJSON(let detail):
                return "Invalid JSON format: \(detail)"
            case .missingRequiredField(let field):
                return "Missing required field: \(field)"
            case .unexpectedDataStructure(let detail):
                return "Unexpected data structure: \(detail)"
            }
        }
    }

    static func convertMODSToStereoCard(_ data: Data) throws -> StereoCardJSON {
        guard
            let dict = try? JSONSerialization.jsonObject(with: data)
                as? [String: Any],
            let cardDict = dict["card"] as? [String: Any],
            let nyplAPI = cardDict["nyplAPI"] as? [String: Any],
            let response = nyplAPI["response"] as? [String: Any],
            let mods = response["mods"] as? [String: Any]
        else {
            throw MODSParsingError.unexpectedDataStructure(
                "Invalid MODS structure")
        }

        // Extract UUID
        let uuid = try extractUUID(from: mods)

        // Extract titles
        let titles = extractTitles(from: mods)

        // Extract dates
        let dates = extractDates(from: mods)

        // Extract subjects
        let subjects = extractSubjects(from: mods)

        // Extract authors
        let authors = try extractAuthors(from: mods)

        // Extract image IDs
        let imageIds = extractImageIDs(from: response)

        // For MODS imports, we'll create placeholder crops if not provided
        let defaultCrop = CropData(
            x0: 0, y0: 0, x1: 1, y1: 1, score: 1.0, side: "left")

        let card = StereoCardJSON(
            uuid: uuid,
            titles: titles,
            subjects: subjects,
            authors: authors,
            dates: dates,
            imageIds: imageIds,
            left: defaultCrop,
            right: CropData(
                x0: 0, y0: 0, x1: 1, y1: 1, score: 1.0, side: "right")
        )

        logImportedCard(card)
        return card
    }

    private static func extractUUID(from mods: [String: Any]) throws -> String {
        guard let identifiers = mods["identifier"] as? [[Any]] else {
            throw MODSParsingError.missingRequiredField("identifiers")
        }

        guard
            let uuidIdentifier = identifiers.flatMap({ $0 })
                .first(where: {
                    ($0 as? [String: Any])?["type"] as? String == "uuid"
                }) as? [String: Any],
            let uuid = uuidIdentifier["x_"] as? String
        else {
            throw MODSParsingError.missingRequiredField("UUID")
        }

        return uuid
    }

    private static func extractTitles(from mods: [String: Any]) -> [String] {
        var titles: [String] = []

        // Handle single titleInfo
        if let titleInfo = mods["titleInfo"] as? [String: Any],
            let title = titleInfo["title"] as? [String: Any],
            let titleText = title["x_"] as? String
        {
            titles.append(titleText)
        }

        // Handle array of titleInfo arrays
        if let titleInfoArrays = mods["titleInfo"] as? [[Any]] {
            for titleInfoArray in titleInfoArrays {
                for titleInfo in titleInfoArray {
                    if let titleDict = titleInfo as? [String: Any],
                        let title = titleDict["title"] as? [String: Any],
                        let titleText = title["x_"] as? String
                    {
                        titles.append(titleText)
                    }
                }
            }
        }

        return titles.isEmpty ? ["Untitled"] : titles
    }

    private static func extractDates(from mods: [String: Any]) -> [String] {
        var dates: [String] = []

        if let originInfoArrays = mods["originInfo"] as? [[Any]] {
            for originInfoArray in originInfoArrays {
                for originInfo in originInfoArray {
                    if let originDict = originInfo as? [String: Any] {
                        // Handle single dateCreated
                        if let dateCreated = originDict["dateCreated"]
                            as? [String: Any],
                            let dateText = dateCreated["x_"] as? String
                        {
                            dates.append(dateText)
                        }

                        // Handle array of dateCreated arrays
                        if let dateCreatedArrays = originDict["dateCreated"]
                            as? [[Any]]
                        {
                            for dateArray in dateCreatedArrays {
                                for date in dateArray {
                                    if let dateDict = date as? [String: Any],
                                        let dateText = dateDict["x_"] as? String
                                    {
                                        dates.append(dateText)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        return dates
    }

    private static func extractSubjects(from mods: [String: Any]) -> [String] {
        var subjects: [String] = []

        // Extract direct subjects
        if let subjectArrays = mods["subject"] as? [[Any]] {
            for subjectArray in subjectArrays {
                for subjectData in subjectArray {
                    if let subjectDict = subjectData as? [String: Any] {
                        // Handle geographic subjects
                        if let geographic = subjectDict["geographic"]
                            as? [String: Any],
                            let name = geographic["x_"] as? String
                        {
                            subjects.append(name)
                        }

                        // Handle topic subjects
                        if let topic = subjectDict["topic"] as? [String: Any],
                            let name = topic["x_"] as? String
                        {
                            subjects.append(name)
                        }
                    }
                }
            }
        }

        // Handle single subject
        if let subject = mods["subject"] as? [String: Any],
            let geographic = subject["geographic"] as? [String: Any],
            let name = geographic["x_"] as? String
        {
            subjects.append(name)
        }

        // Extract subjects from relatedItem titles
        if let relatedItem = mods["relatedItem"] as? [String: Any] {
            extractRelatedItemSubjects(from: relatedItem, into: &subjects)
        }

        return subjects.uniqued()
    }

    private static func extractRelatedItemSubjects(
        from relatedItem: [String: Any], into subjects: inout [String]
    ) {
        // List of generic terms to exclude
        let excludedTerms = [
            "States",
            "United States",
            "United States.",
            "Robert N. Dennis collection of stereoscopic views",
        ]

        // Extract title from current relatedItem
        if let titleInfo = relatedItem["titleInfo"] as? [String: Any],
            let title = titleInfo["title"] as? [String: Any],
            let titleText = title["x_"] as? String,
            !titleText.lowercased().contains("collection"),  // Skip collection titles
            !excludedTerms.contains(titleText)
        {  // Skip generic terms
            subjects.append(titleText)
        }

        // Recursively process nested relatedItems
        if let nestedRelatedItem = relatedItem["relatedItem"] as? [String: Any]
        {
            extractRelatedItemSubjects(from: nestedRelatedItem, into: &subjects)
        }
    }

    private static func extractAuthors(from mods: [String: Any]) -> [String] {
        var authors: [String] = []

        // Try to get author from name first
        if let name = mods["name"] as? [String: Any],
            let namePart = name["namePart"] as? [String: Any],
            let authorName = namePart["x_"] as? String
        {
            authors.append(authorName)
        }

        // If no author found, try to get publisher
        if authors.isEmpty,
            let originInfo = mods["originInfo"] as? [String: Any],
            let publisher = originInfo["publisher"] as? [String: Any],
            let publisherName = publisher["x_"] as? String
        {
            authors.append(publisherName)
        }

        return authors
    }

    private static func extractImageIDs(from response: [String: Any])
        -> ImageIDs
    {
        print("\n🔍 Debug - Processing captures:")
        var frontId = ""
        var backId = ""

        if let captures = response["capture"] as? [[Any]] {
            print("Found capture arrays: \(captures.count)")

            for captureArray in captures {
                for capture in captureArray {
                    if let captureDict = capture as? [String: Any],
                        let imageIDDict = captureDict["imageID"]
                            as? [String: Any],
                        let imageID = imageIDDict["x_"] as? String
                    {
                        print("Found imageID: \(imageID)")
                        if imageID.hasSuffix("F") {
                            frontId = imageID
                            print("✓ Set as front image: \(frontId)")
                        } else if imageID.hasSuffix("B") {
                            backId = imageID
                            print("✓ Set as back image: \(backId)")
                        }
                    }
                }
            }
        }

        print("\nFinal IDs - Front: \(frontId), Back: \(backId)\n")
        return ImageIDs(front: frontId, back: backId)
    }
}

extension MODSParsingService {
    static func logImportedCard(_ card: StereoCardJSON) {
        print("\n🔍 MODS Import Summary:")
        print("━━━━━━━━━━━━━━━━━━━━━━")
        print("UUID: \(card.uuid)")

        print("\n📚 Titles (\(card.titles.count)):")
        card.titles.forEach { print("  • \($0)") }

        print("\n✍️ Authors (\(card.authors.count)):")
        card.authors.forEach { print("  • \($0)") }

        print("\n🏷️ Subjects (\(card.subjects.count)):")
        card.subjects.forEach { print("  • \($0)") }

        print("\n📅 Dates (\(card.dates.count)):")
        card.dates.forEach { print("  • \($0)") }

        print("\n🖼️ Image IDs:")
        print("  Front: \(card.imageIds.front)")
        print("  Back: \(card.imageIds.back)")
        print("━━━━━━━━━━━━━━━━━━━━━━\n")
    }
}
