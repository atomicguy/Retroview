//
//  DailyDiscoveryView.swift
//  Retroview
//
//  Created by Adam Schuster on 3/24/25.
//

import SwiftUI
import SwiftData

struct DailyDiscoveryView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var navigationPath: NavigationPath
    @State private var discoveryManager: DailyDiscoveryManager
    @State private var selectedCard: CardSchemaV1.StereoCard? = nil
    
    init(navigationPath: Binding<NavigationPath>, modelContext: ModelContext) {
        self._navigationPath = navigationPath
        self._discoveryManager = State(initialValue: DailyDiscoveryManager(modelContext: modelContext))
    }
    
    private let columns = [
        GridItem(.adaptive(
            minimum: PlatformEnvironment.Metrics.gridMinWidth,
            maximum: PlatformEnvironment.Metrics.gridMaxWidth
        ), spacing: PlatformEnvironment.Metrics.gridSpacing)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Title with refresh date
            HStack {
                VStack(alignment: .leading) {
                    Text("Daily Discoveries")
                        .font(.system(.title, design: .serif))
                    
                    if let refreshDate = discoveryManager.lastRefreshDate {
                        Text("Updated \(refreshDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // Cards count
                Text("\(discoveryManager.dailyCards.count) cards")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            
            if discoveryManager.isLoading {
                Spacer()
                ProgressView("Loading daily discoveries...")
                Spacer()
            } else if discoveryManager.dailyCards.isEmpty {
                Spacer()
                ContentUnavailableView("No Discoveries Today", systemImage: "star.slash")
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: PlatformEnvironment.Metrics.gridSpacing) {
                        ForEach(discoveryManager.dailyCards) { card in
                            ThumbnailSelectableView(
                                card: card,
                                isSelected: card.id == selectedCard?.id,
                                onSelect: { selectedCard = card },
                                onDoubleClick: {
                                    navigationPath.append(
                                        CardDetailDestination.stack(
                                            cards: discoveryManager.dailyCards,
                                            initialCard: card
                                        )
                                    )
                                }
                            )
                        }
                    }
                    .padding(PlatformEnvironment.Metrics.defaultPadding)
                }
            }
        }
        .task {
            await discoveryManager.loadDailyCards()
        }
        .refreshable {
            await discoveryManager.loadDailyCards()
        }
    }
}
