//
//  VisionNavigationView.swift
//  Retroview
//
//  Created by Adam Schuster on 1/6/25.
//

import SwiftUI

#if os(visionOS)
    struct VisionNavigationView: View {
        @Binding var selectedDestination: AppDestination?
        @Binding var navigationPath: NavigationPath
        @Environment(\.modelContext) private var modelContext
        @State private var showingTransferSheet = false

        var body: some View {
            TabView(selection: destinationBinding) {
                NavigationStack(path: $navigationPath) {
                    DailyDiscoveryView(
                        navigationPath: $navigationPath,
                        modelContext: modelContext
                    )
                    .withNavigationDestinations(navigationPath: $navigationPath)
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button {
                                showingTransferSheet = true
                            } label: {
                                Label("Transfer Library", systemImage: "arrow.triangle.swap")
                                    .labelStyle(.iconOnly)
                            }
                        }
                    }
                }
                .tabItem {
                    Label("Daily Discovery", image: "custom.mustache.seal")
                }
                .tag(AppDestination.dailyDiscovery)
                
                NavigationStack(path: $navigationPath) {
                    LibraryGridView(
                        navigationPath: $navigationPath
                    )
                    .withNavigationDestinations(navigationPath: $navigationPath)
                }
                .tabItem {
                    Label("Library", systemImage: "photo.on.rectangle.angled")
                }
                .tag(AppDestination.library)

                NavigationStack(path: $navigationPath) {
                    GroupGridView<SubjectSchemaV1.Subject>(
                        title: "Subjects",
                        navigationPath: $navigationPath,
                        sortDescriptor: SortDescriptor(
                            \SubjectSchemaV1.Subject.name)
                    )
                    .withNavigationDestinations(navigationPath: $navigationPath)
                }
                .tabItem {
                    Label("Subjects", systemImage: "tag")
                }
                .tag(AppDestination.subjects)

                NavigationStack(path: $navigationPath) {
                    GroupGridView<AuthorSchemaV1.Author>(
                        title: "Authors",
                        navigationPath: $navigationPath,
                        sortDescriptor: SortDescriptor(
                            \AuthorSchemaV1.Author.name)
                    )
                    .withNavigationDestinations(navigationPath: $navigationPath)
                }
                .tabItem {
                    Label("Authors", systemImage: "person")
                }
                .tag(AppDestination.authors)

                NavigationStack(path: $navigationPath) {
                    GroupGridView<DateSchemaV1.Date>(
                        title: "Dates",
                        navigationPath: $navigationPath,
                        sortDescriptor: SortDescriptor(\DateSchemaV1.Date.text)
                    )
                    .withNavigationDestinations(navigationPath: $navigationPath)
                }
                .tabItem {
                    Label("Dates", systemImage: "calendar")
                }
                .tag(AppDestination.dates)

                NavigationStack(path: $navigationPath) {
                    GroupGridView<CollectionSchemaV1.Collection>(
                        title: "Collections",
                        navigationPath: $navigationPath,
                        sortDescriptor: SortDescriptor(\.name)
                    )
                    .withNavigationDestinations(
                        navigationPath: $navigationPath)
                }
                .tabItem {
                    Label("Collections", systemImage: "folder")
                }
                .tag(AppDestination.collections)
                
                NavigationStack(path: $navigationPath) {
                    FavoritesView(navigationPath: $navigationPath)
                        .withNavigationDestinations(
                            navigationPath: $navigationPath)
                }
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }
                .tag(AppDestination.favorites)
            }
            .sheet(isPresented: $showingTransferSheet) {
                StoreTransferView()
            }
        }

        private var destinationBinding: Binding<AppDestination> {
            Binding(
                get: { selectedDestination ?? .dailyDiscovery },
                set: { selectedDestination = $0 }
            )
        }
    }
#endif
