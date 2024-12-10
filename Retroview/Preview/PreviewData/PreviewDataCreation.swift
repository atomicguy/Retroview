//
//  PreviewDataCreation.swift
//  Retroview
//
//  Created by Adam Schuster on 12/7/24.
//

import SwiftData
import SwiftUI

// MARK: - Sample Data Creation
extension PreviewDataManager {
    func createTitles(context: ModelContext) -> [TitleSchemaV1.Title] {
        let titles = [
            "Dart's Camp, 1917.",
            "Lake view with canoe.",
            "Brooklyn Bridge, W.N.W. [west-northwest] from Brooklyn toward Manhattan, New York City.",
            "Brooklyn Bridge, looking from Brooklyn towards New York, U.S.A.",
            "No.20355",
            "Loading oil on steamers at Port Arthur, Texas, U.S.A..",
        ].map { TitleSchemaV1.Title(text: $0) }

        titles.forEach { context.insert($0) }
        return titles
    }

    func createAuthors(context: ModelContext) -> [AuthorSchemaV1.Author] {
        let authors = [
            "Keystone View Company",
            "Unknown",
            "Strohmeyer & Wyman",
            "Underwood & Underwood",
            "E. & H.T. Anthony (Firm)",
            "Graves, Jesse A. (Jesse Albert)",
        ].map { AuthorSchemaV1.Author(name: $0) }

        authors.forEach { context.insert($0) }
        return authors
    }

    func createSubjects(context: ModelContext) -> [SubjectSchemaV1.Subject] {
        let subjects = [
            "Jewelry making",
            "Rhode Island",
            "Providence (R.I.)",
            "Colorado",
            "Pennsylvania",
            "Lakes & ponds",
            "New York (State)",
            "Florida",
            "Canoes",
            "Adirondack Mountains (N.Y.)",
            "Rivers",
            "Ontario",
            "Niagara Falls (N.Y. and Ont.)",
            "Niagara River (N.Y. and Ont.)",
            "Waterfalls",
            "California",
            "East River (N.Y.)",
            "Brooklyn Bridge (New York, N.Y.)",
            "Bridges",
            "Bridge construction",
            "New York (N.Y.)",
            "Ships",
            "Petroleum industry",
            "Port Arthur (Tex.)",
            "Texas",
        ].map { SubjectSchemaV1.Subject(name: $0) }

        subjects.forEach { context.insert($0) }
        return subjects
    }

    func createDates(context: ModelContext) -> [DateSchemaV1.Date] {
        let dates = [
            "1915",
            "Unknown",
            "1917",
        ].map { DateSchemaV1.Date(text: $0) }

        dates.forEach { context.insert($0) }
        return dates
    }

    func createSampleCards(
        context: ModelContext,
        titles: [TitleSchemaV1.Title],
        authors: [AuthorSchemaV1.Author],
        subjects: [SubjectSchemaV1.Subject],
        dates: [DateSchemaV1.Date]
    ) async throws {
        let imageService = await ImageServiceFactory.shared.getService()
        let cardData:
            [(
                uuid: String, imageData: ImageIDs, titles: [String],
                authors: [String], subjects: [String], dates: [String],
                left: CropData, right: CropData
            )] = [
                // Card 1
                (
                    uuid: "0a3eccb0-c56b-012f-54cb-58d385a7bc34",
                    imageData: ImageIDs(
                        front: "G92F015_061F", back: "G92F015_061B"),
                    titles: [],
                    authors: ["Keystone View Company"],
                    subjects: [
                        "Jewelry making", "Rhode Island", "Providence (R.I.)",
                    ],
                    dates: ["1915"],
                    left: CropData(
                        x0: 0.05548441410064697, y0: 0.08482421934604645,
                        x1: 0.8606296181678772, y1: 0.4942439794540405,
                        score: 0.9999371767044067, side: "left"),
                    right: CropData(
                        x0: 0.057971686124801636, y0: 0.4950750470161438,
                        x1: 0.8598233461380005, y1: 0.9045746922492981,
                        score: 0.9996150732040405, side: "right")
                ),
                // Card 2
                (
                    uuid: "0af956f0-c535-012f-9ad6-58d385a7bc34",
                    imageData: ImageIDs(
                        front: "G90F029_007F", back: "G90F029_007B"),
                    titles: [],
                    authors: ["Unknown"],
                    subjects: ["Colorado"],
                    dates: ["Unknown"],
                    left: CropData(
                        x0: 0.043078988790512085, y0: 0.0884842574596405,
                        x1: 0.8736530542373657, y1: 0.4949319660663605,
                        score: 0.9996930360794067, side: "left"),
                    right: CropData(
                        x0: 0.042485564947128296, y0: 0.49728691577911377,
                        x1: 0.8615659475326538, y1: 0.9027869701385498,
                        score: 0.9993634819984436, side: "right")
                ),
                // Card 3
                (
                    uuid: "00b07f30-c566-012f-b573-58d385a7bc34",
                    imageData: ImageIDs(
                        front: "G91F333_034ZF", back: "G91F333_034ZB"),
                    titles: [],
                    authors: ["Graves, Jesse A. (Jesse Albert)"],
                    subjects: ["Pennsylvania"],
                    dates: ["Unknown"],
                    left: CropData(
                        x0: 0.04694324731826782, y0: 0.06721986830234528,
                        x1: 0.926945686340332, y1: 0.49705541133880615,
                        score: 0.9999631643295288, side: "left"),
                    right: CropData(
                        x0: 0.05367878079414368, y0: 0.5034565925598145,
                        x1: 0.9270590543746948, y1: 0.9383574724197388,
                        score: 0.9997246861457825, side: "right")
                ),
                // Card 4
                (
                    uuid: "0b4092f0-c553-012f-f8cf-58d385a7bc34",
                    imageData: ImageIDs(
                        front: "G91F081_032F", back: "G91F081_032B"),
                    titles: ["Dart's Camp, 1917.", "Lake view with canoe."],
                    authors: ["Unknown"],
                    subjects: [
                        "Lakes & ponds", "New York (State)", "Florida",
                        "Canoes", "Adirondack Mountains (N.Y.)",
                    ],
                    dates: ["1917"],
                    left: CropData(
                        x0: 0.07259517908096313, y0: 0.07843181490898132,
                        x1: 0.9272833466529846, y1: 0.49938538670539856,
                        score: 0.9989068508148193, side: "left"),
                    right: CropData(
                        x0: 0.07578766345977783, y0: 0.5009486079216003,
                        x1: 0.9220581650733948, y1: 0.9130609631538391,
                        score: 0.9994638562202454, side: "right")
                ),
                // Card 5
                (
                    uuid: "0c9c85e0-c55f-012f-c487-58d385a7bc34",
                    imageData: ImageIDs(
                        front: "G90F413_019F", back: "G90F413_019B"),
                    titles: [],
                    authors: ["E. & H.T. Anthony (Firm)"],
                    subjects: [
                        "Rivers", "Ontario", "Niagara Falls (N.Y. and Ont.)",
                        "Niagara River (N.Y. and Ont.)", "New York (State)",
                        "Waterfalls",
                    ],
                    dates: ["Unknown"],
                    left: CropData(
                        x0: 0.048793286085128784, y0: 0.06744231283664703,
                        x1: 0.9338785409927368, y1: 0.4978821277618408,
                        score: 0.999405026435852, side: "left"),
                    right: CropData(
                        x0: 0.05150383710861206, y0: 0.4968760907649994,
                        x1: 0.9308846592903137, y1: 0.9211989641189575,
                        score: 0.997821569442749, side: "right")
                ),
                // Card 6
                (
                    uuid: "d03b8e40-c533-012f-6725-58d385a7bc34",
                    imageData: ImageIDs(
                        front: "G89F397_006F", back: "G89F397_006B"),
                    titles: [],
                    authors: ["Strohmeyer & Wyman"],
                    subjects: ["California"],
                    dates: ["Unknown"],
                    left: CropData(
                        x0: 0.04703962802886963, y0: 0.07102151215076447,
                        x1: 0.8919011354446411, y1: 0.4888046979904175,
                        score: 0.9998213648796082, side: "left"),
                    right: CropData(
                        x0: 0.05011674761772156, y0: 0.49648311734199524,
                        x1: 0.888075590133667, y1: 0.9062751531600952,
                        score: 0.9991828799247742, side: "right")
                ),
                // Card 7
                (
                    uuid: "d4ee31f0-c555-012f-9f73-58d385a7bc34",
                    imageData: ImageIDs(
                        front: "G91F173_160F", back: "G91F173_160B"),
                    titles: [
                        "Brooklyn Bridge, W.N.W. [west-northwest] from Brooklyn toward Manhattan, New York City.",
                        "Brooklyn Bridge, looking from Brooklyn towards New York, U.S.A.",
                    ],
                    authors: ["Underwood & Underwood"],
                    subjects: [
                        "East River (N.Y.)",
                        "Brooklyn Bridge (New York, N.Y.)",
                        "Bridges",
                        "Bridge construction",
                        "New York (N.Y.)",
                        "New York (State)",
                    ],
                    dates: ["Unknown"],
                    left: CropData(
                        x0: 0.034334540367126465, y0: 0.077060267329216,
                        x1: 0.8711702227592468, y1: 0.4934043288230896,
                        score: 0.9999160766601562, side: "left"),
                    right: CropData(
                        x0: 0.036974966526031494, y0: 0.4951510429382324,
                        x1: 0.8669135570526123, y1: 0.9134384393692017,
                        score: 0.9992889165878296, side: "right")
                ),
                // Card 8
                (
                    uuid: "d6b30460-c56b-012f-8902-58d385a7bc34",
                    imageData: ImageIDs(
                        front: "G92F037_030F", back: "G92F037_030B"),
                    titles: [
                        "No.20355",
                        "Loading oil on steamers at Port Arthur, Texas, U.S.A..",
                    ],
                    authors: ["Keystone View Company"],
                    subjects: [
                        "Ships", "Petroleum industry", "Port Arthur (Tex.)",
                        "Texas",
                    ],
                    dates: ["Unknown"],
                    left: CropData(
                        x0: 0.051812171936035156, y0: 0.08490397036075592,
                        x1: 0.8785728812217712, y1: 0.499218225479126,
                        score: 0.9998064637184143, side: "left"),
                    right: CropData(
                        x0: 0.03611642122268677, y0: 0.5019264817237854,
                        x1: 0.8759056329727173, y1: 0.9139134287834167,
                        score: 0.9987524747848511, side: "right")
                ),
                // Card 9
                (
                    uuid: "d44eedd0-c546-012f-d184-58d385a7bc34",
                    imageData: ImageIDs(
                        front: "G90F273_028F", back: "G90F273_028B"),
                    titles: [],
                    authors: ["Reed, S. C."],
                    subjects: ["Massachusetts"],
                    dates: ["Unknown"],
                    left: CropData(
                        x0: 0.04616621136665344, y0: 0.06395715475082397,
                        x1: 0.9254530668258667, y1: 0.4960116744041443,
                        score: 0.9996169805526733, side: "left"),
                    right: CropData(
                        x0: 0.04371833801269531, y0: 0.5024446249008179,
                        x1: 0.9304686784744263, y1: 0.930732011795044,
                        score: 0.9991338849067688, side: "right")
                ),
            ]

        for data in cardData {
            // Create card with basic info
            let card = CardSchemaV1.StereoCard(
                uuid: data.uuid,
                imageFrontId: data.imageData.front,
                imageBackId: data.imageData.back
            )

            // Create and set crops
            let leftCrop = CropSchemaV1.Crop(
                x0: data.left.x0,
                y0: data.left.y0,
                x1: data.left.x1,
                y1: data.left.y1,
                score: data.left.score,
                side: data.left.side
            )

            let rightCrop = CropSchemaV1.Crop(
                x0: data.right.x0,
                y0: data.right.y0,
                x1: data.right.x1,
                y1: data.right.y1,
                score: data.right.score,
                side: data.right.side
            )

            card.leftCrop = leftCrop
            card.rightCrop = rightCrop

            // Set relationships
            card.titles = data.titles.compactMap { titleText in
                if let existingTitle = titles.first(where: {
                    $0.text == titleText
                }) {
                    return existingTitle
                } else {
                    let newTitle = TitleSchemaV1.Title(text: titleText)
                    context.insert(newTitle)
                    return newTitle
                }
            }

            card.titlePick = card.titles.first

            card.authors = data.authors.compactMap { authorName in
                if let existingAuthor = authors.first(where: {
                    $0.name == authorName
                }) {
                    return existingAuthor
                } else {
                    let newAuthor = AuthorSchemaV1.Author(name: authorName)
                    context.insert(newAuthor)
                    return newAuthor
                }
            }

            card.subjects = data.subjects.compactMap { subjectName in
                if let existingSubject = subjects.first(where: {
                    $0.name == subjectName
                }) {
                    return existingSubject
                } else {
                    let newSubject = SubjectSchemaV1.Subject(name: subjectName)
                    context.insert(newSubject)
                    return newSubject
                }
            }

            card.dates = data.dates.compactMap { dateText in
                if let existingDate = dates.first(where: { $0.text == dateText }
                ) {
                    return existingDate
                } else {
                    let newDate = DateSchemaV1.Date(text: dateText)
                    context.insert(newDate)
                    return newDate
                }
            }

            // Download and store images using ImageService
            if let frontId = card.imageFrontId {
                if let frontImage = try? await imageService.loadImage(id: frontId, side: .front),
                   let imageData = ImageConversion.convert(cgImage: frontImage) {
                    card.imageFront = imageData
                }
            }

            if let backId = card.imageBackId {
                if let backImage = try? await imageService.loadImage(id: backId, side: .back),
                   let imageData = ImageConversion.convert(cgImage: backImage) {
                    card.imageBack = imageData
                }
            }

            context.insert(card)
        }
    }
}

func createCollections(context: ModelContext) {
    let collections = [
        "Favorites",
        "World's Fair",
        "New York City",
        "Natural Wonders",
    ].map { CollectionSchemaV1.Collection(name: $0) }

    collections.forEach { context.insert($0) }

    // Fetch all cards and add them to relevant collections
    let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
    guard let cards = try? context.fetch(descriptor) else { return }

    for card in cards {
        let subjectNames = card.subjects.map { $0.name }

        if subjectNames.contains("Wyoming")
            || subjectNames.contains("National parks & reserves")
        {
            collections[3].addCard(card)  // Natural Wonders
        }
        if subjectNames.contains("Illinois") {
            collections[1].addCard(card)  // World's Fair
        }
    }
}
