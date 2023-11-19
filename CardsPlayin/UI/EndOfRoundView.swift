//
//  EndOfRoundView.swift
//  CardsPlayin
//
//  Created by Mike Kavouras on 11/11/23.
//

import SwiftUI

struct EndOfRoundView: View {
    let round: Round
    
    @Environment(\.dismiss) private var dismiss
    
    var viewer: Player { round.viewer }
    var opponent: Player { round.opponent }
    
    init(_ round: Round) {
        self.round = round
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
            )
            .ignoresSafeArea()
            VStack {
                Text("Round score")
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
                        Text("\(viewer.score)")
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
                        if #available(iOS 16, *) {
                            Text("\(opponent.score)")
                                .foregroundStyle(.black)
                                .bold()
                        } else {
                            Text("\(opponent.score)")
                                .foregroundStyle(.black)
                        }
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
    var viewer = Player(isViewer: true)
    viewer.tricks = [
        [Card(.ace(11), .spades), Card(.jack(2), .spades)]
    ]
    var opponent = Player(isViewer: false)
    let round = Round([
        viewer,
        opponent
    ])
    return EndOfRoundView(round)
}
