//
//  CardCropView.swift
//  Retroview
//
//  Created by Adam Schuster on 6/17/24.
//

import SwiftUI

struct CardCropView: View {
    @Bindable var card: CardSchemaV1.StereoCard
    @Environment(\.modelContext) private var context

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                let viewModel = StereoCardViewModel(stereoCard: card)

                // The sample values seem to have x and y flipped
                let left = card.leftCrop
                let leftWidth =
                    CGFloat((left?.y1 ?? 0) - (left?.y0 ?? 0))
                        * geometry.size.width
                let leftHeight =
                    CGFloat((left?.x1 ?? 0) - (left?.x0 ?? 0))
                        * geometry.size.height
                let leftX =
                    CGFloat(left?.y0 ?? 0) * geometry.size.width + leftWidth / 2
                let leftY =
                    CGFloat(left?.x0 ?? 0) * geometry.size.height + leftHeight
                        / 2

                let right = card.rightCrop
                let rightWidth =
                    CGFloat((right?.y1 ?? 0) - (right?.y0 ?? 0))
                        * geometry.size.width
                let rightHeight =
                    CGFloat((right?.x1 ?? 0) - (right?.x0 ?? 0))
                        * geometry.size.height
                let rightX =
                    CGFloat(right?.y0 ?? 0) * geometry.size.width + rightWidth
                        / 2
                let rightY =
                    CGFloat(right?.x0 ?? 0) * geometry.size.height + rightHeight
                        / 2

                FrontCardView(viewModel: viewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                Rectangle()
                    .fill(Color.clear)
                    .strokeBorder(Color.red, lineWidth: 5)
                    .frame(
                        width: leftWidth,
                        height: leftHeight
                    )
                    .position(
                        x: leftX,
                        y: leftY
                    )

                Rectangle()
                    .fill(Color.clear)
                    .strokeBorder(Color.blue, lineWidth: 5)
                    .frame(
                        width: rightWidth,
                        height: rightHeight
                    )
                    .position(
                        x: rightX,
                        y: rightY
                    )
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    CardCropView(card: SampleData.shared.card)
        .modelContainer(SampleData.shared.modelContainer)
}
