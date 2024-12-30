//
//  StereoCard+TempFiles.swift
//  Retroview
//
//  Created by Adam Schuster on 12/29/24.
//

import Foundation

extension CardSchemaV1.StereoCard {
    func writeToTemporary(data: Data) -> URL? {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(uuid.uuidString)
            .appendingPathExtension("heic")
        
        try? data.write(to: url)
        return url
    }
}
