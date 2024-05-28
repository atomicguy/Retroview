//
//  main.swift
//  CardLoader
//
//  Created by Adam Schuster on 5/27/24.
//

import Foundation
import SwiftData

func parseJSON(fromFile file: String) -> Data? {
    do {
        if let path = Bundle.main.path(forResource: file, ofType: "json") {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            return data
        }
    } catch {
        print("Error reading JSON file: \(error.localizedDescription)")
    }
    return nil
}

func createModelObjects(fromJSONData jsonData: Data) -> [CardSchemaV1.StereoCard] {
    var stereoCards = [CardSchemaV1.StereoCard]()
    do {
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
        if let jsonDict = jsonObject as? [String: Any] {
            if let uuidString = jsonDict["uuid"] as? String,
               let titles = jsonDict["titles"] as? [String],
               let subjects = jsonDict["subjects"] as? [String],
               let authors = jsonDict["authors"] as? [String],
               let dates = jsonDict["dates"] as? [String],
               let imageIds = jsonDict["image_ids"] as? [String: String],
               let frontImageId = imageIds["front"],
               let backImageId = imageIds["back"] {
                
                let stereoCard = CardSchemaV1.StereoCard(
                    uuid: uuidString,
                    imageFrontId: frontImageId,
                    imageBackId: backImageId
                )
                
                for title in titles {
                    let titleObject = TitleSchemaV1.Title(text: title)
                    stereoCard.titles.append(titleObject)
                }
                
                for subject in subjects {
                    let subjectObject = SubjectSchemaV1.Subject(name: subject)
                    stereoCard.subjects.append(subjectObject)
                }
                
                for author in authors {
                    let authorObject = AuthorSchemaV1.Author(name: author)
                    stereoCard.authors.append(authorObject)
                }
                
                for date in dates {
                    let dateObject = DateSchemaV1.Date(text: date)
                    stereoCard.dates.append(dateObject)
                }
                
                stereoCards.append(stereoCard)
            }
        }
    } catch {
        print("Error parsing JSON data: \(error.localizedDescription)")
    }
    return stereoCards
}

@MainActor
func saveModelObjects(_ objects: [CardSchemaV1.StereoCard]) {
    let modelContainer: ModelContainer
    
    var context: ModelContext {
        modelContainer.mainContext
    }
    
    let schema = Schema([CardSchemaV1.StereoCard.self, TitleSchemaV1.Title.self, AuthorSchemaV1.Author.self, SubjectSchemaV1.Subject.self, DateSchemaV1.Date.self])
    
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    
    do {
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        objects.forEach { object in
            context.insert(object)
        }
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}

@MainActor
func main() {
    if let jsonData = parseJSON(fromFile: "your_json_file_name") {
        let modelObjects = createModelObjects(fromJSONData: jsonData)
        saveModelObjects(modelObjects)
    }
}


