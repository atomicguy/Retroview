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
            
            NavigationStack {
                CardListView(cards: cards)
                    .navigationTitle("List")
            }
            .tabItem {
                Label("List", systemImage: "list.bullet")
            }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(SampleData.shared.modelContainer)
        .environmentObject(WindowStateManager.shared)
}
