//
//  Socket.swift
//  CardsPlayin
//
//  Created by Mike Kavouras on 11/17/23.
//

import Foundation
import PusherSwift

class Socket: ObservableObject, PusherDelegate {
    static let main = Socket()
    var connectionState: ConnectionState = .disconnected
    @Published var channel: PusherChannel? {
        didSet {
            onChannelConnected?(channel)
        }
    }
    var onChannelConnected: ((PusherChannel?)  -> Void)?
    
    private var pusher: Pusher!
    
    init() {
        let options = PusherClientOptions(
          host: .cluster("us2")
        )

        pusher = Pusher(key: "2f3d8f8bf1da7a2f987d", options: options)
        pusher.delegate = self
        pusher.connect()
    }
    
    func createChannel(`for` player: Player) {
        let name = Int.random(in: 10000...99999)
        channel = pusher.subscribe("schnapsen-\(name)")
        sendEvent("player:joined", data: [
            "playerId": player.id,
            "channelName": channel!.name
        ])
    }
    
    func subscribe(channelName: String) {
        channel = pusher.subscribe(channelName: channelName)
    }
    
    func unsubscribe() {
        channel = nil
    }
    
    func changedConnectionState(from old: ConnectionState, to new: ConnectionState) {
        if new == .disconnected {
            print("disconnected")
            channel = nil
        }
        connectionState = new
    }
    
    func debugLog(message: String) {
//        print(message)
    }
    
    func sendEvent(_ name: String, data: [String:Any]) {
        let f: [String:Any] = [
            "event": name,
            "payload": data // TODO: update API
        ]
        
        guard let json = try? JSONSerialization.data(withJSONObject: f) else {
            print("bad json")
            return
        }
        
        let url = URL(string: "https://2f32c7c7c488.ngrok.app/events")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        request.httpBody = json

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
        }

        task.resume()
    }
}
