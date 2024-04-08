//
//  EditCardView.swift
//  Retroview
//
//  Created by Adam Schuster on 4/7/24.
//

import SwiftUI

struct EditCardView: View {
    @Environment(\.dismiss) private var dismiss
    let card: Stereoview
    @State private var uuid = ""
    @State private var titles = [String]()
    @State private var authors = [String]()
    @State private var subjects = [String]()
    @State private var dates = [String]()
    @State private var rating: Int?
    
    var body: some View {
        VStack(alignment: .leading) {
            LabeledContent {
                RatingsView(maxRating: 5, currentRating: $rating, width: 30)
            } label: {
                Text("Rating")
            }
            Divider()
            LabeledContent {
                VStack{
                    if titles.count > 0 {
                        ForEach(0 ..< titles.count, id: \.self) { index in
                            TextField("unknown", text: $titles[index])
                        }
                    }
                }
            } label:  {
                Text("Titles")
            }
            LabeledContent {
                VStack{
                    if authors.count > 0 {
                        ForEach(0 ..< authors.count, id: \.self) { index in
                            TextField("unknown", text: $authors[index])
                        }
                    }
                }
            } label:  {
                Text("Authors")
            }
            LabeledContent {
                VStack{
                    if subjects.count > 0 {
                        ForEach(0 ..< subjects.count, id: \.self) { index in
                            TextField("unknown", text: $subjects[index])
                        }
                    }
                }
            } label:  {
                Text("Subjects")
            }
            LabeledContent {
                VStack{
                    if dates.count > 0 {
                        ForEach(0 ..< dates.count, id: \.self) { index in
                            TextField("unknown", text: $dates[index])
                        }
                    }
                }
            } label:  {
                Text("Dates")
            }
        }
        .padding()
        .textFieldStyle(.roundedBorder)
        .navigationTitle(uuid)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Update") {
                card.uuid = uuid
                card.titles = titles
                card.authors = authors
                card.subjects = subjects
                card.dates = dates
                card.rating = rating
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .onAppear {
            uuid = card.uuid
            titles = card.titles
            authors = card.authors
            subjects = card.subjects
            dates = card.dates
            rating = card.rating
        }
    }
    
    var changed: Bool {
        uuid != card.uuid
        || titles != card.titles
        || authors != card.authors
        || subjects != card.subjects
        || dates != card.dates
        || rating != card.rating
    }
}

//#Preview {
//    NavigationStack{
//        EditCardView()
//    }
//}
