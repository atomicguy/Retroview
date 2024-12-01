//
//  DevelopmentFlags.swift
//  Retroview
//
//  Created by Adam Schuster on 11/30/24.
//

//  DevelopmentFlags.swift
import Foundation

enum DevelopmentFlags {
    private static let defaults = UserDefaults.standard
    
    static var shouldResetStore: Bool {
        get { defaults.bool(forKey: "DEV_SHOULD_RESET_STORE") }
        set { defaults.set(newValue, forKey: "DEV_SHOULD_RESET_STORE") }
    }
    
    // Remove automatic reset to allow flag to persist through app restart
    static func reset() {
        shouldResetStore = false
    }
}
