//
//  Turn.swift
//  CardsPlayin
//
//  Created by Mike Kavouras on 11/6/23.
//

import Foundation

struct Turn {
    let winner: Player
    let trick: [Card]
    let score: Int
}


struct InProgressTurn {
    var viewerPlay: Card? {
        didSet {
            guard let play = viewerPlay else { return }
            if opponentPlay == nil {
                suit = play.suit
            }
        }
    }
    var opponentPlay: Card? {
        didSet {
            guard let play = opponentPlay else { return }
            if viewerPlay == nil {
                suit = play.suit
            }
        }
    }
    var marriage: Marriage?
    var suit: Suit?
}
