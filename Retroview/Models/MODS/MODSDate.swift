//
//  MODSDate.swift
//  Retroview
//
//  Created by Adam Schuster on 12/8/24.
//

import SwiftData
import Foundation

enum DateQualifier: String, Codable {
    case approximate
    case inferred
    case questionable
}

enum DateEncoding: String, Codable {
    case w3cdtf
    case iso8601
    case marc
    case temper
    case edtf
}

enum DatePoint: String, Codable {
    case start
    case end
}

// Custom format style enum to replace DateFormatStyle
enum MODSDateFormat {
    case standard
    case abbreviated
    case full
    
    func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        switch self {
        case .standard:
            formatter.dateStyle = .medium
        case .abbreviated:
            formatter.dateStyle = .short
        case .full:
            formatter.dateStyle = .full
        }
        return formatter.string(from: date)
    }
}

@Model
final class MODSDate {
    // Original text representation
    var text: String
    
    // Optional structured data if we can parse it
    var year: Int?
    var month: Int?
    var day: Int?
    
    // MODS specific metadata
    var qualifier: DateQualifier?
    var encoding: DateEncoding?
    var point: DatePoint?
    
    // Relationship
    @Relationship(deleteRule: .nullify, inverse: \StereoCard.modsDates)
    var cards: [StereoCard]
    
    init(text: String) {
        self.text = text
        self.cards = []
        parseDate()
    }
    
    private func parseDate() {
        // Basic year parsing - extend this as needed
        if let yearInt = Int(text) {
            self.year = yearInt
        } else if text.count >= 4,
                  let yearInt = Int(String(text.prefix(4))) {
            self.year = yearInt
        }
    }
    
    var asDate: Date? {
        guard let year = year else { return nil }
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components)
    }
    
    var isDateRange: Bool {
        point != nil
    }
}

// Helper for working with date ranges
struct MODSDateRange {
    let start: MODSDate
    let end: MODSDate
}

extension StereoCard {
    var modsDateRanges: [MODSDateRange] {
        let startDates = modsDates.filter { $0.point == .start }
        return startDates.compactMap { startDate in
            guard let endDate = modsDates.first(where: { $0.point == .end }) else {
                return nil
            }
            return MODSDateRange(start: startDate, end: endDate)
        }
    }
    
    var modsSingleDates: [MODSDate] {
        modsDates.filter { $0.point == nil }
    }
}

extension MODSDate {
    func formatted(style: MODSDateFormat) -> String {
        if let date = asDate {
            return style.format(date)
        }
        return text
    }
    
    func validate() throws {
        // Add validation logic here
        // For example:
        guard year != nil || !text.isEmpty else {
            throw DateError.invalidDate
        }
    }
    
    enum DateError: Error {
        case invalidDate
    }
    
    var isApproximate: Bool {
        qualifier == .approximate
    }
}

extension MODSDate: Comparable {
    static func < (lhs: MODSDate, rhs: MODSDate) -> Bool {
        // First compare years if available
        if let lhsYear = lhs.year, let rhsYear = rhs.year {
            if lhsYear != rhsYear {
                return lhsYear < rhsYear
            }
            
            // If years are equal, compare months if available
            if let lhsMonth = lhs.month, let rhsMonth = rhs.month {
                if lhsMonth != rhsMonth {
                    return lhsMonth < rhsMonth
                }
                
                // If months are equal, compare days if available
                if let lhsDay = lhs.day, let rhsDay = rhs.day {
                    return lhsDay < rhsDay
                }
            }
        }
        
        // Fall back to text comparison if structured comparison isn't possible
        return lhs.text < rhs.text
    }
}


