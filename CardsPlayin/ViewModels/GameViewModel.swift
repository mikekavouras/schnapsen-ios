//
//  GameViewViewModel.swift
//  CardsPlayin
//
//  Created by Mike Kavouras on 11/8/23.
//

import Foundation

class GameViewModel: ObservableObject {
    @Published var game = Game()
    
    func newGame() {
        game = Game()
        game.newRound()
    }
    
    var turnIsMarriage: Bool {
        return game.currentRound.turnIsMarriage
    }
    
    func handleTap(_ card: Card) -> Bool {
        return game.currentRound.didTap(card)
    }
    
    func didTapPrincipalCard() {
        if game.currentRound.timeForViewerToGrabTheLastCard {
            game.currentRound.chooseFinalCard(game.currentRound.principalCard!)
        } else {
            game.currentRound.capturePrincipalCard(game.viewer)
        }
    }
    
    func didTapDeck(_ card: Card, _ callback: () -> Void) {
        if game.currentRound.timeForViewerToGrabTheLastCard {
            game.currentRound.chooseFinalCard(card)
        } else {
            callback()
        }
    }
    
    func play(_ card: Card, `for` player: Player) -> Turn? {
        return game.currentRound.play(card, for: player)
    }
    
    func afterTurn() -> (roundOver: Bool, gameOver: Bool) {
        return game.afterTurn()
    }
    
    func closeHand() {
        game.currentRound.closeHand(game.viewer)
    }
    
    func playMarriage(_ player: Player) -> (roundOver: Bool, gameOver: Bool) {
        return game.playMarriage(player, cards: player.selectedCards)
    }
    
    func createOpponentPlay() {
        game.currentRound.createOpponentPlay()
    }
    
    func canCloseHand() -> Bool {
        return game.canCloseHand()
    }    
}

