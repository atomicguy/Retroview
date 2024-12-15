//
//  ImportLogger.swift
//  Retroview
//
//  Created by Adam Schuster on 12/14/24.
//

import Foundation

struct ImportLogger {
    enum LogLevel: Int {
        case error
        case warning
        case info
        case debug
        
        var symbol: String {
            switch self {
            case .error: "❌"
            case .warning: "⚠️"
            case .info: "ℹ️"
            case .debug: "🔍"
            }
        }
    }
    
    private static var currentLogLevel: LogLevel = .error
    private static var failedImports: [String: String] = [:]
    
    static func configure(logLevel: LogLevel) {
        currentLogLevel = logLevel
    }
    
    static func log(_ level: LogLevel, _ message: String, file: String? = nil) {
        guard level.rawValue <= currentLogLevel.rawValue else { return }
        
        if level == .error {
            let identifier = file ?? "Unknown File"
            failedImports[identifier] = message
        }
        
        #if DEBUG
        print("\(level.symbol) \(message)")
        #endif
    }
    
    static func getFailedImports() -> [(file: String, error: String)] {
        failedImports.map { ($0.key, $0.value) }
    }
    
    static func clearFailedImports() {
        failedImports.removeAll()
    }
}

struct ImportReport {
    let totalProcessed: Int
    let successCount: Int
    let failedImports: [(file: String, error: String)]
    
    var failureCount: Int { failedImports.count }
    var successRate: Double {
        guard totalProcessed > 0 else { return 0 }
        return Double(successCount) / Double(totalProcessed)
    }
}
