//
//  RoundTests.swift
//  CardsPlayinTests
//
//  Created by Mike Kavouras on 11/9/23.
//

import XCTest
import CardsPlayin

final class RoundTests: XCTestCase {
    func testInitializeSchnapsen() {
        let round = Round([
            Player(isViewer: true),
            Player(isViewer: false)
        ])
        
        XCTAssertEqual(round.players.count, 2)
        XCTAssertEqual(round.deck.cards.count, 20)
        XCTAssertNil(round.principalCard)
    }
}

/// `deal`
extension RoundTests {
    func testDealCards() {
        var round = Round([
            Player(isViewer: true),
            Player(isViewer: false)
        ])
        round.deal()
        
        // each player has 5 cards
        for (i, _) in round.players.enumerated() {
            XCTAssertEqual(round.players[i].cards.count, 5)
        }
        
        // there is a deck
        XCTAssertEqual(round.deck.cards.count, 9)
        
        // there is a principal card face up
        XCTAssertNotNil(round.principalCard)
        XCTAssertFalse(round.principalCard!.isFlipped)
    }
}

///// `didTap`
extension RoundTests {
    func testSelectCard() {
        var round = Round([
            Player(isViewer: true),
            Player(isViewer: false)
        ])
        round.deal()
        
        XCTAssertEqual(round.viewer.selectedCards.count, 0)
        
        let player = round.viewer
        let card = player.cards[0]
        
        round.didTap(card)
        
        XCTAssertTrue(round.viewer.cards[0].isSelected)
        XCTAssertEqual(round.viewer.selectedCards.count, 1)
    }
    
    func testSelectCardDeselectsOtherCards() {
        var round = Round([
            Player(isViewer: true),
            Player(isViewer: false)
        ])
        round.deal()
        
        round.players[0].cards = [
            Card(.jack(2), .spades),
            Card(.queen(3), .hearts)
        ]
        
        XCTAssertEqual(round.players[0].selectedCards.count, 0)
        
        let player = round.players[0]
        let card = player.cards[0]
        
        _ = round.didTap(card)
        
        XCTAssertTrue(round.players[0].cards[0].isSelected)
        
        let otherCard = player.cards[1]
        
        _ = round.didTap(otherCard)
        
        XCTAssertFalse(round.viewer.cards[0].isSelected)
    }
        
    func testSelectPossibleMarriage() {
        var round = Round([
            Player(isViewer: true),
            Player(isViewer: false)
        ])

        XCTAssertEqual(round.viewer.selectedCards.count, 0)
        
        let kingOfHeartsIdx = round.deck.cards.firstIndex(where: { $0.suit == .hearts && $0.rank == .king(4) })!
        let kingOfHearts = round.deck.cards.remove(at: kingOfHeartsIdx)
        let queenOfHeartsIdx = round.deck.cards.firstIndex(where: { $0.suit == .hearts && $0.rank == .queen(3) })!
        let queenOfHearts = round.deck.cards.remove(at: queenOfHeartsIdx)
        
        round.players[0].deal(kingOfHearts)
        round.players[0].deal(queenOfHearts)
        
        _ = round.didTap(kingOfHearts)
        _ = round.didTap(queenOfHearts)
        
        XCTAssertEqual(round.viewer.selectedCards.count, 2)
        XCTAssertTrue(round.viewer.cards[0].isSelected)
        XCTAssertTrue(round.viewer.cards[1].isSelected)
    }
    
    func testSelectPossibleMarriageAlreadyPlayedSuit() {
        var round = Round([
            Player(isViewer: true),
            Player(isViewer: false)
        ])
        round.players[0].marriages = [Marriage(suit: .hearts, isRoyal: false)]
        
        XCTAssertEqual(round.viewer.selectedCards.count, 0)
        
        let kingOfHeartsIdx = round.deck.cards.firstIndex(where: { $0.suit == .hearts && $0.rank == .king(4) })!
        let kingOfHearts = round.deck.cards.remove(at: kingOfHeartsIdx)
        let queenOfHeartsIdx = round.deck.cards.firstIndex(where: { $0.suit == .hearts && $0.rank == .queen(3) })!
        let queenOfHearts = round.deck.cards.remove(at: queenOfHeartsIdx)
        
        round.players[0].deal(kingOfHearts)
        round.players[0].deal(queenOfHearts)
        
        _ = round.didTap(kingOfHearts)
        _ = round.didTap(queenOfHearts)
        
        XCTAssertEqual(round.viewer.selectedCards.count, 1)
    }
    
    func testPossibleMarriageNotWinner() {
        var round = Round([
            Player(isViewer: true),
            Player(isViewer: false)
        ])

        let turn = Turn(winner: round.opponent, trick: [], score: 0)
        round.turns.append(turn)
        
        XCTAssertEqual(round.viewer.selectedCards.count, 0)
        
        let kingOfHeartsIdx = round.deck.cards.firstIndex(where: { $0.suit == .hearts && $0.rank == .king(4) })!
        let kingOfHearts = round.deck.cards.remove(at: kingOfHeartsIdx)
        let queenOfHeartsIdx = round.deck.cards.firstIndex(where: { $0.suit == .hearts && $0.rank == .queen(3) })!
        let queenOfHearts = round.deck.cards.remove(at: queenOfHeartsIdx)
        
        round.players[0].deal(kingOfHearts)
        round.players[0].deal(queenOfHearts)
        
        _ = round.didTap(kingOfHearts)
        _ = round.didTap(queenOfHearts)
        
        XCTAssertEqual(round.viewer.selectedCards.count, 1)
    }
    
    func testAfterTurnAfterMarriage() {
        var round = Round([
            Player(isViewer: true),
            Player(isViewer: false)
        ])
        
        let hand = [
            Card(.queen(3), .spades),
            Card(.king(4), .spades),
            Card(.ace(11), .hearts)
        ]

        for card in hand {
            let cIdx = round.deck.cards.firstIndex(of: card)
            let c = round.deck.cards.remove(at: cIdx!)
            round.players[0].deal(c)
        }
        
        XCTAssertEqual(round.viewer.cards.count, 3)
        
        let marriage = Marriage(suit: .spades, isRoyal: false)
        round.currentTurn = InProgressTurn(marriage: marriage)
        
        _ = round.didTap(hand[2])
        
        XCTAssertFalse(round.viewer.cards[2].isSelected)
        
        _ = round.didTap(hand[1])
        
        XCTAssertTrue(round.viewer.cards[1].isSelected)
    }
    
    func testSelectionDisabledFollowSuit() {
        // TODO: test for this
        var round = Round([
            Player(isViewer: true),
            Player(isViewer: false)
        ])
        round.principalCard = Card(.king(4), .spades)
    
        round.closeHand(round.viewer)
        
        round.currentTurn.opponentPlay = Card(.ace(11), .hearts)
        
        round.players[0].cards = [
            Card(.ace(11), .spades),
            Card(.jack(2), .hearts)
        ]
        
        _ = round.didTap(round.players[0].cards[0])
        
        XCTAssertFalse(round.players[0].cards[0].isSelected)
        
        _ = round.didTap(round.players[0].cards[1])
        
        XCTAssertTrue(round.players[0].cards[1].isSelected)
    }
}

///// `afterTurn`
extension RoundTests {
    /// `it "does nothing if the hand is closed"`
    func testAfterTurnDoesNothingIfHandIsClosed() {
        var round = Round([
            Player(isViewer: true),
            Player(isViewer: false)
        ])
        round.deal()
        
        XCTAssertEqual(round.viewer.cards.count, 5)
        XCTAssertEqual(round.opponent.cards.count, 5)
        
        round.closeHand(round.viewer)
        _ = round.play(round.viewer.cards[0], for: round.viewer)
        
        XCTAssertEqual(round.viewer.cards.count, 4)
        XCTAssertEqual(round.viewer.cards.count, 4)
    }
    
    /// `it "does nothing if the deck is empty"`
    func testAfterTurnDoesNothingIfDeckIsEmpty() {
        var round = Round([
            Player(isViewer: true),
            Player(isViewer: false)
        ])
        round.deal()
        round.deck = Deck()
        
        XCTAssertEqual(round.deck.cards.count, 0)
        
        XCTAssertEqual(round.viewer.cards.count, 5)
        XCTAssertEqual(round.opponent.cards.count, 5)
        
        round.closeHand(round.viewer)
        _ = round.play(round.viewer.cards[0], for: round.viewer)
        
        XCTAssertEqual(round.viewer.cards.count, 4)
        XCTAssertEqual(round.viewer.cards.count, 4)
    }
    
    /// `it "distributes a card to opponent and viewer on the last turn"`
    func testAfterTurnLastCardOpponentWinner() {
        var round = Round([
            Player(isViewer: true),
            Player(isViewer: false)
        ])
        round.deal()
        
        // give opponent winning card
        // give viewer losing card
    }
    
    /// `it "waits for the viewer to select a card on the last turn"`
    func testAfterTurnLastCardViewerWinner() {
        
    }
    
    
    /// `it "deals fresh cards to opponent and viewer based on the previous winner`
    func testAfterTurnDealsNewCardsBasedOnPreviousWinner() {
    }
    
    func testAfterTurnAfterTrick() {
        var round = Round([
            Player(isViewer: true),
            Player(isViewer: false)
        ])
        round.deal()
        
        _ = round.play(round.viewer.cards[0], for: round.viewer)
        
        XCTAssertEqual(round.viewer.cards.count, 4)
        XCTAssertEqual(round.opponent.cards.count, 4)
        
        round.afterTurn()
        
        XCTAssertEqual(round.viewer.cards.count, 5)
        XCTAssertEqual(round.opponent.cards.count, 5)
    }
}

///// `closeHand`
extension RoundTests {
    func testCloseHand() {
        var round = Round([
            Player(isViewer: true),
            Player(isViewer: false)
        ])
        round.deal()
        
        XCTAssertNotNil(round.principalCard)
        XCTAssertFalse(round.handIsClosed)
        
        round.closeHand(round.viewer)
        
        XCTAssertNil(round.principalCard)
        XCTAssertTrue(round.handIsClosed)
    }
}

///// `canCloseHand`
extension RoundTests {
    func testCanCloseHandAlreadyClosed() {
        var game = Game()
        XCTAssertTrue(game.canCloseHand())
        game.currentRound.closedHand = ClosedHand(score: 10, initiator: Player(isViewer: true))
        XCTAssertFalse(game.canCloseHand())
    }
    
    func testCanCloseHandWinner() {
        var game = Game()
        XCTAssertTrue(game.canCloseHand())
        game.hands = [
            Hand(winner: game.opponent, points: 2)
        ]
        XCTAssertFalse(game.canCloseHand())
    }
}

///// `capturePrincipalCard`
extension RoundTests {
    func testCapturePrincipalCardWithJack() {
        // TODO: oppo should also be able to capture the principal card
        var round = Round([
            Player(isViewer: true),
            Player(isViewer: false)
        ])
        let vIdx = round.players.firstIndex(where: { $0 == round.viewer })!
        
        // find a principal card and remove it from the deck
        let pIdx = round.deck.cards.firstIndex(of: Card(.queen(3), .spades))!
        let pCard = round.deck.cards.remove(at: pIdx)
        
        // Set the principal card
        round.principalCard = pCard
        
        // Give the player the jack of principal suit
        let jack = Card(.jack(2), .spades)
        round.players[vIdx].deal(jack)
        
        XCTAssertEqual(round.players[vIdx].cards.count, 1)
        XCTAssertEqual(round.players[vIdx].cards[0], jack)
        
        round.capturePrincipalCard(round.viewer)
        
        // Assert that principal card and jack have switched
        XCTAssertEqual(round.principalCard, jack)
        XCTAssertEqual(round.players[vIdx].cards.count, 1)
        XCTAssertEqual(round.players[vIdx].cards[0], pCard)
    }
    
    func testCapturePrincipalCardWithoutJack() {
        var round = Round([
            Player(isViewer: true),
            Player(isViewer: false)
        ])
        let vIdx = round.players.firstIndex(where: { $0 == round.viewer })!
        
        // find a principal card and remove it from the deck
        let pIdx = round.deck.cards.firstIndex(of: Card(.queen(3), .spades))!
        let pCard = round.deck.cards.remove(at: pIdx)
        
        // Set the principal card
        round.principalCard = pCard
        
        // Give the player the jack of principal suit
        let notJack = Card(.ace(11), .spades)
        round.players[vIdx].deal(notJack)
        
        XCTAssertEqual(round.players[vIdx].cards.count, 1)
        XCTAssertEqual(round.players[vIdx].cards[0], notJack)
        
        round.capturePrincipalCard(round.viewer)
        
        // Assert that principal card and jack have *not* switched
        XCTAssertEqual(round.principalCard, pCard)
        XCTAssertEqual(round.players[vIdx].cards.count, 1)
        XCTAssertEqual(round.players[vIdx].cards[0], notJack)
    }
}

///// `play`
extension RoundTests {
    func testPlaySameSuitNotPrincipal() {
        var round = Round([
            Player(isViewer: true),
            Player(isViewer: false)
        ])
        let pCardIdx = round.deck.cards.firstIndex(of: Card(.queen(3), .spades))!
        let pCard = round.deck.cards[pCardIdx]
        round.principalCard = pCard
        
        XCTAssertEqual(round.deck.cards.count, 20)
        
        let jackOfHeartsIdx = round.deck.cards.firstIndex(of: Card(.jack(2), .hearts))!
        let jackOfHearts = round.deck.cards.remove(at: jackOfHeartsIdx)
        
        XCTAssertEqual(round.deck.cards.count, 19)
        
        let aceOfHeartsIdx = round.deck.cards.firstIndex(of: Card(.ace(11), .hearts))!
        let aceOfHearts = round.deck.cards.remove(at: aceOfHeartsIdx)
        
        XCTAssertEqual(round.deck.cards.count, 18)
        
        round.players[0].deal(aceOfHearts)
        round.players[1].deal(jackOfHearts)
        
        XCTAssertEqual(round.players[1].tricks.count, 0)
        
        let turn = round.play(aceOfHearts, for: round.viewer)!
        
        XCTAssertEqual(round.players[0].tricks.count, 1)
        XCTAssertEqual(turn.winner, round.players[0])
        XCTAssertEqual(turn.score, 13)
    }
    
    func testPlayedPrincipalVsNotPrincipal() {
        var round = Round([
            Player(isViewer: true),
            Player(isViewer: false)
        ])
        let pCardIdx = round.deck.cards.firstIndex(of: Card(.queen(3), .spades))!
        let pCard = round.deck.cards[pCardIdx]
        round.principalCard = pCard
        
        XCTAssertEqual(round.deck.cards.count, 20)
        
        let jackOfSpadesIdx = round.deck.cards.firstIndex(of: Card(.jack(2), .spades))!
        let jackOfSpades = round.deck.cards.remove(at: jackOfSpadesIdx)
        
        XCTAssertEqual(round.deck.cards.count, 19)
        
        let aceOfHeartsIdx = round.deck.cards.firstIndex(of: Card(.ace(11), .hearts))!
        let aceOfHearts = round.deck.cards.remove(at: aceOfHeartsIdx)
        
        XCTAssertEqual(round.deck.cards.count, 18)
        
        round.players[0].deal(jackOfSpades)
        round.players[1].deal(aceOfHearts)
        
        XCTAssertEqual(round.players[0].tricks.count, 0)
        
        let turn = round.play(jackOfSpades, for: round.viewer)!
        
        XCTAssertEqual(round.players[0].tricks.count, 1)
        XCTAssertEqual(turn.winner, round.players[0])
        XCTAssertEqual(turn.score, 13)
    }
    
    func testPlaySameDifferentSuitNotPrincipal() {
        var round = Round([
            Player(isViewer: true),
            Player(isViewer: false)
        ])
        let pCardIdx = round.deck.cards.firstIndex(of: Card(.queen(3), .spades))!
        let pCard = round.deck.cards[pCardIdx]
        round.principalCard = pCard
        
        XCTAssertEqual(round.deck.cards.count, 20)
        
        let jackOfHeartsIdx = round.deck.cards.firstIndex(of: Card(.jack(2), .hearts))!
        let jackOfHearts = round.deck.cards.remove(at: jackOfHeartsIdx)
        
        XCTAssertEqual(round.deck.cards.count, 19)
        
        let aceOfClubsIdx = round.deck.cards.firstIndex(of: Card(.ace(11), .clubs))!
        let aceOfClubs = round.deck.cards.remove(at: aceOfClubsIdx)
        
        XCTAssertEqual(round.deck.cards.count, 18)
        
        round.players[0].deal(jackOfHearts)
        round.players[1].deal(aceOfClubs)
        
        XCTAssertEqual(round.players[0].tricks.count, 0)
        
        let turn = round.play(jackOfHearts, for: round.viewer)!
        
        XCTAssertEqual(round.players[0].tricks.count, 1)
        XCTAssertEqual(turn.winner, round.players[0])
        XCTAssertEqual(turn.score, 13)
    }
    
    func testPlayOpponentGoesFirst() {
        var round = Round([
            Player(isViewer: true),
            Player(isViewer: false)
        ])
        let pCardIdx = round.deck.cards.firstIndex(of: Card(.queen(3), .spades))!
        let pCard = round.deck.cards[pCardIdx]
        round.principalCard = pCard
        
        XCTAssertEqual(round.deck.cards.count, 20)
        
        let jackOfHeartsIdx = round.deck.cards.firstIndex(of: Card(.jack(2), .hearts))!
        let jackOfHearts = round.deck.cards.remove(at: jackOfHeartsIdx)
        
        XCTAssertEqual(round.deck.cards.count, 19)
        
        round.players[1].deal(jackOfHearts)
        
        XCTAssertEqual(round.players[1].tricks.count, 0)
        
        let turn = round.play(jackOfHearts, for: round.opponent)
        XCTAssertNil(turn)
        
        XCTAssertEqual(round.currentTurn.opponentPlay, jackOfHearts)
        XCTAssertNil(round.currentTurn.viewerPlay)
    }
}

///// `playMarriage`
extension RoundTests {
    func testPlayMarriage() {
        var round = Round([
            Player(isViewer: true),
            Player(isViewer: false)
        ])
        round.principalCard = Card(.ace(11), .spades)
        
        var king = Card(.king(4), .hearts)
        var queen = Card(.queen(3), .hearts)
        
        king.isSelected = true
        queen.isSelected = true
        
        round.players[0].deal(queen)
        round.players[0].deal(king)
        
        XCTAssertEqual(round.players[0].marriages.count, 0)
        XCTAssertEqual(round.players[0].selectedCards.count, 2)
        
        round.playMarriage(round.viewer, cards: [queen, king])
        
        XCTAssertTrue(round.playedMarriageSuits.contains(.hearts))
        XCTAssertFalse(round.turnIsMarriage)
        XCTAssertEqual(round.players[0].marriages.count, 1)
        XCTAssertEqual(round.players[0].selectedCards.count, 1)
    }
}

//// TODO: tests for selecting the final card
