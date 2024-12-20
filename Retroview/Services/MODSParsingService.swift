//
//  MODSParsingService.swift
//  Retroview
//
//  Created by Adam Schuster on 12/8/24.
//

import Foundation

actor MODSParsingService {
    enum MODSParsingError: LocalizedError {
        case invalidJSON(String)
        case missingRequiredField(String)
        case unexpectedDataStructure(String)
        case processingError(String)

        var errorDescription: String? {
            switch self {
            case .invalidJSON(let detail):
                return "Invalid JSON format: \(detail)"
            case .missingRequiredField(let field):
                return "Missing required field: \(field)"
            case .unexpectedDataStructure(let detail):
                return "Unexpected data structure: \(detail)"
            case .processingError(let detail):
                return "Processing error: \(detail)"
            }
        }
    }

    static func convertMODSToStereoCard(_ data: Data, fileName: String? = nil) throws -> StereoCardJSON {
        do {
            ImportLogger.log(.debug, "Starting MODS parsing...", file: fileName)
            
            let cleanedData = try preprocessJSONData(data)
            guard let dict = try JSONSerialization.jsonObject(with: cleanedData) as? [String: Any] else {
                ImportLogger.log(.error, "Failed to parse JSON", file: fileName)
                throw MODSParsingError.invalidJSON("Could not parse as dictionary")
            }
            
            guard let cardDict = dict["card"] as? [String: Any] else {
                ImportLogger.log(.error, "Missing card object", file: fileName)
                throw MODSParsingError.unexpectedDataStructure("Missing card object")
            }
            
            guard let nyplAPI = cardDict["nyplAPI"] as? [String: Any] else {
                print("❌ Missing nyplAPI object")
                throw MODSParsingError.unexpectedDataStructure("Missing nyplAPI object")
            }
            
            guard let response = nyplAPI["response"] as? [String: Any] else {
                print("❌ Missing response object")
                throw MODSParsingError.unexpectedDataStructure("Missing response object")
            }
            
            guard let mods = response["mods"] as? [String: Any] else {
                print("❌ Missing mods object")
                print("Response keys available: \(response.keys)")
                throw MODSParsingError.unexpectedDataStructure("Missing mods object")
            }
            
            // Extract all required fields
            let uuid = try extractUUID(from: mods)
            let titles = extractTitles(from: mods)
            let dates = extractDates(from: mods)
            let subjects = extractSubjects(from: mods)
            let authors = extractAuthors(from: mods)
            let imageIds = extractImageIDs(from: response)
            
            // Create and return the card
            let card = StereoCardJSON(
                uuid: uuid.uuidString,
                titles: titles,
                subjects: subjects,
                authors: authors,
                dates: dates,
                imageIds: imageIds,
                left: CropData(x0: 0, y0: 0, x1: 1, y1: 1, score: 1.0, side: "left"),
                right: CropData(x0: 0, y0: 0, x1: 1, y1: 1, score: 1.0, side: "right")
            )
            
            // Log successful parsing
            logImportedCard(card)
            
            return card
        } catch {
            ImportLogger.log(.error, "Failed to import: \(error.localizedDescription)", file: fileName)
                    throw error
        }
    }

    private static func extractUUID(from mods: [String: Any]) throws -> UUID {
        guard let identifiers = mods["identifier"] as? [[Any]] else {
            throw MODSParsingError.missingRequiredField("identifiers")
        }

        guard
            let uuidIdentifier = identifiers.flatMap({ $0 })
                .first(where: {
                    ($0 as? [String: Any])?["type"] as? String == "uuid"
                }) as? [String: Any],
            let uuidString = uuidIdentifier["x_"] as? String,
            let uuid = UUID(uuidString: uuidString)
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

        if let originInfo = mods["originInfo"] as? [String: Any] {
            // Handle single dateCreated
            if let dateCreated = originInfo["dateCreated"] as? [String: Any],
                let dateText = dateCreated["x_"] as? String
            {
                // Split on comma if multiple dates are present
                dates.append(contentsOf: dateText.components(separatedBy: ", "))
            }

            // Handle array of dateCreated
            if let dateCreatedArrays = originInfo["dateCreated"] as? [[Any]] {
                for dateArray in dateCreatedArrays {
                    for date in dateArray {
                        if let dateDict = date as? [String: Any],
                            let dateText = dateDict["x_"] as? String
                        {
                            dates.append(
                                contentsOf: dateText.components(
                                    separatedBy: ", "))
                        }
                    }
                }
            }
        }

        return dates.filter { !$0.isEmpty }
    }

    private static func extractSubjects(from mods: [String: Any]) -> [String] {
        var subjects: [String] = []

        // Handle single subject array
        if let subjectArray = mods["subject"] as? [[Any]] {
            for subjectData in subjectArray {
                for subject in subjectData {
                    if let subjectDict = subject as? [String: Any] {
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
        if let subject = mods["subject"] as? [String: Any] {
            if let geographic = subject["geographic"] as? [String: Any],
                let name = geographic["x_"] as? String
            {
                subjects.append(name)
            }
            if let topic = subject["topic"] as? [String: Any],
                let name = topic["x_"] as? String
            {
                subjects.append(name)
            }
        }

        return subjects.normalizedUnique()
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

extension MODSParsingService {
    static func debugConvertMODSToStereoCard(_ data: Data) throws
        -> StereoCardJSON
    {
        // Try parsing JSON
        guard
            let dict = try? JSONSerialization.jsonObject(with: data)
                as? [String: Any]
        else {
            throw MODSParsingError.unexpectedDataStructure(
                "Failed to parse initial JSON")
        }

        // Check for card
        guard let cardDict = dict["card"] as? [String: Any] else {
            throw MODSParsingError.unexpectedDataStructure(
                "Missing or invalid 'card' object in JSON: \(dict.keys)")
        }

        // Check for nyplAPI
        guard let nyplAPI = cardDict["nyplAPI"] as? [String: Any] else {
            throw MODSParsingError.unexpectedDataStructure(
                "Missing or invalid 'nyplAPI' in card: \(cardDict.keys)")
        }

        // Check for response
        guard let response = nyplAPI["response"] as? [String: Any] else {
            throw MODSParsingError.unexpectedDataStructure(
                "Missing or invalid 'response' in nyplAPI: \(nyplAPI.keys)")
        }

        // Check for mods
        guard let mods = response["mods"] as? [String: Any] else {
            throw MODSParsingError.unexpectedDataStructure(
                "Missing or invalid 'mods' in response: \(response.keys)")
        }

        // Continue with existing parsing logic...
        let uuid = try extractUUID(from: mods)
        let titles = extractTitles(from: mods)
        let dates = extractDates(from: mods)
        let subjects = extractSubjects(from: mods)
        let authors = extractAuthors(from: mods)
        let imageIds = extractImageIDs(from: response)

        // Log the structure at each level
        print("\n🔍 Debug - Document Structure:")
        print("Root keys: \(dict.keys)")
        print("Card keys: \(cardDict.keys)")
        print("NYPL API keys: \(nyplAPI.keys)")
        print("Response keys: \(response.keys)")
        print("MODS keys: \(mods.keys)")

        let defaultCrop = CropData(
            x0: 0, y0: 0, x1: 1, y1: 1, score: 1.0, side: "left")
        
        return StereoCardJSON(
            uuid: uuid.uuidString,
            titles: titles,
            subjects: subjects,
            authors: authors,
            dates: dates,
            imageIds: imageIds,
            left: defaultCrop,
            right: CropData(
                x0: 0, y0: 0, x1: 1, y1: 1, score: 1.0, side: "right")
        )
    }
}

extension MODSParsingService {
    private static func preprocessJSONData(_ data: Data) throws -> Data {
        // Try different encodings in order of likelihood
        let encodings: [String.Encoding] = [
            .utf8,
            .ascii,
            .isoLatin1,
            .utf16LittleEndian,
            .utf16BigEndian
        ]
        
        var lastError: Error? = nil
        
        for encoding in encodings {
            if let jsonString = String(data: data, encoding: encoding) {
                print("🧹 Successfully decoded JSON with \(encoding) encoding")
                
                // First pass: clean any raw control characters from the entire string
                var cleanedString = jsonString
                    .components(separatedBy: .controlCharacters)
                    .joined(separator: " ")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Remove any BOM (Byte Order Mark) if present
                if cleanedString.hasPrefix("\u{FEFF}") {
                    cleanedString = String(cleanedString.dropFirst())
                }
                
                // Second pass: find and clean all string values in JSON
                let pattern = ": ?\"[^\"]+\""  // Matches :"value" or : "value"
                if let regex = try? NSRegularExpression(pattern: pattern) {
                    let nsString = NSString(string: cleanedString)
                    let matches = regex.matches(in: cleanedString, range: NSRange(location: 0, length: nsString.length))
                    
                    // Process matches in reverse to not invalidate ranges
                    for match in matches.reversed() {
                        let range = match.range
                        let stringValue = nsString.substring(with: range)
                        
                        // Clean the string value
                        var cleaned = stringValue
                            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
                            .replacingOccurrences(of: "\t", with: "\\t")
                            .replacingOccurrences(of: "\r", with: "\\r")
                            .replacingOccurrences(of: "\n", with: "\\n")
                            .trimmingCharacters(in: .whitespaces)
                        
                        // Ensure it starts with :" and ends with "
                        if cleaned.hasPrefix(":") {
                            cleaned = ":" + cleaned.dropFirst().trimmingCharacters(in: .whitespaces)
                        }
                        if !cleaned.hasSuffix("\"") {
                            cleaned += "\""
                        }
                        
                        cleanedString = (cleanedString as NSString).replacingCharacters(in: range, with: cleaned)
                    }
                }
                
                // Verify the cleaned string can be converted back to data
                if let cleanedData = cleanedString.data(using: .utf8) {
                    // Verify it's valid JSON
                    do {
                        _ = try JSONSerialization.jsonObject(with: cleanedData)
                        print("✅ Successfully preprocessed and validated JSON")
                        return cleanedData
                    } catch {
                        print("⚠️ Cleaned data failed JSON validation: \(error)")
                        lastError = error
                        continue
                    }
                }
            }
        }
        
        throw MODSParsingError.invalidJSON("""
            Could not process JSON with any known encoding. \
            Last error: \(lastError?.localizedDescription ?? "Unknown")
            """
        )
    }
}
