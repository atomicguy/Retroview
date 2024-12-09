////
////  MODSDateTests.swift
////  Retroview
////
////  Created by Adam Schuster on 12/8/24.
////
//
//import SwiftData
//import XCTest
//@testable import Retroview
//
//final class MODSDateTests: XCTestCase {
//    var context: ModelContext!
//    
//    override func setUp() {
//        super.setUp()
//        let config = ModelConfiguration(isStoredInMemoryOnly: true)
//        let container = try! ModelContainer(for: MODSDate.self, configurations: config)
//        context = ModelContext(container)
//    }
//    
//    override func tearDown() {
//        context = nil
//        super.tearDown()
//    }
//    
//    func testDateParsing() {
//        // Test simple year
//        let simpleDate = MODSDate(text: "1915")
//        XCTAssertEqual(simpleDate.year, 1915)
//        XCTAssertNil(simpleDate.month)
//        XCTAssertNil(simpleDate.day)
//        
//        // Test approximate date from Jewelry workers card
//        let approximateDate = MODSDate(text: "1915")
//        approximateDate.qualifier = .approximate
//        XCTAssertTrue(approximateDate.isApproximate)
//        
//        // Test date range from Lake view card
//        let startDate = MODSDate(text: "1915")
//        startDate.point = .start
//        let endDate = MODSDate(text: "1919")
//        endDate.point = .end
//        
//        XCTAssertTrue(startDate.isDateRange)
//        XCTAssertTrue(endDate.isDateRange)
//        XCTAssertTrue(startDate < endDate)
//    }
//    
//    func testDateFormats() {
//        let date = MODSDate(text: "1915")
//        
//        // Test different format styles
//        XCTAssertEqual(date.formatted(style: .standard), "1915")
//        
//        // Test date comparison
//        let earlier = MODSDate(text: "1914")
//        let later = MODSDate(text: "1916")
//        
//        XCTAssertTrue(earlier < later)
//        XCTAssertTrue(earlier < date)
//        XCTAssertTrue(date < later)
//    }
//    
//    func testDateValidation() {
//        // Test valid date
//        let validDate = MODSDate(text: "1915")
//        XCTAssertNoThrow(try validDate.validate())
//        
//        // Test invalid date
//        let invalidDate = MODSDate(text: "")
//        invalidDate.year = nil
//        XCTAssertThrowsError(try invalidDate.validate())
//    }
//}
