//
//  ContentView.swift
//  CardsPlayin
//
//  Created by Mike Kavouras on 7/26/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var socket = Socket.main
    var body: some View {
        GameView()
            .environmentObject(socket)
    }
}

#Preview {
    ContentView()
}
