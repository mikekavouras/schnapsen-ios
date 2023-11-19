//
//  Socket.swift
//  CardsPlayin
//
//  Created by Mike Kavouras on 11/17/23.
//

import Foundation
import PusherSwift

enum Event: String {
    case joinedRoom = "joined-room"
    case leftRoom = "left-room"
    case playedCard = "played-card"
}

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
    
    func createChannel(_ player: Player) {
        let name = Int.random(in: 10000...99999)
        subscribe(player, to: "\(name)", isHost: true)
    }
    
    func subscribe(_ player: Player, `to` channelName: String, isHost: Bool, needsSync: Bool = false) {
        channel = pusher.subscribe(channelName: channelName)
        sendEvent(.joinedRoom(player.id, channelName, needsSync, isHost))
    }
    
    func unsubscribe(_ player: Player, from channelName: String) {
        channel = nil
        sendEvent(.leftRoom(player.id, channelName, player.isHost))
    }
    
    func changedConnectionState(from old: ConnectionState, to new: ConnectionState) {
        if new == .disconnected {
            print("disconnected")
        }
        connectionState = new
    }
    
    func debugLog(message: String) {
//        print(message)
    }
    
    func sendEvent(_ r: Router) {
        let data: [String: Any] = [
            "channelName": channel?.name ?? "",
            "socketId": pusher.connection.socketId ?? ""
        ]
        
        let req: [String:Any] = ["data": data.merging(r.params, uniquingKeysWith: { _, theirs in theirs })]
        
        guard let json = try? JSONSerialization.data(withJSONObject: req) else {
            print("bad json")
            return
        }
        
        var request = URLRequest(url: r.url)
        for (k, v) in r.headers {
            request.setValue(v, forHTTPHeaderField: k)
        }
        request.httpMethod = r.method
        request.httpBody = json

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
        }

        task.resume()
    }
}


enum Router {
    case joinedRoom(String, String, Bool, Bool)
    case leftRoom(String, String, Bool)
    
    var url: URL {
        let str = switch self {
        case .joinedRoom:
            Event.joinedRoom.rawValue
        case .leftRoom:
            Event.leftRoom.rawValue
        }
        
        return URL(string: "https://c00138812c38.ngrok.app/events/\(str)")!
    }
    
    var method: String {
        return "POST"
    }
    
    var headers: [String:String] {
        ["Accept": "application/json"]
    }
    
    var params: [String:Any] {
        switch self {
        case .joinedRoom(let playerId, let channelName, let needsSync, let isHost):
            return [
                "playerId": playerId,
                "channelName": channelName,
                "needsSync": needsSync,
                "isHost": isHost,
            ]
        case .leftRoom(let playerId, let channelName, let isHost):
            return [
                "isHost": isHost,
                "channelName": channelName,
                "playerId": playerId
            ]
        }
    }
    
}
