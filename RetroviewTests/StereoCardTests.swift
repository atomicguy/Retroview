////
////  StereoCardTests.swift
////  Retroview
////
////  Created by Adam Schuster on 12/8/24.
////
//
//import SwiftData
//import XCTest
//@testable import Retroview
//
//final class StereoCardTests: XCTestCase {
//    var context: ModelContext!
//    
//    override func setUp() {
//        super.setUp()
//        let config = ModelConfiguration(isStoredInMemoryOnly: true)
//        let container = try! ModelContainer(for: StereoCard.self, configurations: config)
//        context = ModelContext(container)
//    }
//    
//    override func tearDown() {
//        context = nil
//        super.tearDown()
//    }
//    
//    // Helper function for comparing optional Float values with accuracy
//    private func assertFloatEqual(_ value: Float?, _ expected: Double, accuracy: Double, file: StaticString = #file, line: UInt = #line) {
//        guard let value = value else {
//            XCTFail("Value is nil", file: file, line: line)
//            return
//        }
//        XCTAssertEqual(Double(value), expected, accuracy: accuracy, file: file, line: line)
//    }
//    
//    func testJewelryWorkerCard() throws {
//        // Test data from jewelry workers card
//        let cardJSON = StereoCardJSON(
//            uuid: "0a3eccb0-c56b-012f-54cb-58d385a7bc34",
//            titles: ["Skilled workers manufacturing jewelry, Providence, R.I."],
//            subjects: ["Jewelry making", "Rhode Island", "Providence (R.I.)"],
//            authors: ["Keystone View Company"],
//            dates: ["1915"],
//            imageIds: ImageIDs(front: "G92F015_061F", back: "G92F015_061B"),
//            left: CropData(x0: 0.055484414, y0: 0.084824219, x1: 0.86062962, y1: 0.49424398, score: 0.99993718, side: "left"),
//            right: CropData(x0: 0.057971686, y0: 0.49507505, x1: 0.85982335, y1: 0.90457469, score: 0.99961507, side: "right")
//        )
//        
//        // Create card
//        let card = StereoCard(uuid: UUID(uuidString: cardJSON.uuid)!)
//        card.titles = cardJSON.titles
//        card.imageFrontId = cardJSON.imageIds.front
//        card.imageBackId = cardJSON.imageIds.back
//        
//        // Add authors
//        for authorName in cardJSON.authors {
//            let author = Author(name: authorName)
//            author.cards.append(card)
//            card.authors.append(author)
//        }
//        
//        // Add subjects
//        for subjectName in cardJSON.subjects {
//            let subject = Subject(name: subjectName)
//            subject.cards.append(card)
//            card.subjects.append(subject)
//        }
//        
//        // Add crops
//        let leftCrop = StereoCrop(
//            x0: cardJSON.left.x0,
//            y0: cardJSON.left.y0,
//            x1: cardJSON.left.x1,
//            y1: cardJSON.left.y1,
//            score: cardJSON.left.score,
//            side: .left
//        )
//        
//        let rightCrop = StereoCrop(
//            x0: cardJSON.right.x0,
//            y0: cardJSON.right.y0,
//            x1: cardJSON.right.x1,
//            y1: cardJSON.right.y1,
//            score: cardJSON.right.score,
//            side: .right
//        )
//        
//        card.crops = [leftCrop, rightCrop]
//        
//        // Save to context
//        context.insert(card)
//        try context.save()
//        
//        // Fetch and verify
//        let descriptor = FetchDescriptor<StereoCard>(
//            predicate: #Predicate<StereoCard> { card in
//                card.uuid == UUID(uuidString: cardJSON.uuid)!
//            }
//        )
//        
//        let fetchedCard = try context.fetch(descriptor).first
//        XCTAssertNotNil(fetchedCard)
//        
//        // Verify properties
//        XCTAssertEqual(fetchedCard?.titles.first, "Skilled workers manufacturing jewelry, Providence, R.I.")
//        XCTAssertEqual(fetchedCard?.imageFrontId, "G92F015_061F")
//        XCTAssertEqual(fetchedCard?.imageBackId, "G92F015_061B")
//        
//        // Verify relationships
//        XCTAssertEqual(fetchedCard?.authors.count, 1)
//        XCTAssertEqual(fetchedCard?.authors.first?.name, "Keystone View Company")
//        
//        XCTAssertEqual(fetchedCard?.subjects.count, 3)
//        XCTAssertTrue(fetchedCard?.subjects.map { $0.name }.contains("Jewelry making") ?? false)
//        
//        // Verify crops
//        XCTAssertEqual(fetchedCard?.crops.count, 2)
//        XCTAssertNotNil(fetchedCard?.leftCrop)
//        XCTAssertNotNil(fetchedCard?.rightCrop)
//        
//        // Verify crop data using helper function
//        assertFloatEqual(fetchedCard?.leftCrop?.x0, 0.055484414, accuracy: 0.0001)
//        assertFloatEqual(fetchedCard?.leftCrop?.y0, 0.084824219, accuracy: 0.0001)
//        assertFloatEqual(fetchedCard?.leftCrop?.x1, 0.86062962, accuracy: 0.0001)
//        assertFloatEqual(fetchedCard?.leftCrop?.y1, 0.49424398, accuracy: 0.0001)
//        
//        assertFloatEqual(fetchedCard?.rightCrop?.x0, 0.057971686, accuracy: 0.0001)
//        assertFloatEqual(fetchedCard?.rightCrop?.y0, 0.49507505, accuracy: 0.0001)
//        assertFloatEqual(fetchedCard?.rightCrop?.x1, 0.85982335, accuracy: 0.0001)
//        assertFloatEqual(fetchedCard?.rightCrop?.y1, 0.90457469, accuracy: 0.0001)
//    }
//}
