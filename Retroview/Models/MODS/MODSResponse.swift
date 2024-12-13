//
//  MODSResponse.swift
//  Retroview
//
//  Created by Adam Schuster on 12/11/24.
//

import Foundation

struct MODSResponse: Codable {
    let card: MODSCard
}

struct MODSCard: Codable {
    let nyplAPI: NYPLAPI
}

struct NYPLAPI: Codable {
    let response: MODSResponseContent
}
