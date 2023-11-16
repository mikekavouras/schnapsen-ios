//
//  Player.swift
//  CardsPlayin
//
//  Created by Mike Kavouras on 7/26/23.
//

import Foundation

struct Player: Equatable {
    let isViewer: Bool
    var cards: [Card] = []
    var tricks: [[Card]] = [] // TODO: would make more sense as a tuple (Card, Card)
    var marriages: [Marriage] = []
    let id = UUID().uuidString
    
    var selectedCards: [Card] {
        cards.filter { $0.isSelected }
    }
    
    var score: Int {
        let trickScore = tricks.flatMap { $0 }.map { $0.rank.value }.reduce(0, +)
        let marriageScore: Int = marriages.map { m in
            return m.points
        }.reduce(0, +)
        
        return trickScore + marriageScore
    }
    
    init(isViewer: Bool) {
        self.isViewer = isViewer
    }
    
    mutating func deal(_ card: Card) {
        cards.append(card)
    }
    
    mutating func addTrick(_ trick: [Card]) {
        tricks.append(trick)
    }
    
    /// `play` figures out which card to play
    mutating func play(against: Card) -> Card {
        if let idx = cardToPlayIdx(against) {
            return cards.remove(at: idx)
        }
        return Card(.two(2), .hearts)
    }
    
    /// `cardToPlayIdx` figure out which card to play against a given opponent card. This can be used to
    /// provide an opponent play, or to suggest a viewer play.
    func cardToPlayIdx(_ against: Card) -> Int? {
        print("Assessing hand...")
        print(cards.map { $0.debugDescription }.joined(separator: ","))
        
        // Do we have any cards of the same suit?
        let ofSameSuit = cards.filter { card in
            card.suit == against.suit
        }
        
        // If we have any cards of the same suit
        if ofSameSuit.count > 0 {
            // Find the highest card of the same suit
            let max = ofSameSuit.max { $0.rank < $1.rank }
            
            // Is the highest card higher than the opponents play?
            if max!.rank > against.rank {
                print("Playing higher card.")
                let foundIdx = cards.firstIndex(of: max!)!
                return foundIdx
            }
            
            print("Playing lower card.")
            // Play the lowest card of the same suit (TODO: maybe not the best move)
            let min = ofSameSuit.max { a, b in
                a.rank < b.rank
            }
            let foundIdx = cards.firstIndex(of: min!)!
            
            return foundIdx
        }
        
        // If we have no cards of the same suit, play the lowest card
        print("Playing throwaway card.")
        let min = cards.min { a, b in
            return a.rank < b.rank
        }
        if let lowestRankingCard = min,
           let foundIdx = cards.firstIndex(of: lowestRankingCard) {
            return foundIdx
        }
        
        return nil

    }
    
    mutating func playMarriage(_ marriage: Marriage) {
        marriages.append(marriage)
    }
    
    mutating func groupAndSortCards() {
        var hearts: [Card] = []
        var spades: [Card] = []
        var diamonds: [Card] = []
        var clubs: [Card] = []
        
        for card in cards {
            switch card.suit {
            case .hearts: hearts.append(card)
            case .spades: spades.append(card)
            case .diamonds: diamonds.append(card)
            case .clubs: clubs.append(card)
            }
        }
        
        hearts.sort { $0.rank.value < $1.rank.value }
        spades.sort { $0.rank.value < $1.rank.value }
        diamonds.sort { $0.rank.value < $1.rank.value }
        clubs.sort { $0.rank.value < $1.rank.value }
        
        cards = [hearts, spades, diamonds, clubs].flatMap { $0 }
    }
    
    mutating func resetHand() {
        cards = []
        tricks = []
        marriages = []
    }
    
    func hasSuit(_ suit: Suit) -> Bool {
        return cards.first(where: { $0.suit == suit }) != nil
    }
    
    static func==(lhs: Player, rhs: Player) -> Bool {
        lhs.id == rhs.id
    }
}
