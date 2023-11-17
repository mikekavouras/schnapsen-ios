//
//  Marraige.swift
//  CardsPlayin
//
//  Created by Mike Kavouras on 11/6/23.
//

import Foundation

struct Marriage {
    let suit: Suit
    let isRoyal: Bool
    
    var points: Int {
        return isRoyal ? 40 : 20
    }
}

struct PotentialMarriage {
    let player: Player
    let cards: [Card]
    
    func isValid(in round: Round) -> Bool {
        guard isMarriage() else { return false }
        guard playerHasCards() else { return false }
        guard !round.playedMarriageSuits.contains(cards[0].suit) else { return false }
        if round.previousTurn != nil && round.previousTurn!.winner == round.opponent { return false }
        
        return true
    }
    
    private func isMarriage() -> Bool {
        guard cards.count == 2 else { return false }
        guard cards[0].suit == cards[1].suit else { return false }
        
        let suit = cards[0].suit
        let lCard = cards.first!
        let rCard = cards.last!
        
        if (lCard.isKing(of: suit) && rCard.isQueen(of: suit)) || (lCard.isQueen(of: suit) && rCard.isKing(of: suit)) {
            return true
        }
        
        return false
    }
    
    private func playerHasCards() -> Bool {
        guard player.cards.firstIndex(of: cards[0]) != nil else { return false }
        guard player.cards.firstIndex(of: cards[1]) != nil else { return false }
        
        return true
    }
}
