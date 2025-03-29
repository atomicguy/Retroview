//
//  CardStackDestination.swift
//  Retroview
//
//  Created by Adam Schuster on 12/31/24.
//

enum CardDetailDestination: Hashable {
    case stack(
        cards: [CardSchemaV1.StereoCard], initialCard: CardSchemaV1.StereoCard)

    // Make it Hashable by comparing card IDs
    func hash(into hasher: inout Hasher) {
        switch self {
        case .stack(let cards, let initialCard):
            hasher.combine(cards.map { $0.id })
            hasher.combine(initialCard.id)
        }
    }

    static func == (lhs: CardDetailDestination, rhs: CardDetailDestination)
        -> Bool
    {
        switch (lhs, rhs) {
        case (
            .stack(let cards1, let initial1), .stack(let cards2, let initial2)
        ):
            return cards1.map({ $0.id }) == cards2.map({ $0.id })
                && initial1.id == initial2.id
        }
    }
}
