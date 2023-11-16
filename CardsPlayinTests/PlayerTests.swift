//
//  PlayerTest.swift
//  CardsPlayinTests
//
//  Created by Mike Kavouras on 11/6/23.
//

import XCTest

final class PlayerTests: XCTestCase {
    func testScore() {
        var player = Player(isViewer: true)
        player.tricks = [
            [Card(.ace(11), .spades), Card(.jack(2), .spades)]
        ]
        
        XCTAssertEqual(player.score, 13)
        
        player.marriages = [
            Marriage(suit: .hearts, isRoyal: false)
        ]
        
        XCTAssertEqual(player.score, 33)
    }
    
    func testHasSuit() {
        var player = Player(isViewer: true)
        player.cards = [
            Card(.jack(2), .clubs)
        ]
        
        XCTAssertFalse(player.hasSuit(.hearts))
        XCTAssertTrue(player.hasSuit(.clubs))
    }
    
    func testResetHand() {
        var player = Player(isViewer: false)
        player.cards = [Card(.jack(2), .spades)]
        player.marriages = [Marriage(suit: .clubs, isRoyal: true)]
        player.tricks = [
            [Card(.jack(2), .spades), Card(.ace(11), .spades)]
        ]
        
        XCTAssertEqual(player.cards.count, 1)
        XCTAssertEqual(player.marriages.count, 1)
        XCTAssertEqual(player.tricks.count, 1)
        
        player.resetHand()
        
        XCTAssertEqual(player.cards.count, 0)
        XCTAssertEqual(player.marriages.count, 0)
        XCTAssertEqual(player.tricks.count, 0)
    }
}
