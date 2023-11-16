//
//  EndOfGameView.swift
//  CardsPlayin
//
//  Created by Mike Kavouras on 11/13/23.
//

import SwiftUI

struct EndOfGameView: View {
    let game: Game
    
    init(_ game: Game) {
        self.game = game
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 72/255.0, green: 168/255.0, blue: 96/255.0),
                    Color(red: 46/255.0, green: 139/255.0, blue: 87/255.0)
                    
                ],
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()
            VStack {
                Text("Final score")
                    .font(.headline)
                    .padding(.top, 20)
                    .foregroundStyle(.black)
                Spacer()
                HStack {
                    VStack {
                        Image("mike")
                            .resizable()
                            .frame(width: 70, height: 70)
                            .mask(Circle())
                            .shadow(radius: 2)
                        Text("\(game.viewerPoints)")
                            .bold()
                            .foregroundStyle(.black)
                    }
                    Color.clear.frame(width: 20, height: 100)
                    VStack {
                        Image("drew")
                            .resizable()
                            .frame(width: 70, height: 70)
                            .mask(Circle())
                            .shadow(radius: 2)
                        Text("\(game.opponentPoints)")
                            .foregroundStyle(.black)
                            .bold()
                    }
                }
                .buttonStyle(.borderedProminent)
                Spacer()
            }
            .frame(maxHeight: .infinity)
        }
    }
}

#Preview {
    EndOfGameView(Game())
}
