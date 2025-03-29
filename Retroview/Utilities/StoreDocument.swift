//
//  StoreDocument.swift
//  Retroview
//
//  Created by Adam Schuster on 12/23/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct StoreDocument: FileDocument {
    var storeURL: URL?
    
    static var readableContentTypes: [UTType] { [.retroviewStore] }
    
    init(storeURL: URL?) {
        self.storeURL = storeURL
    }
    
    init(configuration: ReadConfiguration) throws {
        storeURL = nil
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let storeURL else {
            throw StoreTransferManager.TransferError.storeNotFound
        }
        
        do {
            return try FileWrapper(url: storeURL)
        } catch {
            throw StoreTransferManager.TransferError.transferFailed(error.localizedDescription)
        }
    }
}
