//
//  StereoBrowser.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

#if os(visionOS)
import RealityKit
import StereoViewer

struct StereoBrowser: View {
    let cards: [CardSchemaV1.StereoCard]
    @Binding var selectedCard: CardSchemaV1.StereoCard
    @Binding var isVisible: Bool
    
    var body: some View {
        ZStack {
            StereoView(card: selectedCard)
            
            VStack {
                StereoControlsView {
                    isVisible = false
                }
                
                Spacer()
                
                CardStrip(
                    cards: cards,
                    selectedCard: $selectedCard
                )
                .padding(.bottom)
            }
        }
    }
}
#endif
