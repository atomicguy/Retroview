# Typed Throws Implementation

## Summary

This document describes the implementation of Swift's typed throws feature across the Retroview codebase, providing better error handling with compile-time type safety.

## Overview

Swift 6.0 introduced typed throws, allowing functions to specify exactly which error types they can throw. This provides several benefits:

1. **Type Safety**: Compiler verifies error handling at compile time
2. **Better Documentation**: Function signatures clearly show possible errors
3. **Improved Error Context**: Rich error types with contextual information
4. **Exhaustive Handling**: Can pattern match on specific error types

## Changes Made

### 1. New Error Type System (`TypedErrors.swift`)

Created a comprehensive, domain-specific error type system:

#### **ImageLoadError**
Errors during image loading operations:
- `invalidImageData`: Corrupted or invalid image data
- `networkFailure`: Network issues during download
- `cacheFailure`: Cache read/write failures
- `swiftDataAccessFailure`: Database access issues
- `missingImageURL`: Missing image metadata
- `dataProviderCreationFailed`: CGImage data provider errors
- `cgImageCreationFailed`: CGImage creation failures

#### **ImportError**
Errors during card import operations:
- `fileReadFailure`: File system read errors
- `jsonDecodingFailure`: JSON parsing errors
- `modsParsingFailure`: MODS format parsing errors
- `cardAlreadyExists`: Duplicate card detection
- `invalidCardData`: Invalid card structure
- `swiftDataInsertFailure`: Database insert errors
- `swiftDataSaveFailure`: Database save errors
- `swiftDataFetchFailure`: Database fetch errors
- `batchProcessingFailure`: Batch operation errors
- `importCancelled`: User-cancelled operations
- `noJsonFiles`: Empty directory detection

**Skippable Errors**: Certain errors (like `cardAlreadyExists`, `noJsonFiles`) are marked as skippable, allowing batch operations to continue.

#### **MODSParsingError**
Errors specific to MODS XML/JSON parsing:
- `invalidJSON`: Malformed JSON structure
- `missingRequiredField`: Missing required metadata fields
- `invalidUUID`: Invalid UUID format
- `invalidImageIdentifier`: Missing/invalid image IDs
- `invalidCropData`: Invalid crop coordinates
- `jsonSerializationFailure`: JSON serialization errors

#### **ImageDownloadError**
Errors during batch image downloads:
- `noCardsNeedDownload`: No work to perform
- `swiftDataFetchFailure`: Database fetch errors
- `downloadCancelled`: User cancellation
- `preloadFailure`: Image preload errors
- `batchFetchFailure`: Batch fetch errors

#### **StoreArchiveError**
Errors for store import/export:
- `zipCreationFailure`: ZIP archive creation errors
- `zipExtractionFailure`: ZIP extraction errors
- `storeFileNotFound`: Missing store files
- `invalidArchiveStructure`: Malformed archives
- `fileSystemFailure`: File system operations
- `tempDirectoryCreationFailure`: Temp directory errors
- `storeImportFailure`: Store import errors

#### **SpatialPhotoError**
Errors for spatial photo processing:
- `missingImageData`: Missing source data
- `invalidImageFormat`: Unsupported formats
- `heifConversionFailure`: HEIF conversion errors
- `metadataWriteFailure`: Metadata writing errors
- `unsupportedImageFormat`: Format not supported
- `cropDataMissing`: Missing crop information
- `temporaryFileCreationFailure`: Temp file errors

#### **CropUpdateError**
Errors for crop data updates:
- `cardNotFound`: Card doesn't exist
- `invalidCropData`: Invalid crop coordinates
- `swiftDataSaveFailure`: Save operation errors

### 2. Updated Services

#### **CardImageLoader.swift**
```swift
// Before
func loadImage(...) async throws -> CGImage?

// After
func loadImage(...) async throws(ImageLoadError) -> CGImage?
```

**Benefits**:
- Clear documentation of possible failures
- Contextual error information (card UUID, side, quality)
- Distinguishes between network, cache, and data errors

#### **ImportService.swift**
```swift
// Before
func importJSON(from url: URL) async throws
func importCard(from cardData: StereoCardJSON) async throws

// After
func importJSON(from url: URL) async throws(ImportError)
func importCard(from cardData: StereoCardJSON) async throws(ImportError)
```

**Benefits**:
- File-level error context
- Skippable vs. fatal error distinction
- Better batch operation error handling

#### **BackgroundImportManager.swift**
```swift
// Before
private func importFiles(from urls: [URL]) async throws

// After
private func importFiles(from urls: [URL]) async throws(ImportError)
```

**Benefits**:
- Graceful handling of skippable errors
- Continue processing on recoverable failures
- Better progress tracking with error categorization

#### **ImageDownloadManager.swift**
```swift
// Before
private func processBatch(...) async throws

// After
private func processBatch(...) async throws(ImageDownloadError)
```

**Benefits**:
- Clear cancellation handling
- Batch-level error recovery
- Better progress reporting

#### **MODSParsingService.swift**
```swift
// Before
static func convertMODSToStereoCard(...) throws -> StereoCardJSON
private static func extractUUID(...) throws -> UUID
private static func extractImageIDs(...) -> ImageIDs

// After
static func convertMODSToStereoCard(...) throws(MODSParsingError) -> StereoCardJSON
private static func extractUUID(...) throws(MODSParsingError) -> UUID
private static func extractImageIDs(...) throws(MODSParsingError) -> ImageIDs
```

**Benefits**:
- File-level context in all errors
- Validates required fields explicitly
- Better error messages for debugging

### 3. Error Handling Patterns

#### **Pattern 1: Error Type Conversion**
```swift
do {
    let data = try Data(contentsOf: url)
} catch {
    throw ImageLoadError.networkFailure(
        cardUUID: card.uuid,
        underlyingError: error.localizedDescription
    )
}
```

#### **Pattern 2: Skippable Error Handling**
```swift
do {
    try await importService.importJSON(from: fileURL)
} catch let error as ImportError where error.isSkippable {
    logger.warning("Skipped: \(error.localizedDescription)")
    continue  // Keep processing
} catch {
    throw error  // Fatal error, stop processing
}
```

#### **Pattern 3: Error Context Enrichment**
```swift
guard let uuid = UUID(uuidString: uuidString) else {
    throw MODSParsingError.invalidUUID(
        fileName: fileName,
        uuidString: uuidString
    )
}
```

## Benefits Realized

### 1. **Type Safety**
- Compiler enforces error handling
- No silent error swallowing
- Exhaustive error matching possible

### 2. **Better Debugging**
- Rich contextual information in errors
- File names, UUIDs, offsets included
- Clear error categorization

### 3. **Improved User Experience**
- Graceful degradation for skippable errors
- Better error messages with recovery suggestions
- Progress tracking continues through minor errors

### 4. **Code Maintainability**
- Self-documenting error handling
- Clear error ownership per domain
- Easier to add new error cases

## Migration Guide

### For New Code

```swift
// Define your error type
enum MyError: Error, LocalizedError {
    case somethingWentWrong(reason: String)

    var errorDescription: String? {
        switch self {
        case .somethingWentWrong(let reason):
            return "Something went wrong: \(reason)"
        }
    }
}

// Use typed throws
func myFunction() throws(MyError) {
    throw MyError.somethingWentWrong(reason: "Because")
}
```

### For Callers

```swift
// Specific error handling
do {
    try imageLoader.loadImage(...)
} catch let error as ImageLoadError {
    switch error {
    case .networkFailure:
        // Show retry UI
    case .cacheFailure:
        // Clear cache
    default:
        // Generic error handling
    }
}

// Or simple catch
do {
    try imageLoader.loadImage(...)
} catch {
    print(error.localizedDescription)
}
```

## Future Improvements

1. **Add Result<Success, Failure> types** for non-throwing APIs
2. **Implement retry logic** for network errors
3. **Add telemetry** for error tracking
4. **Create error recovery strategies** for common failures
5. **Enhance error messages** with actionable suggestions

## Compatibility

- **Swift Version**: Requires Swift 6.0+
- **Platforms**: iOS 16+, macOS 13+, visionOS 1.0+
- **Backward Compatibility**: None - typed throws is a Swift 6.0 feature

## Testing Considerations

When testing functions with typed throws:

```swift
func testImageLoader() async throws {
    do {
        _ = try await imageLoader.loadImage(for: card, side: .front, quality: .thumbnail)
    } catch let error as ImageLoadError {
        // Test specific error handling
        XCTAssertEqual(error, .networkFailure(...))
    }
}
```

## Conclusion

The implementation of typed throws across Retroview provides:
- ✅ Better type safety
- ✅ Improved error context
- ✅ Clearer error handling patterns
- ✅ More maintainable code
- ✅ Better user experience with graceful error recovery

This modernization aligns with Swift's direction toward more explicit, type-safe error handling.
