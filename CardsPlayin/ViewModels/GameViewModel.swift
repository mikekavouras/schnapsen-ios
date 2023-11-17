//
//  GameViewViewModel.swift
//  CardsPlayin
//
//  Created by Mike Kavouras on 11/8/23.
//

import Foundation
import PusherSwift

class GameViewModel: ObservableObject {
    @Published var game = Game()
    var socket: Socket = Socket.main
    
    var channel: PusherChannel? {
        didSet {
            channel?.bind(eventName: "joined", eventCallback: { [weak self] event in
                self?.handlePlayerJoined(event)
            })
            
            channel?.bind(eventName: "playCard", eventCallback: { event in
                print(event.eventName)
                print(event.data)
            })
        }
    }

    init() {
        socket.onChannelConnected = { [weak self] channel in
            self?.channel = channel
        }
    }
    
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

// Socket stuff
extension GameViewModel {
    struct PlayerJoined: Decodable {
        let playerId: String
        let needsSync: Bool
    }
    
    private func handlePlayerJoined(_ event: PusherEvent) {
        guard let dataString = event.data,
              let data = dataString.data(using: .utf8),
              let json = try? JSONDecoder().decode(PlayerJoined.self, from: data) else 
        {
            print("bad json")
            return
        }
        
        if let pIdx = game.currentRound.players.firstIndex(where: { $0.id == json.playerId }) {
            game.currentRound.players[pIdx].isOnline = true
        } else { // opponent
            let idx = game.currentRound.players.firstIndex(where: { $0 != game.viewer })!
            game.currentRound.players[idx].id = json.playerId
            game.currentRound.players[idx].isOnline = true
            
            // needs sync means we've connected to a channel explicitly and we need to sync
            // to know about the other player.
            if json.needsSync && channel != nil {
                socket.sendEvent("player:joined", data: [
                    "playerId": game.viewer.id,
                    "channelName": channel!.name,
                    "needsPing": false
                ])

            }
        }
    }
}
