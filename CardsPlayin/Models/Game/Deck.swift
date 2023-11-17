//
//  Deck.swift
//  CardsPlayin
//
//  Created by Mike Kavouras on 7/26/23.
//

struct Deck {
    var cards: [Card] = []
    
    mutating func draw() -> Card? {
        return cards.popLast()
    }
    
    static func `for`(_ gameType: GameType) -> Deck {
        switch gameType {
        case .schnapsen:
            let suits: [Suit] = [.hearts, .diamonds, .clubs, .spades]
            let values: [Rank] = [.ten(10), .jack(2), .queen(3), .king(4), .ace(11)]
            var cards: [Card] = []
            for suit in suits {
                for v in values {
                    cards.append(Card(v, suit))
                }
            }
            return Deck(cards: cards)
        }
    }
    
    mutating func shuffle() {
        cards.shuffle()
    }
}

