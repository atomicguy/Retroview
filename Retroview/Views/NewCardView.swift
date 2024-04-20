//
//  NewCardView.swift
//  Retroview
//
//  Created by Adam Schuster on 4/6/24.
//

import SwiftUI

struct NewCardView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @State private var uuid = ""
    @State private var titles = [""]
    @State private var authors = [""]
    @State private var subjects = [""]
    @State private var dates = [""]
    var body: some View {
        NavigationStack {
            Form {
                TextField("UUID", text: $uuid)
                TextField("Title", text: $titles[0])
                TextField("Author", text: $authors[0])
                TextField("Subject", text: $subjects[0])
                TextField("Date", text: $dates[0])
                Button("Create") {
                    let newCard = Card(uuid: uuid, titles: titles, authors: authors, subjects: subjects, dates: dates)
                    context.insert(newCard)
                    dismiss()
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .buttonStyle(.borderedProminent)
                .padding(.vertical)
                .disabled(
                    uuid.isEmpty || titles.isEmpty || authors.isEmpty || subjects.isEmpty || dates.isEmpty
                )
                .navigationTitle("New Card")
            }
            
        }
    }
}

#Preview {
    NewCardView()
}
