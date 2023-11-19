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
    
    var body: some View {
        if let channel {
            Button(action: {
                socket.unsubscribe(player, from: channel.name)
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
                createChannelAndConnect()
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
    
    func createChannelAndConnect() {
        socket.createChannel(player)
    }
    
    private func submitCode() {
        socket.subscribe(player, to: channelName, isHost: false, needsSync: true)
    }
}

#Preview {
    let player = Player(isViewer: true)
    return UserSettingsView(
        socket: Socket.main,
        player: player
    )
}
