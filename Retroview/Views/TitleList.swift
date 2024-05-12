//
//  TitleList.swift
//  Retroview
//
//  Created by Adam Schuster on 5/11/24.
//

import SwiftUI
import SwiftData

struct TitleList: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TitleSchemaV1.Title.text) private var titles: [TitleSchemaV1.Title]
    
    @State private var newTitle: TitleSchemaV1.Title?
    
    var body: some View {
        NavigationSplitView {
            Group {
                if !titles.isEmpty {
                    List {
                        ForEach(titles) { title in
                            NavigationLink {
                                Text(title.text)
                                    .navigationTitle("Title")
                            } label: {
                                Text(title.text)
                            }
                        }
                    }
                    
                } else {
                    ContentUnavailableView {
                        Label("No Titles", systemImage: "person.and.person")
                    }
                }
            }
            
        } detail: {
        Text("Select a title")
                .navigationTitle("Title")
        }
    }
}

#Preview {
    TitleList()
        .modelContainer(SampleData.shared.modelContainer)
}
