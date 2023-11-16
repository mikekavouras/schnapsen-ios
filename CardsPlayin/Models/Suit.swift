//
//  Suit.swift
//  CardsPlayin
//
//  Created by Mike Kavouras on 7/26/23.
//

enum Suit: CustomDebugStringConvertible {
    case hearts
    case diamonds
    case spades
    case clubs
    
    var imageName: String {
        switch self {
        case .hearts:
            return "hearts"
        case .diamonds:
            return "diamonds"
        case .spades:
            return "spades"
        case .clubs:
            return "clubs"
        }
    }
    
    var debugDescription: String {
        switch self {
        case .hearts: return "♥"
        case .clubs: return "♣"
        case .spades: return "♠"
        case .diamonds: return "♦"
        }
    }
}

extension Suit: Equatable {
    static func ==(lhs: Suit, rhs: Suit) -> Bool {
        switch (lhs, rhs) {
        case (.hearts, .hearts): return true
        case (.diamonds, .diamonds): return true
        case (.spades, .spades): return true
        case (.clubs, .clubs): return true
        default: return false
        }
    }
}
