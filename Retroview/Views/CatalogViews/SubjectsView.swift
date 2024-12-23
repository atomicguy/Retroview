//
//  SubjectsView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftUI

struct SubjectsView: View {
    var body: some View {
        CatalogContainerView<SubjectSchemaV1.Subject>(
            title: "Subjects",
            icon: "tag",
            sortDescriptor: SortDescriptor(\SubjectSchemaV1.Subject.name)
        )
    }
}
