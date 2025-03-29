//
//  DebugMenu.swift
//  Retroview
//
//  Created by Adam Schuster on 11/29/24.
//

import SwiftData
import SwiftUI

#if DEBUG
struct DebugMenu: View {
    @State private var showingRestartAlert = false
    
    var body: some View {
        Button {
            showingRestartAlert = true
        } label: {
            Label("Reset Database", systemImage: "trash")
        }
        .alert("Reset Database",
               isPresented: $showingRestartAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset & Restart", role: .destructive) {
                StoreUtility.resetStore()
                // Restart the app
                #if os(macOS)
                let task = Process()
                task.executableURL = URL(fileURLWithPath: Bundle.main.executablePath!)
                try? task.run()
                NSApp.terminate(nil)
                #else
                exit(0)
                #endif
            }
        } message: {
            Text("This will delete all data and restart the app. Are you sure?")
        }
    }
}
#endif
//
//#Preview("Debug Menu") {
//    DebugMenu()
//        .withPreviewData()
//}
