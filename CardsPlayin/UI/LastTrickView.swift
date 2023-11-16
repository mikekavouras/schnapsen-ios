//
//  LastTrickView.swift
//  CardsPlayin
//
//  Created by Mike Kavouras on 11/11/23.
//

import SwiftUI

struct LastTrickView: View {
    let round: Round
    var trick: [Card]? {
        guard var t = round.previousTurn?.trick else { return nil }
        t[0].isFlipped = false
        t[1].isFlipped = false
        
        return t
    }
    
    var points: Int {
        guard let trick else { return 0 }
        return [trick[0], trick[1]]
            .compactMap { $0 }
            .map { $0.rank.value }
            .reduce(0, +)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 255/255.0, green:216/255.0, blue: 90/255.0),
                    Color(red: 240/255.0, green: 180/255.0, blue: 90/255.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()
            if let trick = trick {
                VStack {
                    ZStack {
                        Image(trick[1].imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 130)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .offset(x: 50, y: -40)
                        
                            .rotationEffect(.degrees(18))
                        Image(trick[0].imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 130)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .offset(x: -50)
                            .rotationEffect(.degrees(-8))
                    }
                    Text("\(points) points")
                        .bold()
                        .padding(.top, 30)
                        .foregroundColor(.black)
                }

            }
        }
    }
}

#Preview {
    let viewModel = GameViewModel()
    let viewer = viewModel.game.currentRound.viewer
    viewModel.game.currentRound.turns = [
        Turn(
            winner: viewer,
            trick: [
                Card(.ace(11), .spades),
                Card(.queen(3), .spades)
            ],
            score: 14
        )
    ]
    return LastTrickView(round: viewModel.game.currentRound)
}
