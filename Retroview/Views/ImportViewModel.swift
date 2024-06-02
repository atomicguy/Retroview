//
//  ImportViewModel.swift
//  Retroview
//
//  Created by Adam Schuster on 6/1/24.
//

import SwiftUI
import SwiftData

class ImportViewModel: ObservableObject {
//    @Environment(\.modelContext) private var context
    
    func parseJSON(fromFile fileURL: URL) -> Data? {
        do {
            let data = try Data(contentsOf: fileURL)
            return data
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
                    
                    var titleObjects = [TitleSchemaV1.Title]()
                    for title in titles {
                        let titleObject = TitleSchemaV1.Title(text: title)
                        titleObjects.append(titleObject)
                    }
                    
                    var subjectObjects = [SubjectSchemaV1.Subject]()
                    for subject in subjects {
                        let subjectObject = SubjectSchemaV1.Subject(name: subject)
                        subjectObjects.append(subjectObject)
                    }
                    
                    var authorObjects = [AuthorSchemaV1.Author]()
                    for author in authors {
                        let authorObject = AuthorSchemaV1.Author(name: author)
                        authorObjects.append(authorObject)
                    }
                    
                    var dateObjects = [DateSchemaV1.Date]()
                    for date in dates {
                        let dateObject = DateSchemaV1.Date(text: date)
                        dateObjects.append(dateObject)
                    }
                    
                    let stereoCard = CardSchemaV1.StereoCard(
                        uuid: uuidString,
                        imageFrontId: frontImageId,
                        imageBackId: backImageId,
                        titles: titleObjects,
                        authors: authorObjects,
                        subjects: subjectObjects,
                        dates: dateObjects
                    )
                    
                    stereoCards.append(stereoCard)
                }
            }
        } catch {
            print("Error parsing JSON data: \(error.localizedDescription)")
        }
        return stereoCards
    }
    
    @MainActor
    func saveModelObjects(_ objects: [CardSchemaV1.StereoCard], context: ModelContext) {
            objects.forEach { object in
                context.insert(object)
            }
            do {
                try context.save()
                print("Model objects saved successfully.")
            } catch {
                print("Could not save context: \(error)")
            }
        }
    
    //    func importData(fromFile fileURL: URL) {
    //        Task {
    //            var didStartAccessing = false
    //            if fileURL.startAccessingSecurityScopedResource() {
    //                didStartAccessing = true
    //                print("Started accessing security scoped resource")
    //            } else {
    //                print("Failed to start accessing security scoped resource")
    //            }
    //            defer {
    //                if didStartAccessing {
    //                    fileURL.stopAccessingSecurityScopedResource()
    //                    print("Stopped accessing security scoped resource")
    //                }
    //            }
    //
    //            if let jsonData = parseJSON(fromFile: fileURL) {
    //                let modelObjects = createModelObjects(fromJSONData: jsonData)
    //                await saveModelObjects(modelObjects)
    //            } else {
    //                print("Failed to parse JSON data")
    //            }
    //        }
    //    }
    func importData(fromFile fileURL: URL, context: ModelContext) {
        Task {
            var didStartAccessing = false
            if fileURL.startAccessingSecurityScopedResource() {
                didStartAccessing = true
                print("Started accessing security scoped resource")
            } else {
                print("Failed to start accessing security scoped resource")
            }
            defer {
                if didStartAccessing {
                    fileURL.stopAccessingSecurityScopedResource()
                    print("Stopped accessing security scoped resource")
                }
            }
            
            do {
                let jsonData = try Data(contentsOf: fileURL)
                print("Read JSON data successfully: \(jsonData)")
                let modelObjects = createModelObjects(fromJSONData: jsonData)
                await saveModelObjects(modelObjects, context: context)
            } catch {
                print("Error reading JSON file: \(error.localizedDescription)")
            }
        }
    }
    
}
