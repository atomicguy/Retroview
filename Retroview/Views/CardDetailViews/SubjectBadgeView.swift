//
//  SubjectBadgeView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftUI

struct SubjectBadge: View {
    let name: String
    
    var body: some View {
        Text(name)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.secondary.opacity(0.1))
            .clipShape(Capsule())
    }
}
