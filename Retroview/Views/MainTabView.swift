//
//  MainTabView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/10/24.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var context
    @Query private var cards: [CardSchemaV1.StereoCard]
    
    var body: some View {
        TabView {
            NavigationStack {
                CardGridView(cards: cards)
                    .navigationTitle("Collection")
            }
            .tabItem {
                Label("Collection", systemImage: "square.grid.2x2")
            }
            
            VisionBrowserView()
                .tabItem {
                    Label("Browser", systemImage: "rectangle.split.3x1")
                }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(SampleData.shared.modelContainer)
        .environmentObject(WindowStateManager.shared)
}
