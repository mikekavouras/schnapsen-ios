//
//  CardsPlayinTests.swift
//  CardsPlayinTests
//
//  Created by Mike Kavouras on 11/4/23.
//

import XCTest
import CardsPlayin

final class GameTests: XCTestCase {}

/// `points`
extension GameTests {
    /// `it "accurately calculates the viewer's remaining points"`
    func testViewerPoints() {
        var game = Game()
        XCTAssertEqual(game.hands.count, 0)
        XCTAssertEqual(game.viewerPoints, 7)
        
        game.hands.append(Hand(winner: game.viewer, points: 2))
        
        XCTAssertEqual(game.hands.count, 1)
        XCTAssertEqual(game.hands[0].winner, game.viewer)
        XCTAssertEqual(game.viewerPoints, 5)
    }
    
    /// `it "accurately calculates the opponent's remaining points`
    func testOpponentPoints() {
        var game = Game()
        XCTAssertEqual(game.hands.count, 0)
        XCTAssertEqual(game.opponentPoints, 7)
        
        game.hands.append(Hand(winner: game.opponent, points: 2))
        
        XCTAssertEqual(game.hands.count, 1)
        XCTAssertEqual(game.hands[0].winner, game.opponent)
        XCTAssertEqual(game.opponentPoints, 5)

    }
}

/// `previousWinner`
extension GameTests {
    /// `it "returns the winner of the previous round, if one exists"
    func testReturnsPreviousRoundWinnerIfOneExists() {
        var game = Game()
        game.newRound()
        game.hands.append(
            Hand(winner: game.viewer, points: 2)
        )
        game.currentRound.turns = [
            Turn(winner: game.opponent, trick: [], score: 14)
        ]
        XCTAssertEqual(game.previousWinner, game.opponent)
    }
    
    /// `it "returns the winner of the previous hand, if one exists"`
    func testReturnsPreviousHandWinnerIfOneExists() {
        var game = Game()
        game.newRound()
        game.hands.append(
            Hand(winner: game.viewer, points: 2)
        )
        XCTAssertEqual(game.previousWinner, game.viewer)
    }
    
    /// `it "return nil when there is no previous winner"`
    func testReturnsNoPreviousWinner() {
        let game = Game()
        XCTAssertNil(game.previousWinner)
    }
}

/// `newRound`
extension GameTests {
    /// `it "resets the players hand"`
    func testNewRoundResetsPlayerHands() {
        var game = Game()
        game.currentRound.players[0].tricks = [
            [Card(.jack(2), .spades), Card(.ace(11), .spades)]
        ]
        
        XCTAssertEqual(game.viewer.tricks.count, 1)
        
        game.newRound()
        
        XCTAssertEqual(game.viewer.tricks.count, 0)
    }
    
    /// `it "plays an opponent card if opponent is the previous winner"`
    func testPlaysOpponentCardIfOpponentWon() {
        var game = Game()
        game.hands.append(
            Hand(winner: game.opponent, points: 2)
        )
        
        XCTAssertNil(game.currentRound.currentTurn.opponentPlay)
        XCTAssertNil(game.currentRound.currentTurn.viewerPlay)
        
        game.newRound()
        
        XCTAssertNil(game.currentRound.currentTurn.viewerPlay)
        XCTAssertNotNil(game.currentRound.currentTurn.opponentPlay)
    }
}

/// `canCloseHand`
extension GameTests {
    /// `it "cannot close hand if the hand is closed"`
    func testCannotCloseHandIfHandIsClosed() {
        var game = Game()
        game.newRound()
        
        XCTAssertTrue(game.canCloseHand())
        
        game.currentRound.closeHand(game.viewer)
        
        XCTAssertFalse(game.canCloseHand())
    }
    
    /// `it "cannot close hand if the previous winner is opponent"`
    func testCannotCloseHandOpponentWinner() {
        var game = Game()
        game.newRound()
        game.hands.append(
            Hand(winner: game.opponent, points: 2)
        )
        game.newRound()
        
        XCTAssertFalse(game.currentRound.handIsClosed)
        XCTAssertFalse(game.canCloseHand())
    }
}

/// `afterTurn`
extension GameTests {
    /// `it "return roundOver:true if the round is over but the game is not`
    func testRoundOverIfRoundIsOverButGameIsNot() {
        var game = Game()
        game.newRound()
        game.currentRound.players[0].cards = []
        game.currentRound.players[1].cards = []
        
        let val = game.afterTurn()
        XCTAssertTrue(val.roundOver)
        XCTAssertFalse(val.gameOver)
    }
    
    /// `it "returns gameOver:true if the game is over"`
    func testGameOverIfGameIsOver() {
        var game = Game()
        game.currentRound.players[0].cards = []
        game.currentRound.players[1].cards = []
        game.hands = [
            Hand(winner: game.viewer, points: 7)
        ]
        
        let val = game.afterTurn()
        XCTAssertTrue(val.roundOver)
        XCTAssertTrue(val.gameOver)
    }
    
    /// `it "returns false, false if the round is still in progress"`
    func testAfterTurnInProgress() {
        var game = Game()
        game.newRound()
        
        let val = game.afterTurn()
        XCTAssertFalse(val.roundOver)
        XCTAssertFalse(val.gameOver)
    }
}

/// `playMarriage`
extension GameTests {
    /// `it "plays the marriage for the player"`
    func testPlayMarriagePlaysMarriage() {
        var game = Game()
        game.newRound()
        
        let queen = Card(.queen(3), .spades)
        let king = Card(.king(4), .spades)
        
        game.currentRound.players[0].cards = [queen, king]
        
        XCTAssertEqual(game.viewer.marriages.count, 0)
        
        _ = game.playMarriage(game.viewer, cards: [queen, king])
        
        XCTAssertEqual(game.viewer.marriages.count, 1)
    }
    
    /// `it "ends the round if the round is over"`
    func testPlayMarriageRoundIsOverIfRoundIsOver() {
        var game = Game()
        game.newRound()
        game.currentRound.players[0].tricks = [
            [Card(.ace(11), .spades), Card(.ten(10), .spades)],
            [Card(.ace(11), .spades), Card(.ten(10), .spades)],
            [Card(.ace(11), .spades), Card(.ten(10), .spades)],
            [Card(.ace(11), .spades), Card(.ten(10), .spades)]
        ]
        
        let queen = Card(.queen(3), .spades)
        let king = Card(.king(4), .spades)
        game.currentRound.players[0].cards = [queen, king]
        
        let result = game.playMarriage(game.viewer, cards: [queen, king])
        
        XCTAssertTrue(result.roundOver)
        XCTAssertFalse(result.gameOver)
    }
    
    /// `it "ends the game if the round is over"`
    func testPlayMarriageGameIsOverIfGameIsOver() {
        var game = Game()
        game.newRound()
        game.currentRound.players[0].tricks = [
            [Card(.ace(11), .spades), Card(.ten(10), .spades)],
            [Card(.ace(11), .spades), Card(.ten(10), .spades)],
            [Card(.ace(11), .spades), Card(.ten(10), .spades)],
            [Card(.ace(11), .spades), Card(.ten(10), .spades)]
        ]
        
        game.hands = [
            Hand(winner: game.viewer, points: 4)
        ]
        
        let queen = Card(.queen(3), .spades)
        let king = Card(.king(4), .spades)
        game.currentRound.players[0].cards = [queen, king]
        
        let result = game.playMarriage(game.viewer, cards: [queen, king])
        
        XCTAssertTrue(result.roundOver)
        XCTAssertTrue(result.gameOver)
    }

}
