//
//  CollectionListItem.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftUI

struct CollectionListItem: View {
    let collection: CollectionSchemaV1.Collection
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Text(collection.name)
            Spacer()
            Text("\(collection.cardOrder.count)")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
