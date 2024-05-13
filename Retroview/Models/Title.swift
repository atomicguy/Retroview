//
//  Titles.swift
//  Retroview
//
//  Created by Adam Schuster on 4/20/24.
//

import Foundation
import SwiftData

enum TitleSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1,0,0)
    
    static var models: [any PersistentModel.Type] {
        [TitleSchemaV1.Title.self, CardSchemaV1.StereoCard.self]
    }
    
    @Model
    class Title {
        var text: String
        var cards = [CardSchemaV1.StereoCard]()
        
        init(
            text: String
        ) {
            self.text = text
        }
        
        static let sampleData = [
            Title(text: "Bird's-eye view, Columbian Exposition."),
            Title(text: "Stereoscopic views of the World's Columbian Exposition. 7972."),
            Title(text: "Stereoscopic views of the World's Columbian Exposition. 8288."),
            Title(text: "Ostrich farm, Midway Plaisance, Columbian Exposition."),
            Title(text: "Stereoscopic views of the World's Columbian Exposition. 8244."),
            Title(text: "The great Ferris Wheel, Midway Plaisance, Columbian Exposition."),
            Title(text: "Idols of the British Columbian Indians, Columbian Exposition."),
            Title(text: "Stereoscopic views of the World's Columbian Exposition. 8199."),
            Title(text: "The convent where Columbus died, Columbian Exposition. 8228."),
            Title(text: "This train made the quickest time on record, a mile in 32 seconds. Columbian Exposition."),
            Title(text: "The crowning glory of the Basin, Columbian Exposition."),
            Title(text: "Stereoscopic views of the World's Columbian Exposition. 8104."),
            Title(text: "Little-me-too at the World's Fair."),
            Title(text: "Stereoscopic views of the World's Columbian Exposition. 8404."),
            Title(text: "Stereoscopic views of the World's Columbian Exposition. 8439."),
            Title(text: "Administration building and fountains from Agricultural building, Columbian Exposition."),
            Title(text: "North Canal from Electric building, Columbian Exposition."),
            Title(text: "Stereoscopic views of the World's Columbian Exposition. 7968."),
            Title(text: "Stereoscopic views of the World's Columbian Exposition. 7879."),
            Title(text: "Dedication of the Japanese building. World's Fair."),
            Title(text: "Stereoscopic views of the World's Columbian Exposition. 8567."),
            Title(text: "The great light house lens mounted for work, Electric building, World's Columbian Exposition."),
            Title(text: "The convent where Columbus died, Columbian Exposition. 8218."),
            Title(text: "Liberal Arts building, German department. Bust of the Emperor and Empress, Columbian Exposition."),
            Title(text: "Stereoscopic views of the World's Columbian Exposition. 8241."),
            Title(text: "Sweetly the chimes are ringing, Columbian Exposition."),
            Title(text: "The mammoth fern, Horticultural Hall, Columbian Exposition."),
            Title(text: "Stereoscopic views of the World's Columbian Exposition. 8195."),
            Title(text: "Columbian Exposition: Chicago, 1893. 375."),
            Title(text: "The India building, World's Fair, Chicago, Ill."),
            Title(text: "The Great Austrian exhibit, Liberal Arts building, Columbian Exposition."),
            Title(text: "Stereoscopic views of the World's Columbian Exposition. 8002."),
            Title(text: "John Bull train and great Krupp Guns, Columbian Exposition."),
            Title(text: "The convent where Columbus died, Columbian Exposition. 8226."),
            Title(text: "The great Krupp Guns, Krupp building, World's Fair, Chicago."),
            Title(text: "Stereoscopic views of the World's Columbian Exposition. 8555."),
            Title(text: "India's princess, Agricultural building, World's Fair, Chicago."),
            Title(text: "Stereoscopic views of the World's Columbian Exposition. 8712."),
            Title(text: "Stereoscopic views of the World's Columbian Exposition. 8703."),
            Title(text: "The great thunder and lightning makers, Machinery building, World's Columbian Exposition."),
            Title(text: "Stereoscopic views of the World's Columbian Exposition. 8144."),
            Title(text: "California redwood, Columbian Exposition."),
            Title(text: "Stereoscopic views of the World's Columbian Exposition. 8172."),
            Title(text: "Golden Arch, Transportation building, Columbian Exposition."),
            Title(text: "The surging sea of humanity at the opening of the Columbian Exposition."),
            Title(text: "Stereoscopic views of the World's Columbian Exposition. 7929."),
        ]
    }
}
