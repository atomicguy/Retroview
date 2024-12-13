//
//  MODSResponseContent.swift
//  Retroview
//
//  Created by Adam Schuster on 12/11/24.
//

import Foundation

struct MODSResponseContent: Codable {
    let mods: MODSContent
    let capture: [[MODSCapture]]
    
    struct MODSCapture: Codable {
        let imageID: XMLText
        let rightsStatement: XMLText
    }
}
