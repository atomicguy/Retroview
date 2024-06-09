//
//  StereoCardData.swift
//  Retroview
//
//  Created by Adam Schuster on 5/27/24.
//

import Foundation

struct StereoCardData: Codable {
    var uuid: String
    var imageFrontId: String?
    var imageBackId: String?
    var titles: [String]
    var authors: [String]
    var subjects: [String]
    var dates: [String]
}
