//
//  DatabaseExportService.swift
//  Retroview
//
//  Created by Adam Schuster on 12/14/24.
//

import Foundation
import SwiftData
import Compression

actor DatabaseExportService {
    enum ExportError: LocalizedError {
        case encodingFailed(String)
        case decodingFailed(String)
        case compressionFailed
        case decompressionFailed(String)
        
        var errorDescription: String? {
            switch self {
            case .encodingFailed(let details): "Failed to encode database: \(details)"
            case .decodingFailed(let details): "Failed to decode database: \(details)"
            case .compressionFailed: "Failed to compress data"
            case .decompressionFailed(let details): "Failed to decompress data: \(details)"
            }
        }
    }
    
    func compressDataForExport(_ data: Data) async throws -> Data {
        print("🗜️ Compressing \(data.count) bytes...")
        let sourceBufferSize = data.count
        let destinationBufferSize = sourceBufferSize
        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: destinationBufferSize)
        defer { destinationBuffer.deallocate() }
        
        let compressedSize = data.withUnsafeBytes { sourceBuffer in
            guard let baseAddress = sourceBuffer.baseAddress else {
                return 0
            }
            return compression_encode_buffer(
                destinationBuffer,
                destinationBufferSize,
                baseAddress.assumingMemoryBound(to: UInt8.self),
                sourceBufferSize,
                nil,
                COMPRESSION_LZFSE
            )
        }
        
        guard compressedSize > 0 else {
            print("❌ Compression failed!")
            throw ExportError.compressionFailed
        }
        
        print("✅ Compressed to \(compressedSize) bytes")
        return Data(bytes: destinationBuffer, count: compressedSize)
    }
    
    func decompressDataForImport(_ data: Data) async throws -> Data {
        print("🗜️ Decompressing \(data.count) bytes...")
        let sourceBufferSize = data.count
        // Increase the multiplier since our compression ratio is higher than 4x
        let destinationBufferSize = sourceBufferSize * 10  // Increased from 4 to 10
        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: destinationBufferSize)
        defer { destinationBuffer.deallocate() }
        
        let decompressedSize = data.withUnsafeBytes { sourceBuffer in
            guard let baseAddress = sourceBuffer.baseAddress else {
                return 0
            }
            return compression_decode_buffer(
                destinationBuffer,
                destinationBufferSize,
                baseAddress.assumingMemoryBound(to: UInt8.self),
                sourceBufferSize,
                nil,
                COMPRESSION_LZFSE
            )
        }
        
        guard decompressedSize > 0 else {
            print("❌ Decompression failed!")
            throw ExportError.decompressionFailed("Decompression returned size: \(decompressedSize)")
        }
        
        let decompressedData = Data(bytes: destinationBuffer, count: decompressedSize)
        
        // Verify we can parse as JSON
        if let _ = try? JSONSerialization.jsonObject(with: decompressedData) {
            print("✅ Decompressed data is valid JSON of size \(decompressedSize) bytes")
        } else {
            print("⚠️ Decompressed data is not valid JSON!")
            if let str = String(data: decompressedData, encoding: .utf8) {
                print("📃 First 200 characters:", String(str.prefix(200)))
            }
            throw ExportError.decompressionFailed("Decompressed data is not valid JSON")
        }
        
        print("✅ Decompressed to \(decompressedSize) bytes")
        return decompressedData
    }
}
