//
//  RetroviewApp.swift
//  Retroview
//
//  Created by Adam Schuster on 4/6/24.
//

import SwiftUI
import SwiftData

@main
struct RetroviewApp: App {
    var body: some Scene {
        WindowGroup {
            CollectionView()
        }
        .modelContainer(for: Stereoview.self)
    }
    
    init() {
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
}
