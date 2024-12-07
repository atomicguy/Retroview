////
////  VisionAuthorView.swift
////  Retroview
////
////  Created by Adam Schuster on 12/5/24.
////
//
//import SwiftData
//import SwiftUI
//
//#if os(visionOS)
//struct VisionAuthorsView: View {
//    @Query(sort: \AuthorSchemaV1.Author.name) private var authors: [AuthorSchemaV1.Author]
//    @State private var selectedAuthor: AuthorSchemaV1.Author?
//    @Environment(\.spatialBrowserState) private var browserState
//    
//    var body: some View {
//        NavigationSplitView {
//            List(authors, selection: $selectedAuthor) { author in
//                AuthorRow(author: author)
//                    .tag(author)
//            }
//            .navigationTitle("Authors")
//        } detail: {
//            if let author = selectedAuthor {
//                ScrollView {
//                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 250, maximum: 300))], spacing: 10) {
//                        ForEach(author.cards) { card in
//                            CardSquareView(card: card)
//                                .withTitle()
//                                .contentShape(Rectangle())
//                                .onTapGesture {
//                                    // Pass only the current author's cards
//                                    browserState.showBrowser(with: card, cards: author.cards)
//                                }
//                        }
//                    }
//                    .padding()
//                }
//                .navigationTitle("\(author.name) (\(author.cards.count) cards)")
//            } else {
//                ContentUnavailableView(
//                    "No Author Selected",
//                    systemImage: "person",
//                    description: Text("Select an author to view their cards")
//                )
//            }
//        }
//    }
//}
//
//private struct AuthorRow: View {
//    let author: AuthorSchemaV1.Author
//    
//    var body: some View {
//        HStack {
//            Text(author.name)
//                .lineLimit(2)
//            
//            if !author.cards.isEmpty {
//                Text("\(author.cards.count)")
//                    .foregroundStyle(.secondary)
//                    .monospacedDigit()
//            }
//        }
//    }
//}
//
//#Preview {
//    VisionAuthorsView()
//        .withPreviewContainer()
//}
//#endif
