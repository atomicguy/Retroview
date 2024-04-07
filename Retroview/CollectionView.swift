//
//  ContentView.swift
//  Retroview
//
//  Created by Adam Schuster on 4/6/24.
//

import SwiftUI

struct CollectionView: View {
    @State private var createNewCard = false
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
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

#Preview {
    CollectionView()
}
