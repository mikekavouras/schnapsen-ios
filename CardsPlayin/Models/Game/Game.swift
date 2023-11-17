//
//  Game.swift
//  CardsPlayin
//
//  Created by Mike Kavouras on 11/3/23.
//

import Foundation
import PusherSwift

enum GameType {
    case schnapsen
}

struct Game {
    var currentRound: Round
    
    var viewer: Player { currentRound.viewer }
    var opponent: Player { currentRound.opponent }
    
    var hands: [Hand] = []
    var previousHand: Hand? { hands.last }
    var viewerHands: [Hand] { hands.filter { $0.winner == viewer } }
    var opponentHands: [Hand] { hands.filter { $0.winner == opponent } }
    
    var viewerPoints: Int {
        let points = 7 - (viewerHands.map { $0.points }.reduce(0, +))
        return [0, points].max()!
    }
    var opponentPoints: Int {
        let points = 7 - (opponentHands.map { $0.points }.reduce(0, +))
        return [0, points].max()!
    }
        
    var previousWinner: Player? {
        if let turn = currentRound.previousTurn {
            return turn.winner
        }
        
        if let hand = hands.last {
            return hand.winner
        }
        
        return nil
    }
    
    
    init() {
        currentRound = Round([
            Player(isViewer: true),
            Player(isViewer: false),
        ])
    }
    
    mutating func newRound() {
        var players = currentRound.players
        players[0].resetHand()
        players[1].resetHand()
        
        currentRound = Round(players)
        currentRound.deal()
        
        if let previousWinner = previousWinner,
           previousWinner == opponent {
            currentRound.createOpponentPlay()
        }
    }

    func canCloseHand() -> Bool {
        if currentRound.handIsClosed { return false }
        if let previousWinner = previousWinner {
            if previousWinner == currentRound.opponent {
                return false
            }
        }
        
        return true
    }
    
    mutating func afterTurn() -> (roundOver: Bool, gameOver: Bool) {
        guard !currentRound.isOver() else {
            endRound()
            return (true, isOver())
        }

        currentRound.afterTurn()
        
        guard let previousTurn = currentRound.previousTurn else {
            return (false, false)
        }
        
        if previousTurn.winner == opponent {
            currentRound.createOpponentPlay()
        }
        
        return (false, false)
    }
    
    mutating func playMarriage(_ player: Player, cards: [Card]) -> (roundOver: Bool, gameOver: Bool) {
        currentRound.playMarriage(player, cards: cards)
        
        guard !currentRound.isOver() else {
            endRound()
            return (true, isOver())
        }
                
        return (false, false)
    }
    
    mutating private func endRound() {
        if let closedHand = currentRound.closedHand {
            let iIdx = currentRound.players.firstIndex(of: closedHand.initiator)!
            if currentRound.players[iIdx].score >= 66 {
                let points = closedHand.points()
                let hand = Hand(winner: closedHand.initiator, points: points)
                hands.append(hand)
            } else {
                let oIdx = currentRound.players.firstIndex(where: { $0 != closedHand.initiator })!
                let points = closedHand.points()
                let hand = Hand(winner: currentRound.players[oIdx], points: points)
                hands.append(hand)
            }
            return
        }
        
        let viewer = currentRound.viewer
        let opponent = currentRound.opponent
        
        // Both players got over 66; wash
        if viewer.score >= 66 && opponent.score >= 66 {
            return
        }
        
        // Neither player got 66; wash
        if viewer.score < 66 && opponent.score < 66 {
            return
        }
        
        let winner = viewer.score >= 66 ? viewer : opponent
        let loser = currentRound.players.first(where: { $0 != winner })!
        let points = pointsForScore(loser.score)
        
        hands.append(Hand(winner: winner, points: points))
    }
    
    private func pointsForScore(_ score: Int) -> Int {
        if score >= 66 {
            return 0
        } else if score >= 33 {
            return 1
        } else if score > 0 {
            return 2
        }
        
        return 3
    }
    
    mutating private func isOver() -> Bool {
        guard currentRound.isOver() else { return false }
        return (viewerPoints <= 0 || opponentPoints <= 0)
    }
    
    private func endGame() {
        
    }
}
