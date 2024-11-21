//
//  RootView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/19/24.
//

import SwiftUI
import SwiftData

struct RootView: View {
    var body: some View {
        #if os(macOS)
        MacBrowserView()
        #else
        MainTabView()
        #endif
    }
}
