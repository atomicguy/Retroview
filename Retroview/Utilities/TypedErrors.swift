//
//  TypedErrors.swift
//  Retroview
//
//  Created by Claude on 10/31/25.
//

import Foundation
import SwiftData

// MARK: - Image Loading Errors

/// Errors that can occur during image loading operations
enum ImageLoadError: Error, LocalizedError, Equatable {
    case invalidImageData(cardUUID: UUID, side: String, quality: String)
    case networkFailure(cardUUID: UUID, underlyingError: String)
    case cacheFailure(key: String, reason: String)
    case swiftDataAccessFailure(cardUUID: UUID)
    case missingImageURL(cardUUID: UUID, side: String)
    case dataProviderCreationFailed(cardUUID: UUID)
    case cgImageCreationFailed(cardUUID: UUID)

    var errorDescription: String? {
        switch self {
        case .invalidImageData(let uuid, let side, let quality):
            return "Invalid image data for card \(uuid.uuidString) (side: \(side), quality: \(quality))"
        case .networkFailure(let uuid, let error):
            return "Network failure loading image for card \(uuid.uuidString): \(error)"
        case .cacheFailure(let key, let reason):
            return "Cache failure for key \(key): \(reason)"
        case .swiftDataAccessFailure(let uuid):
            return "Failed to access SwiftData for card \(uuid.uuidString)"
        case .missingImageURL(let uuid, let side):
            return "Missing image URL for card \(uuid.uuidString) side \(side)"
        case .dataProviderCreationFailed(let uuid):
            return "Failed to create data provider for card \(uuid.uuidString)"
        case .cgImageCreationFailed(let uuid):
            return "Failed to create CGImage for card \(uuid.uuidString)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .invalidImageData, .dataProviderCreationFailed, .cgImageCreationFailed:
            return "The image data may be corrupted. Try re-downloading the image."
        case .networkFailure:
            return "Check your internet connection and try again."
        case .cacheFailure:
            return "Try clearing the cache and reloading."
        case .swiftDataAccessFailure:
            return "There may be a database issue. Try restarting the app."
        case .missingImageURL:
            return "The card may be missing image metadata."
        }
    }
}

// MARK: - Import Errors

/// Errors that can occur during import operations
enum ImportError: Error, LocalizedError, Equatable {
    case fileReadFailure(url: String, reason: String)
    case jsonDecodingFailure(url: String, reason: String)
    case modsParsingFailure(url: String, reason: String)
    case cardAlreadyExists(uuid: String)
    case invalidCardData(url: String, reason: String)
    case swiftDataInsertFailure(uuid: String, reason: String)
    case swiftDataSaveFailure(reason: String)
    case swiftDataFetchFailure(reason: String)
    case batchProcessingFailure(batchIndex: Int, reason: String)
    case importCancelled
    case noJsonFiles(directory: String)

    var errorDescription: String? {
        switch self {
        case .fileReadFailure(let url, let reason):
            return "Failed to read file \(url): \(reason)"
        case .jsonDecodingFailure(let url, let reason):
            return "Failed to decode JSON from \(url): \(reason)"
        case .modsParsingFailure(let url, let reason):
            return "Failed to parse MODS data from \(url): \(reason)"
        case .cardAlreadyExists(let uuid):
            return "Card \(uuid) already exists in the database"
        case .invalidCardData(let url, let reason):
            return "Invalid card data in \(url): \(reason)"
        case .swiftDataInsertFailure(let uuid, let reason):
            return "Failed to insert card \(uuid): \(reason)"
        case .swiftDataSaveFailure(let reason):
            return "Failed to save to database: \(reason)"
        case .swiftDataFetchFailure(let reason):
            return "Failed to fetch from database: \(reason)"
        case .batchProcessingFailure(let index, let reason):
            return "Batch \(index) processing failed: \(reason)"
        case .importCancelled:
            return "Import operation was cancelled"
        case .noJsonFiles(let directory):
            return "No JSON files found in directory \(directory)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .fileReadFailure:
            return "Ensure the file exists and you have permission to read it."
        case .jsonDecodingFailure, .modsParsingFailure:
            return "The file format may be invalid. Verify the file structure."
        case .cardAlreadyExists:
            return "This is informational - the card was skipped."
        case .invalidCardData:
            return "Check the file contents and ensure it matches the expected format."
        case .swiftDataInsertFailure, .swiftDataSaveFailure, .swiftDataFetchFailure:
            return "There may be a database issue. Try restarting the app."
        case .batchProcessingFailure:
            return "Some items in this batch failed. Check individual file errors."
        case .importCancelled:
            return "You can restart the import if needed."
        case .noJsonFiles:
            return "Ensure the directory contains valid JSON files."
        }
    }

    var isSkippable: Bool {
        switch self {
        case .cardAlreadyExists, .invalidCardData, .fileReadFailure, .jsonDecodingFailure, .modsParsingFailure, .noJsonFiles:
            return true
        case .swiftDataInsertFailure, .swiftDataSaveFailure, .swiftDataFetchFailure, .batchProcessingFailure, .importCancelled:
            return false
        }
    }
}

// MARK: - MODS Parsing Errors

/// Errors specific to MODS XML parsing
enum MODSParsingError: Error, LocalizedError, Equatable {
    case invalidJSON(fileName: String, reason: String)
    case missingRequiredField(fileName: String, field: String)
    case invalidUUID(fileName: String, uuidString: String)
    case invalidImageIdentifier(fileName: String)
    case invalidCropData(fileName: String, reason: String)
    case jsonSerializationFailure(fileName: String, reason: String)

    var errorDescription: String? {
        switch self {
        case .invalidJSON(let fileName, let reason):
            return "Invalid JSON in \(fileName): \(reason)"
        case .missingRequiredField(let fileName, let field):
            return "Missing required field '\(field)' in \(fileName)"
        case .invalidUUID(let fileName, let uuidString):
            return "Invalid UUID '\(uuidString)' in \(fileName)"
        case .invalidImageIdentifier(let fileName):
            return "Invalid or missing image identifier in \(fileName)"
        case .invalidCropData(let fileName, let reason):
            return "Invalid crop data in \(fileName): \(reason)"
        case .jsonSerializationFailure(let fileName, let reason):
            return "JSON serialization failed for \(fileName): \(reason)"
        }
    }
}

// MARK: - Image Download Errors

/// Errors that can occur during batch image download operations
enum ImageDownloadError: Error, LocalizedError {
    case noCardsNeedDownload
    case swiftDataFetchFailure(reason: String)
    case downloadCancelled
    case preloadFailure(cardUUID: UUID, reason: String)
    case batchFetchFailure(offset: Int, reason: String)

    var errorDescription: String? {
        switch self {
        case .noCardsNeedDownload:
            return "No cards need thumbnail downloads"
        case .swiftDataFetchFailure(let reason):
            return "Failed to fetch cards from database: \(reason)"
        case .downloadCancelled:
            return "Image download was cancelled"
        case .preloadFailure(let uuid, let reason):
            return "Failed to preload images for card \(uuid.uuidString): \(reason)"
        case .batchFetchFailure(let offset, let reason):
            return "Failed to fetch batch at offset \(offset): \(reason)"
        }
    }
}

// MARK: - Store Archive Errors

/// Errors related to store file import/export operations
enum StoreArchiveError: Error, LocalizedError {
    case zipCreationFailure(reason: String)
    case zipExtractionFailure(url: String, reason: String)
    case storeFileNotFound(url: String)
    case invalidArchiveStructure(reason: String)
    case fileSystemFailure(operation: String, reason: String)
    case tempDirectoryCreationFailure
    case storeImportFailure(reason: String)

    var errorDescription: String? {
        switch self {
        case .zipCreationFailure(let reason):
            return "Failed to create ZIP archive: \(reason)"
        case .zipExtractionFailure(let url, let reason):
            return "Failed to extract archive from \(url): \(reason)"
        case .storeFileNotFound(let url):
            return "Store file not found at \(url)"
        case .invalidArchiveStructure(let reason):
            return "Invalid archive structure: \(reason)"
        case .fileSystemFailure(let operation, let reason):
            return "File system operation '\(operation)' failed: \(reason)"
        case .tempDirectoryCreationFailure:
            return "Failed to create temporary directory"
        case .storeImportFailure(let reason):
            return "Failed to import store: \(reason)"
        }
    }
}

// MARK: - Spatial Photo Errors

/// Errors related to spatial photo conversion and processing
enum SpatialPhotoError: Error, LocalizedError {
    case missingImageData(cardUUID: UUID)
    case invalidImageFormat(cardUUID: UUID)
    case heifConversionFailure(cardUUID: UUID, reason: String)
    case metadataWriteFailure(cardUUID: UUID, reason: String)
    case unsupportedImageFormat(format: String)
    case cropDataMissing(cardUUID: UUID)
    case temporaryFileCreationFailure(cardUUID: UUID)

    var errorDescription: String? {
        switch self {
        case .missingImageData(let uuid):
            return "Missing image data for card \(uuid.uuidString)"
        case .invalidImageFormat(let uuid):
            return "Invalid image format for card \(uuid.uuidString)"
        case .heifConversionFailure(let uuid, let reason):
            return "HEIF conversion failed for card \(uuid.uuidString): \(reason)"
        case .metadataWriteFailure(let uuid, let reason):
            return "Failed to write metadata for card \(uuid.uuidString): \(reason)"
        case .unsupportedImageFormat(let format):
            return "Unsupported image format: \(format)"
        case .cropDataMissing(let uuid):
            return "Crop data missing for card \(uuid.uuidString)"
        case .temporaryFileCreationFailure(let uuid):
            return "Failed to create temporary file for card \(uuid.uuidString)"
        }
    }
}

// MARK: - Crop Update Errors

/// Errors that can occur during crop data updates
enum CropUpdateError: Error, LocalizedError {
    case cardNotFound(uuid: UUID)
    case invalidCropData(cardUUID: UUID, reason: String)
    case swiftDataSaveFailure(cardUUID: UUID, reason: String)

    var errorDescription: String? {
        switch self {
        case .cardNotFound(let uuid):
            return "Card \(uuid.uuidString) not found"
        case .invalidCropData(let uuid, let reason):
            return "Invalid crop data for card \(uuid.uuidString): \(reason)"
        case .swiftDataSaveFailure(let uuid, let reason):
            return "Failed to save crop data for card \(uuid.uuidString): \(reason)"
        }
    }
}

// MARK: - Helper Extensions

extension Error {
    /// Converts any error to a user-friendly description
    var userFriendlyDescription: String {
        if let localizedError = self as? LocalizedError {
            return localizedError.errorDescription ?? localizedDescription
        }
        return localizedDescription
    }

    /// Gets recovery suggestion if available
    var recoverySuggestion: String? {
        (self as? LocalizedError)?.recoverySuggestion
    }
}
