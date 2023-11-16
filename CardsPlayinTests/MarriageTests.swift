//
//  MarriageTests.swift
//  CardsPlayinTests
//
//  Created by Mike Kavouras on 11/6/23.
//

import XCTest

final class MarriageTests: XCTestCase {
    func testPoints() {
        let marriage = Marriage(suit: .hearts, isRoyal: false)
        XCTAssertEqual(marriage.points, 20)
        
        let royalMarriage = Marriage(suit: .hearts, isRoyal: true)
        XCTAssertEqual(royalMarriage.points, 40)
    }
    
    /// `it "is valid when the marriage is valid"`
    func testIsValidWhenValid() {
        let queen = Card(.queen(3), .spades)
        let king = Card(.king(4), .spades)
        
        var round = Round([
            Player(isViewer: true),
            Player(isViewer: false)
        ])
        round.players[0].cards = [queen, king]
        
        let p = PotentialMarriage(player: round.viewer, cards: [queen, king])
        XCTAssertTrue(p.isValid(in: round))
    }
    
    /// `it "is invalid when the cards aren't eligible"`
    func testIsInvalidWhenIneligibleCards() {
        let queen = Card(.queen(3), .spades)
        let king = Card(.king(4), .hearts)
        
        var round = Round([
            Player(isViewer: true),
            Player(isViewer: false)
        ])
        round.players[0].cards = [queen, king]
        
        let p = PotentialMarriage(player: round.viewer, cards: [queen, king])
        XCTAssertFalse(p.isValid(in: round))
    }

    /// `it "is invalid when the marriage has already been played"`
    func testIsInvalidWhenMarriageHasBeenPlayed() {
        let queen = Card(.queen(3), .spades)
        let king = Card(.king(4), .spades)
        
        var round = Round([
            Player(isViewer: true),
            Player(isViewer: false)
        ])
        round.players[0].cards = [queen, king]
        round.players[0].marriages = [
            Marriage(suit: .spades, isRoyal: false)
        ]
        
        let p = PotentialMarriage(player: round.viewer, cards: [queen, king])
        XCTAssertFalse(p.isValid(in: round))
    }
    
    /// `it "is invalid when the previous winner is opponent`
    func testIsInvalidWhenOpponentIsPreviousWinner() {
        let queen = Card(.queen(3), .spades)
        let king = Card(.king(4), .spades)
        
        var round = Round([
            Player(isViewer: true),
            Player(isViewer: false)
        ])
        round.players[0].cards = [queen, king]
        
        round.turns = [
            Turn(
                winner: round.opponent,
                trick: [],
                score: 10
            )
        ]
        
        let p = PotentialMarriage(player: round.viewer, cards: [queen, king])
        XCTAssertFalse(p.isValid(in: round))
    }
    
    /// `it "is invalid if the cards aren't in the player's hand`
    func testIsInvalidUnlessCardsInHand() {
        let queen = Card(.queen(3), .spades)
        let king = Card(.king(4), .spades)
        
        var round = Round([
            Player(isViewer: true),
            Player(isViewer: false)
        ])
        round.players[0].cards = []
        
        let p = PotentialMarriage(player: round.viewer, cards: [queen, king])
        XCTAssertFalse(p.isValid(in: round))
    }
}
