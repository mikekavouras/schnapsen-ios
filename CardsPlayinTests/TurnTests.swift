//
//  TurnTests.swift
//  CardsPlayinTests
//
//  Created by Mike Kavouras on 11/7/23.
//

import XCTest

final class TurnTests: XCTestCase {
    func testInProgressTurnSuit() {
        var turn = InProgressTurn()
        XCTAssertNil(turn.suit)
        
        turn.viewerPlay = Card(.ace(11), .hearts)
        
        XCTAssertEqual(turn.suit, .hearts)
        
        turn.opponentPlay = Card(.jack(2), .clubs)
        
        XCTAssertEqual(turn.suit, .hearts)
    }
}
