//
//  GameView.swift
//  CardsPlayin
//
//  Created by Mike Kavouras on 7/26/23.
//

import SwiftUI
import PusherSwift

struct GameView: View {
    @Namespace private var animation
    
    @StateObject var viewModel = GameViewModel()
    @StateObject var socket = Socket.main
    
    @State private var roundIsOver: Bool = false
    @State private var gameIsOver: Bool = false
    @State private var showLastTrick: Bool = false
    @State private var showUserSettings: Bool = false
    @State private var showCloseHandConfirmation = false
    
    var viewer: Player {
        return viewModel.game.currentRound.viewer
    }
    
    var opponent: Player {
        return viewModel.game.currentRound.opponent
    }
        
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ZStack {
                    Image("mike")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .mask(Circle())
                        .onTapGesture {
                            showUserSettings.toggle()
                        }
                    if viewer.isOnline {
                        Circle()
                            .frame(width: 4, height: 4)
                            .offset(y: 32)
                            .foregroundStyle(.green)
                    }
                    if viewModel.game.previousWinner == viewer {
                        Circle()
                            .stroke(Color.yellow, lineWidth: 2.0)
                            .frame(width: 50, height: 50)
                    }
                        
                }
                HStack {
                    Text("\(viewModel.game.viewerPoints)")
                        .foregroundColor(.white)
                        .bold()
                    Spacer()
                    Text("\(viewModel.game.opponentPoints)")
                        .foregroundColor(.white)
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding([.leading, .trailing])
                ZStack {
                    Image("drew")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .mask(Circle())
                    if opponent.isOnline {
                        Circle()
                            .frame(width: 4, height: 4)
                            .offset(y: 32)
                            .foregroundStyle(.green)
                    }
                    if viewModel.game.previousWinner == opponent {
                        Circle()
                            .stroke(Color.yellow, lineWidth: 2.0)
                            .frame(width: 50, height: 50)
                    }

                }
            }
            .padding([.leading, .trailing, .top])
            ZStack {
                Group {
                    LinearGradient(
                        colors: [
                            Color(red: 10/255.0, green: 80/255.0, blue: 235/255.0),
                            Color(red: 0/255.0, green: 90/255.0, blue: 195/255.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(maxHeight: .infinity).cornerRadius(20)
                }.frame(maxHeight: .infinity).padding([.top, .bottom], 50)

                VStack(spacing: 0) {
                    OpponentHandView(viewModel: viewModel, animation: animation)
                        .offset(y: -50)

                    GameActionView(
                        viewModel: viewModel,
                        showCloseHandConfirmation: $showCloseHandConfirmation,
                        animation: animation
                    ).frame(maxHeight: .infinity)
                    
                    ViewerHandView(viewModel: viewModel, animation: animation)
                        .offset(y: 50)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding([.top, .bottom], 50)
            }
            ActionButtonView(
                viewModel: viewModel,
                roundIsOver: $roundIsOver,
                gameIsOver: $gameIsOver,
                showLastTrick: $showLastTrick
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 20/255.0, green: 20/255.0, blue: 20/255.0))
        .alert(Text("Close hand?"), isPresented: $showCloseHandConfirmation) {
            Button(role: .destructive, action: closeHand) {
                Text("Close hand")
            }
        }
        .sheet(isPresented: $roundIsOver, onDismiss: {
            withAnimation(Animation.linear.delay(0.3)) {
                viewModel.game.newRound()
            }
        }, content: {
            if #available(iOS 16, *) {
                EndOfRoundView(viewModel.game.currentRound)
                    .presentationDetents([.medium])
            } else {
                EndOfRoundView(viewModel.game.currentRound)
            }
        })
        .sheet(isPresented: $gameIsOver, onDismiss: {
            withAnimation(.linear(duration: 0.3)) {
                viewModel.newGame()
            }
        }, content: {
            if #available(iOS 16, *) {
                EndOfGameView(viewModel.game)
                    .presentationDetents([.medium])
            } else {
                EndOfGameView(viewModel.game)
            }
        })
        .sheet(isPresented: $showLastTrick, content: {
            if #available(iOS 16.0, *) {
                LastTrickView(round: viewModel.game.currentRound)
                    .presentationDetents([.medium])
            } else {
                LastTrickView(round: viewModel.game.currentRound)
            }
        })
        .sheet(isPresented: $showUserSettings, content: {
            UserSettingsView(socket: socket, player: viewer)
        })
        .alert("Your opponent has left the game", isPresented: $viewModel.opponentDidDisconnect, actions: {
            Button("Leave game", role: .destructive) {
                viewModel.newGame()
            }
        })
        .onAppear {
            viewModel.game.newRound()
        }
    }

    private func closeHand() {
        viewModel.closeHand()
    }
}

#Preview {
    GameView()
}
