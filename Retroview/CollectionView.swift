//
//  ContentView.swift
//  Retroview
//
//  Created by Adam Schuster on 4/6/24.
//

import SwiftUI
import SwiftData

struct CollectionView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Stereoview.uuid) private var stereoviews: [Stereoview]
    @State private var createNewCard = false
    var body: some View {
        NavigationStack{
            List {
                ForEach(stereoviews) { stereoview in
                    NavigationLink {
                        EditCardView(card: stereoview)
                    } label: {
                        HStack(spacing: 10) {
                            VStack(alignment: .leading) {
                                Text(stereoview.titles[0]).font(.title2)
                                Text(stereoview.uuid).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .onDelete {indexSet in
                    indexSet.forEach { index in
                        let stereoview = stereoviews[index]
                        context.delete(stereoview)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Stereoviews")
            .toolbar {
                Button {
                    createNewCard = true
                }label: {
                    Image(systemName: "plus.circle.fill")
                        .imageScale(.large)
                }
            }
            .sheet(isPresented: $createNewCard) {
                NewCardView()
                    .presentationDetents([.medium])
            }
        }
    }
}

#Preview {
    CollectionView()
        .modelContainer(for: Stereoview.self, inMemory: true)
}


