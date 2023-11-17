//
//  UserSettingsView.swift
//  CardsPlayin
//
//  Created by Mike Kavouras on 11/16/23.
//

import SwiftUI
import PusherSwift

struct UserSettingsView: View {
    @ObservedObject var socket: Socket
    @State private var channelName: String = ""
    
    var player: Player
    var channel: PusherChannel? { socket.channel }
    
    init(player: Player, socket: Socket) {
        self.player = player
        self.socket = socket
    }
    
    var body: some View {
        if socket.connectionState != .connected {
            Text("Can't connect to server")
        } else {
            if let channel {
                Button(action: {
                    socket.unsubscribe()
                }, label: { Text("Disconnect") })
                
                Text(channel.name)
                    .padding()
                    .cornerRadius(14)
                    .contextMenu {
                        Button {
                            UIPasteboard.general.string = channel.name
                        } label: {
                            Label("Copy", systemImage: "clipboard")
                        }
                    }
            } else {
                Button(action: {
                    socket.createChannel(for: player)
                }, label: {
                    Text("Connect")
                })
                TextField("Ender a game code", text: $channelName)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
                    .padding(.top, 50)
                Button(action: {
                    submitCode()
                }, label: {
                    Text("Submit")
                })
                .padding()
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    private func submitCode() {
        socket.subscribe(channelName: channelName)
        socket.sendEvent("player:joined", data: [
            "playerId": player.id,
            "channelName": channelName,
            "needsPing": true
        ])
    }
}

#Preview {
    let player = Player(isViewer: true)
    return UserSettingsView(
        player: player,
        socket: Socket()
    )
}
