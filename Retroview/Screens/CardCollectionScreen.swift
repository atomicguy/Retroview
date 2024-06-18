//
//  CardCollectionScreen.swift
//  Retroview
//
//  Created by Adam Schuster on 4/28/24.
//

import SwiftUI
import SwiftData

struct CardCollectionScreen: View {
    
    @Environment(\.modelContext) private var context
    @ObservedObject var viewModel = ImportViewModel()
    @State private var isImporting = false

    
    @Query private var cards: [CardSchemaV1.StereoCard]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Stereoview Cards")
                .font(.largeTitle)
            NavigationStack {
                Button(action: {isImporting = true}, label: {
                    Label("Import", systemImage: "square.and.arrow.down")
                })
                .fileImporter(isPresented: $isImporting, allowedContentTypes: [.json], allowsMultipleSelection: true) { result in
                    switch result {
                    case .success(let urls):
                        for url in urls {
                            viewModel.importData(fromFile: url, context: context)
                        }
                    case .failure(let error):
                        print("Error importing file: \(error.localizedDescription)")
                    }
                }
                CardGridView(cards: cards)
            }
        }
        .padding()
    }
}

#Preview {
    NavigationStack{
        CardCollectionScreen()
            .modelContainer(SampleData.shared.modelContainer)
    }
}
