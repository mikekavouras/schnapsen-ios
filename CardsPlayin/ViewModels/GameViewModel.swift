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
    
    var opponentDidDisconnect = false
    var socket: Socket = Socket.main
    
    var channel: PusherChannel? {
        didSet {
            channel?.bind(eventName: Event.joinedRoom.rawValue, eventCallback: { [weak self] event in
                self?.handlePlayerJoined(event)
            })
            
            channel?.bind(eventName: Event.leftRoom.rawValue, eventCallback: { [weak self] event in
                self?.handlePlayerLeft(event)
//                self?.socket.disconnect()
            })
            
            channel?.bind(eventName: "playedCard", eventCallback: { event in
                print(event.eventName)
                print(event.data)
            })
        }
    }

    init(_ game: Game? = nil) {
        _game = Published(wrappedValue: game ?? Game())
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
        return game.currentRound.play(card, for: player, on: channel)
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
        let isHost: Bool
    }
    
    private func handlePlayerJoined(_ event: PusherEvent) {
        guard let dataString = event.data,
              let data = dataString.data(using: .utf8),
              let json = try? JSONDecoder().decode(PlayerJoined.self, from: data) else 
        {
            print("Failed to parse json: \(event.data?.debugDescription)")
            return
        }
        
        print("player joined")
        
        // If the player who joined (event.playerId) is the viewer, set the viewer's
        // isOnline status to true and set their isHost status to true. The end.
        //
        // If the player who joined is the opponent, set their isOnline status to true
        // and update the local game opponent player.id to sync with the player on another
        // device. Since the opponent won't know that the viewer is connected (viewer connected first)
        // we'll send one more request from the viewer's device to advertise their online status.
        // At this point both players are in sync and participating in a shared game (channel).
        if game.viewer.id == json.playerId {
            let pIdx = game.currentRound.players.firstIndex(where: { $0.id == json.playerId })!
            game.currentRound.players[pIdx].isOnline = true
            game.currentRound.players[pIdx].isHost = json.isHost
        } else {
            let idx = game.currentRound.players.firstIndex(where: { $0 != game.viewer })!
            game.currentRound.players[idx].id = json.playerId
            game.currentRound.players[idx].isOnline = true
            
            // needsSync means we've connected to a channel explicitly and we need to sync
            // to know about the other player.
            if json.needsSync && channel != nil {
                socket.sendEvent(.joinedRoom(game.viewer.id, channel!.name, false, false))
            }
        }
    }
    
    struct PlayerLeft: Decodable {
        let isHost: Bool
        let playerId: String
        let channelName: String
    }
    
    private func handlePlayerLeft(_ event: PusherEvent) {
        guard let dataString = event.data,
              let data = dataString.data(using: .utf8),
              let json = try? JSONDecoder().decode(PlayerLeft.self, from: data) else
        {
            return
        }
        
        print("player left")
        
        if game.viewer.id == json.playerId {
            let pIdx = game.currentRound.players.firstIndex(where: { $0.id == json.playerId })!
            game.currentRound.players[pIdx].isOnline = false
            game.currentRound.players[pIdx].isHost = false
        } else {
            let oIdx = game.currentRound.players.firstIndex(where: { $0 != game.viewer })!
            game.currentRound.players[oIdx].isOnline = false
//            if !game.viewer.isHost {
//                Socket.main.unsubscribe(game.viewer, from: json.channelName)
//            }
            opponentDidDisconnect.toggle()
        }
    }
}
