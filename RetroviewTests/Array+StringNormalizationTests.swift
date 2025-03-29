//
//  Array+StringNormalizationTests.swift
//  RetroviewTests
//
//  Created by Adam Schuster on 12/14/24.
//

import XCTest
@testable import Retroview

final class ArrayStringNormalizationTests: XCTestCase {
    func testBasicNormalization() {
        let input = ["Colorado.", "colorado", " Colorado", "Colorado "]
        let expected = ["Colorado"]
        XCTAssertEqual(input.normalizedUnique(), expected)
    }
    
    func testPreservesWords() {
        let input = ["New York", "Florida", "Canoes", "People"]
        let expected = ["New York", "Florida", "Canoes", "People"]
        XCTAssertEqual(input.normalizedUnique(), expected)
    }
    
    func testHandlesParentheses() {
        let input = ["Building (Front)", "Building (Side)", "Building (Front)."]
        let expected = ["Building (Front)", "Building (Side)"]
        XCTAssertEqual(input.normalizedUnique(), expected)
    }
    
    func testMixedCaseAndPunctuation() {
        let input = [
            "New York.",
            "NEW YORK",
            "new york",
            "Colorado (West).",
            "Colorado (West)",
            "Mountains, Rocky"
        ]
        let expected = [
            "New York",
            "Colorado (West)",
            "Mountains, Rocky"
        ]
        XCTAssertEqual(input.normalizedUnique(), expected)
    }
    
    func testPreservesFirstOccurrence() {
        // Tests that we keep the first occurrence when dealing with duplicates
        let input = ["Arizona.", "ARIZONA", "Arizona", "arizona"]
        let expected = ["Arizona"]
        XCTAssertEqual(input.normalizedUnique(), expected)
    }
    
    func testHandlesWhitespace() {
        let input = [
            "  New Mexico  ",
            "New Mexico.",
            "New    Mexico",
            "New\tMexico"
        ]
        let expected = ["New Mexico"]
        XCTAssertEqual(input.normalizedUnique(), expected)
    }
    
    func testEmptyAndNilCases() {
        // Test empty array
        XCTAssertEqual([String]().normalizedUnique(), [])
        
        // Test array with empty strings and whitespace
        let input = ["", " ", "\n", "\t", "  "]
        let expected = [""]
        XCTAssertEqual(input.normalizedUnique(), expected)
    }
    
    func testComprehensiveExample() {
        let input = [
            "Colorado.",
            "colorado",
            "New York.",
            "NEW YORK",
            "Florida",
            "FLORIDA.",
            "Canoes",
            "Building (Front).",
            "Building (Front)",
            "Rocky Mountains.",
            "rocky mountains",
            "  Santa Fe  ",
            "Santa Fe.",
            "People (Group).",
            "people (group)"
        ]
        
        let expected = [
            "Colorado",
            "New York",
            "Florida",
            "Canoes",
            "Building (Front)",
            "Rocky Mountains",
            "Santa Fe",
            "People (Group)"
        ]
        
        XCTAssertEqual(input.normalizedUnique(), expected)
    }
}
