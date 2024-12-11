//
//  AppError.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import Foundation
import SwiftUI

import Foundation
import SwiftUI

enum AppError: LocalizedError, Equatable {
    // Data Errors
    case modelContextMissing
    case saveFailed(Error)
    case fetchFailed(Error)
    case importFailed(Error)
    case invalidData(String)
    
    // Image Errors
    case imageLoadFailed(String)
    case imageSaveFailed(String)
    case imageProcessingFailed
    case invalidImageFormat
    case imageDownloadFailed
    
    // Network Errors
    case networkError(Error)
    case invalidURL
    case serverError(Int)
    case responseError(String)
    
    // File System Errors
    case fileNotFound(String)
    case fileAccessDenied(String)
    case fileOperationFailed(Error)
    
    var errorDescription: String? {
        switch self {
        // Data Errors
        case .modelContextMissing:
            return "Database context is unavailable"
        case .saveFailed(let error):
            return "Failed to save data: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to fetch data: \(error.localizedDescription)"
        case .importFailed(let error):
            return "Import operation failed: \(error.localizedDescription)"
        case .invalidData(let details):
            return "Invalid data format: \(details)"
            
        // Image Errors
        case .imageLoadFailed(let imageId):
            return "Failed to load image: \(imageId)"
        case .imageSaveFailed(let imageId):
            return "Failed to save image: \(imageId)"
        case .imageProcessingFailed:
            return "Failed to process image"
        case .invalidImageFormat:
            return "Invalid image format"
        case .imageDownloadFailed:
            return "Failed to download image"
            
        // Network Errors
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidURL:
            return "Invalid URL"
        case .serverError(let code):
            return "Server error: \(code)"
        case .responseError(let message):
            return "Server response error: \(message)"
            
        // File System Errors
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .fileAccessDenied(let path):
            return "Access denied to file: \(path)"
        case .fileOperationFailed(let error):
            return "File operation failed: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .modelContextMissing:
            return "Try restarting the application"
        case .networkError:
            return "Check your internet connection and try again"
        case .fileNotFound, .fileAccessDenied:
            return "Verify the file exists and you have proper permissions"
        default:
            return "Try the operation again"
        }
    }
    
    // MARK: - Equatable Conformance
    static func == (lhs: AppError, rhs: AppError) -> Bool {
        switch (lhs, rhs) {
        case (.modelContextMissing, .modelContextMissing):
            return true
        case (.saveFailed(let lhsError), .saveFailed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.fetchFailed(let lhsError), .fetchFailed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.importFailed(let lhsError), .importFailed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.invalidData(let lhs), .invalidData(let rhs)):
            return lhs == rhs
        case (.imageLoadFailed(let lhs), .imageLoadFailed(let rhs)):
            return lhs == rhs
        case (.imageSaveFailed(let lhs), .imageSaveFailed(let rhs)):
            return lhs == rhs
        case (.imageProcessingFailed, .imageProcessingFailed):
            return true
        case (.invalidImageFormat, .invalidImageFormat):
            return true
        case (.imageDownloadFailed, .imageDownloadFailed):
            return true
        case (.networkError(let lhsError), .networkError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.invalidURL, .invalidURL):
            return true
        case (.serverError(let lhs), .serverError(let rhs)):
            return lhs == rhs
        case (.responseError(let lhs), .responseError(let rhs)):
            return lhs == rhs
        case (.fileNotFound(let lhs), .fileNotFound(let rhs)):
            return lhs == rhs
        case (.fileAccessDenied(let lhs), .fileAccessDenied(let rhs)):
            return lhs == rhs
        case (.fileOperationFailed(let lhsError), .fileOperationFailed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

// MARK: - Error Alert
struct ErrorAlert: Identifiable {
    let id = UUID()
    let error: AppError
    var title: String {
        "Error"
    }
    var message: String {
        if let recovery = error.recoverySuggestion {
            return "\(error.localizedDescription)\n\n\(recovery)"
        }
        return error.localizedDescription
    }
}

// MARK: - View Extension for Error Handling
extension View {
    func handleError(_ error: Binding<AppError?>, retryAction: (() -> Void)? = nil) -> some View {
        let errorAlert = Binding<ErrorAlert?>(
            get: { error.wrappedValue.map { ErrorAlert(error: $0) } },
            set: { _ in error.wrappedValue = nil }
        )
        
        return alert(item: errorAlert) { alert in
            if let retryAction = retryAction {
                Alert(
                    title: Text(alert.title),
                    message: Text(alert.message),
                    primaryButton: .default(Text("Retry"), action: retryAction),
                    secondaryButton: .cancel(Text("OK"))
                )
            } else {
                Alert(
                    title: Text(alert.title),
                    message: Text(alert.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}
