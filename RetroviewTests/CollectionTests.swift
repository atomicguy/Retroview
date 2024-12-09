////
////  CollectionTests.swift
////  Retroview
////
////  Created by Adam Schuster on 12/8/24.
////
//
//import SwiftData
//import XCTest
//@testable import Retroview
//
//final class CollectionTests: XCTestCase {
//    var context: ModelContext!
//    
//    override func setUp() {
//        super.setUp()
//        let config = ModelConfiguration(isStoredInMemoryOnly: true)
//        let container = try! ModelContainer(for: Collection.self, configurations: config)
//        context = ModelContext(container)
//    }
//    
//    override func tearDown() {
//        context = nil
//        super.tearDown()
//    }
//    
//    func testCollectionManagement() throws {
//        // Create a collection
//        let collection = Collection(name: "Test Collection")
//        context.insert(collection)
//        
//        // Create some test cards using real data
//        let card1 = StereoCard(
//            uuid: UUID(uuidString: "0a3eccb0-c56b-012f-54cb-58d385a7bc34")!,
//            imageFrontId: "G92F015_061F",
//            imageBackId: "G92F015_061B",
//            titles: ["Skilled workers manufacturing jewelry, Providence, R.I."]
//        )
//        
//        let card2 = StereoCard(
//            uuid: UUID(uuidString: "0af956f0-c535-012f-9ad6-58d385a7bc34")!,
//            imageFrontId: "G90F029_007F",
//            imageBackId: "G90F029_007B",
//            titles: ["Durango and mountains, Colorado."]
//        )
//        
//        context.insert(card1)
//        context.insert(card2)
//        
//        // Test adding cards
//        collection.addCard(card1)
//        XCTAssertEqual(collection.cards.count, 1)
//        XCTAssertTrue(collection.cards.contains(card1))
//        
//        // Test adding duplicate card (should be prevented)
//        collection.addCard(card1)
//        XCTAssertEqual(collection.cards.count, 1)
//        
//        // Test adding second card
//        collection.addCard(card2)
//        XCTAssertEqual(collection.cards.count, 2)
//        
//        // Test removing card
//        collection.removeCard(card1)
//        XCTAssertEqual(collection.cards.count, 1)
//        XCTAssertFalse(collection.cards.contains(card1))
//        XCTAssertTrue(collection.cards.contains(card2))
//        
//        // Verify timestamps
//        XCTAssertNotNil(collection.createdAt)
//        XCTAssertNotNil(collection.updatedAt)
//        XCTAssertGreaterThan(collection.updatedAt, collection.createdAt)
//        
//        // Save and verify persistence
//        try context.save()
//        
//        let descriptor = FetchDescriptor<Collection>(
//            predicate: #Predicate<Collection> { $0.name == "Test Collection" }
//        )
//        
//        let fetchedCollection = try context.fetch(descriptor).first
//        XCTAssertNotNil(fetchedCollection)
//        XCTAssertEqual(fetchedCollection?.cards.count, 1)
//    }
//}
