//
//  Card.swift
//  CardsPlayin
//
//  Created by Mike Kavouras on 7/26/23.
//

import Foundation

struct Card: CustomDebugStringConvertible, Equatable {
    let suit: Suit
    let rank: Rank
    let id = UUID().uuidString
    var isSelected: Bool
    var isFlipped: Bool
    
    init(_ value: Rank, _ suit: Suit) {
        self.rank = value
        self.suit = suit
        self.isSelected = false
        self.isFlipped = true
    }
    
    var debugDescription: String {
        "\(rank)\(suit)"
    }
    
    static func==(lhs: Card, rhs: Card) -> Bool {
        lhs.suit == rhs.suit && lhs.rank == rhs.rank
    }
    
    var imageName: String {
        isFlipped ? "back" : "\(suit.imageName)_\(rank.imageName)"
    }
    
    func isQueen(of suit: Suit) -> Bool {
        return self == Card(.queen(3), suit)
    }
    
    func isKing(of suit: Suit) -> Bool {
        return self == Card(.king(4), suit)
    }
}

