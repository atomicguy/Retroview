//
//  OrnamentalDivider.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftUI

struct OrnamentalDivider: View {
    var body: some View {
        HStack {
            Image(systemName: "laurel.leading")
                .foregroundStyle(.secondary.opacity(0.5))
            
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.secondary.opacity(0.3))
            
            Image(systemName: "laurel.trailing")
                .foregroundStyle(.secondary.opacity(0.5))
        }
        .padding(.vertical, 6)
    }
}
