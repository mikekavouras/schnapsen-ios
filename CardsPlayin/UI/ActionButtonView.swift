//
//  ActionButtonView.swift
//  CardsPlayin
//
//  Created by Mike Kavouras on 11/8/23.
//

import SwiftUI

struct ActionButtonView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var roundIsOver: Bool
    @Binding var gameIsOver: Bool
    @Binding var showLastTrick: Bool
    
    var selectedCard: Card? { viewer.selectedCards.first }
    
    var turnIsMarriage: Bool { viewModel.turnIsMarriage}
    
    var viewer: Player { viewModel.game.currentRound.viewer }
    var opponent: Player { viewModel.game.currentRound.opponent }
    
    var body: some View {
        HStack {
            ZStack {
                TrickStack(
                    tricks: (viewer.tricks + opponent.tricks),
                    showLastTrick: $showLastTrick
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
                
                HStack {
                    if let selectedCard {
                        HStack {
                            Spacer()
                            if turnIsMarriage {
                                Button(action: {
                                    withAnimation(Animation.easeOut(duration: 0.16)) {
                                        playMarriage()
                                    }
                                }, label: {
                                    Text("Play marriage")
                                        .bold()
                                })
                                .padding()
                                .background(LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom))
                                .foregroundStyle(.black)
                                .cornerRadius(4)
                            } else {
                                Button(action: {
                                    withAnimation {
                                        playCard()
                                    }
                                }, label: {
                                    Text("Play")
                                        .bold()
                                    Text("\(String(describing: selectedCard))")
                                        .bold()
                                        .foregroundColor(.black)
                                })
                                .padding()
                                .background(LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom))
                                .foregroundStyle(.black)
                                .cornerRadius(4)
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private  func playCard() {
        guard let selectedCard else { return }
    
        let turn = viewModel.play(selectedCard, for: viewer)
        
        if let _ = turn {
            withAnimation(Animation.linear.delay(1.3)) {
                let status = viewModel.afterTurn()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(Animation.default) {
                        if status.gameOver {
                            gameIsOver = true
                        } else {
                            roundIsOver = status.roundOver
                        }
                    }
                }
            }
        }
     }
     
     private func playMarriage() {
         let status = viewModel.playMarriage(viewer)
         DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
             withAnimation {
                 if status.gameOver {
                     gameIsOver = true
                 } else {
                     roundIsOver = status.roundOver
                 }
             }
         }
     }
}

struct TrickStack: View {
    let tricks: [[Card]]
    @Binding var showLastTrick: Bool
    
    var body: some View {
        if tricks.isEmpty {
            Image("empty")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40)
                .shadow(radius: 2)
        } else {
            Button(action: {
                showLastTrick.toggle()
            }, label: {
                ZStack {
                    Image("back")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40)
                        .cornerRadius(3)
                        .offset(x: -4)
                        .rotationEffect(.degrees(-8))
                        .shadow(radius: 2)
                        
                    Image("back")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40)
                        .cornerRadius(3)
                        .rotationEffect(.degrees(3))
                        .shadow(radius: 2)
                }
            })
        }
    }
}

#Preview {
    let viewModel = GameViewModel()
    viewModel.game.currentRound.players[0].tricks = [
        [Card(.jack(2), .diamonds), Card(.ace(11), .diamonds)]
    ]
    var viewerCard = Card(.jack(2), .spades)
    viewerCard.isSelected = true
    viewModel.game.currentRound.players[0].cards = [viewerCard]
    return ActionButtonView(
        viewModel: viewModel,
        roundIsOver: .constant(false),
        gameIsOver: .constant(false),
        showLastTrick: .constant(false)
    )
}
