//
//  Round.swift
//  CardsPlayin
//
//  Created by Mike Kavouras on 11/9/23.
//

import Foundation

struct Round {
    var deck: Deck
    
    var players: [Player]
    var viewer: Player { players.first(where: { $0.isViewer })! }
    var opponent: Player { players.first(where: { !$0.isViewer })! }

    var turns: [Turn] = []
    var currentTurn = InProgressTurn()
    var previousTurn: Turn? { turns.last }
    
    var playedMarriageSuits: [Suit] {
        let marriages = viewer.marriages + opponent.marriages
        return marriages.map { $0.suit }
    }
    var turnIsMarriage: Bool { 
        isValidMarriage(viewer.selectedCards, for: viewer)
    }
    
    var timeForViewerToGrabTheLastCard = false
    var handIsClosed: Bool { closedHand != nil }
    var closedHand: ClosedHand?
    
    var principalCard: Card? {
        didSet {
            // The principal suit is set when the principal cards is set and
            // the principal suit is never unset
            if let pCard = principalCard {
                principalSuit = pCard.suit
            }
        }
    }
    private var principalSuit: Suit?
    
    private var trumpUnter: Card? {
        guard let principalSuit = principalSuit else { return nil }
        return Card(.jack(2), principalSuit)
    }
    
    init(_ players: [Player]) {
        self.players = players
        
        var deck = Deck.for(.schnapsen)
        deck.shuffle()
        self.deck = deck
        
        print(players.map { $0.id })
    }
    
    /// `deal` gives each player 5 cards and sets the principal card.
    mutating func deal() {
        for (i, _) in players.enumerated() {
            for _ in (0..<5) {
                var card = deck.draw()!
                if players[i].isViewer {
                    card.isFlipped = false
                }
                players[i].deal(card)
                players[i].groupAndSortCards()
            }
        }
        
        principalCard = deck.cards.removeLast()
        principalCard!.isFlipped = false
    }
    
    mutating func play(_ card: Card, `for` player: Player) -> Turn? {
        let cIdx = player.cards.firstIndex(of: card)!
        let pIdx = players.firstIndex(of: player)!
        
        // Get the player and remove the card from their hand
        var aCard = players[pIdx].cards.remove(at: cIdx)
        aCard.isFlipped = false
        
        if player == viewer {
            currentTurn.viewerPlay = aCard
            if currentTurn.opponentPlay == nil {
                let oIdx = players.firstIndex(where: { $0 != player })!
                var oppoCard = players[oIdx].play(against: card)
                oppoCard.isFlipped = false
                currentTurn.opponentPlay = oppoCard
            }
            
            return executeTurn()
        } else {
            currentTurn.opponentPlay = aCard
            if currentTurn.viewerPlay == nil {
                // update UI and wait for viewer to play
                return nil
            }
            
            return executeTurn()
        }
    }
    
    // TODO: we need more test coverage for play combos
    mutating private func executeTurn() -> Turn? {
        guard let result = findWinner() else { return nil }
        let trick = result.trick
        let winner = result.winner
        
        let score = trick.map { $0.rank.value }.reduce(0, +)
        
        let wIdx = players.firstIndex(where: { $0 == winner })
        players[wIdx!].addTrick(trick)
        
        let turn = Turn(winner: winner, trick: trick, score: score)
        turns.append(turn)
        
        return turn
    }
    
    /// `afterTurn` runs after a turn is executed.
    mutating func afterTurn() {
        currentTurn = InProgressTurn()
        
        guard !handIsClosed else { return } // play the hand we have
        guard !deck.cards.isEmpty else { return } // play the hand we have
        
        guard let previousTurn = previousTurn else { return }
        if deck.cards.count == 1 {
            if previousTurn.winner == opponent {
                let seed = Int.random(in: 0...1)
                opponentPickLastCard(seed)
            } else {
                timeForViewerToGrabTheLastCard = true
            }
            return
        }
        
        // Deal each player a new card
        let vIdx = players.firstIndex(of: viewer)!
        let oIdx = players.firstIndex(of: opponent)!
        
        // previous winner is the winner of the turn we just executed
        if previousTurn.winner == viewer {
            var playerCard = deck.draw()!
            playerCard.isFlipped = false
            players[vIdx].deal(playerCard)
            players[oIdx].deal(deck.draw()!)
        } else {
            players[oIdx].deal(deck.draw()!)
            var playerCard = deck.draw()!
            playerCard.isFlipped = false
            players[vIdx].deal(playerCard)
        }
        
        for (i, _) in players.enumerated() {
            players[i].groupAndSortCards()
        }
    }


    private func findWinner() -> (trick: [Card], winner: Player)? {
        guard let principalSuit else { return nil }
        
        let t = currentTurn
        guard let vPlay = t.viewerPlay,
              let oPlay = t.opponentPlay else { return nil }
        
        var winner: Player?
        let trick = [vPlay, oPlay]
        
        // which suite was played first
        guard let suit = currentTurn.suit else { return nil }
        
        
        winner = if vPlay.suit == principalSuit && oPlay.suit != principalSuit {
            viewer
        } else if oPlay.suit == principalSuit && vPlay.suit != principalSuit {
            opponent
        } else if oPlay.suit != suit {
            viewer
        } else if vPlay.suit != suit {
            opponent
        } else if vPlay.rank > oPlay.rank {
            viewer
        } else {
            opponent
        }
        
        return (trick, winner!)
    }
    
    mutating func didTap(_ card: Card) -> Bool {
        guard let cIdx = viewer.cards.firstIndex(where: { $0 == card }) else { return false }
        guard let pIdx = players.firstIndex(where: { $0 == viewer }) else { return false }
        
        if players[pIdx].cards[cIdx].isSelected {
            deselect(card, for: viewer)
        } else {
            return select(card, for: viewer)
        }
        
        return true
    }
    
    mutating private func deselect(_ card: Card, `for` player: Player) {
       if let cIdx = player.cards.firstIndex(where: { $0 == card }),
          let pIdx = players.firstIndex(where: { $0 == player }) {
           players[pIdx].cards[cIdx].isSelected = false
       }
   }
   
   mutating private func select(_ card: Card, `for` player: Player) -> Bool {
       if !canSelect(card, for: player) { return false }
       
       let cIdx = player.cards.firstIndex(where: { $0 == card })!
       let pIdx = players.firstIndex(where: { $0 == player })!
       
       // Deselect all cards *unless it's a potential marriage*
       if !isValidMarriage([card, player.selectedCards.first], for: viewer) {
           for (i, _) in players[pIdx].cards.enumerated() {
               if i == cIdx { continue }
               players[pIdx].cards[i].isSelected = false
           }
       }

       players[pIdx].cards[cIdx].isSelected = true
       
       return true
    }
    
    mutating private func deselectPlayerCards(_ player: Player) {
        if let pIdx = players.firstIndex(where: { $0 == player }) {
            for (i, _) in players[pIdx].cards.enumerated() {
                players[pIdx].cards[i].isSelected = false
            }
        }
    }
    
    func canSelect(_ card: Card, `for` player: Player) -> Bool {
        // If the current turn has a marriage then the player can only play
        // the king or queen
        if let marriage = currentTurn.marriage {
            if card != Card(.queen(3), marriage.suit) &&
                card != Card(.king(4), marriage.suit) {
                return false
            }
        }
        
        if let oPlay = currentTurn.opponentPlay {
            let hasSuit = player.hasSuit(oPlay.suit)
            if (handIsClosed || deck.cards.isEmpty) && hasSuit && card.suit != oPlay.suit {
                return false
            }
        }
        
        if timeForViewerToGrabTheLastCard {
            return false
        }
        
        
        return true
    }
    
    mutating func capturePrincipalCard(_ player: Player) {
        guard let card = principalCard else { return }
        guard card.rank != .jack(2) else { return }
        
        if let pIdx = players.firstIndex(where: { $0 == player }) {
            // check if the player has the jack
            guard let jIdx = players[pIdx].cards.firstIndex(of: trumpUnter!) else { return }
            
            // We want to remove the selected state so the card isn't auto-selected
            // if it ends up back in our hand at the end of the round.
            players[pIdx].cards[jIdx].isSelected = false
            
            let jack = players[pIdx].cards.remove(at: jIdx)
            // swap the jack with the principal card
            players[pIdx].cards.insert(card, at: jIdx)
            principalCard = jack
            
            players[pIdx].groupAndSortCards()
        }
    }
    
    mutating func playMarriage(_ player: Player, cards: [Card]) {
        guard isValidMarriage(cards, for: player) else { return }
        
        let suit = cards[0].suit
        let isRoyal = suit == principalSuit
        let marriage = Marriage(suit: suit, isRoyal: isRoyal)
        
        if let pIdx = players.firstIndex(where: { $0 == player }) {
            players[pIdx].playMarriage(marriage)
            
            let card = cards[0]
            deselectPlayerCards(player)
            _ = select(card, for: player)
        }
        
        currentTurn.marriage = marriage
    }
    
    func isValidMarriage(_ c: [Card?], `for` player: Player) -> Bool {
        let cards = c.compactMap { $0 }
        return PotentialMarriage(
            player: player,
            cards: cards
        ).isValid(in: self)
    }
        
    mutating func closeHand(_ player: Player) {
        let oIdx = players.firstIndex(where: { $0 != player })!
        let o = players[oIdx]
        closedHand = ClosedHand(score: o.score, initiator: player)
        
        // move principal card to the top of the deck
        deck.cards.append(principalCard!)
        principalCard = nil
    }
    
    mutating private func opponentPickLastCard(_ seed: Int) {
        let cards = [deck.cards[0], principalCard]
        let oCard = cards[seed]!
        
        let oppIdx = players.firstIndex(of: opponent)!
        let viewerIdx = players.firstIndex(of: viewer)!
        
        if principalCard == oCard {
            principalCard?.isFlipped = true
            players[oppIdx].deal(principalCard!)
            
            var viewerCard = deck.cards.remove(at: 0)
            viewerCard.isFlipped = false
            players[viewerIdx].deal(viewerCard)
        } else {
            players[viewerIdx].deal(principalCard!)
            
            var opponentCard = deck.cards.remove(at: 0)
            opponentCard.isFlipped = true
            players[oppIdx].deal(opponentCard)
        }
        
        timeForViewerToGrabTheLastCard = false
        for (i, _) in players.enumerated() {
            players[i].groupAndSortCards()
        }

        principalCard = nil
    }
    
    mutating func chooseFinalCard(_ card: Card) {
        let vIdx = players.firstIndex(of: viewer)!
        let oIdx = players.firstIndex(of: opponent)!
        
        if card == principalCard {
            players[vIdx].deal(principalCard!)
            principalCard = nil
            
            var c = deck.cards.remove(at: 0)
            c.isFlipped = true
            players[oIdx].deal(c)
        } else {
            var c = deck.cards.remove(at: 0)
            c.isFlipped = false
            players[vIdx].deal(c)
            
            principalCard?.isFlipped = true
            players[oIdx].deal(principalCard!)
            principalCard = nil
        }
        
        timeForViewerToGrabTheLastCard = false
        
        for (i, _) in players.enumerated() {
            players[i].groupAndSortCards()
        }
    }
    
    mutating func createOpponentPlay() {
        if viewer.cards.count == 0 && opponent.cards.count == 0 { return }
        
        // TODO: How to pick a good card?
        let idx = if opponent.cards.count <= 1 {
            0
        } else {
            Int.random(in: 0..<opponent.cards.count)
        }
        _ = play(opponent.cards[idx], for: opponent)
    }
    
    func isOver() -> Bool {
        // Someone hit 66
        if viewer.score >= 66 || opponent.score >= 66 {
            return true
        }
        
        // Everyone is out of cards
        if opponent.cards.isEmpty && viewer.cards.isEmpty {
            return true
        }
        
        return false
    }
}
