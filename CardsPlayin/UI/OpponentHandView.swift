//
//  OpponentHandView.swift
//  CardsPlayin
//
//  Created by Mike Kavouras on 11/6/23.
//

import SwiftUI

struct OpponentHandView: View {
    @ObservedObject var viewModel: GameViewModel
    let animation: Namespace.ID

    private var cardWidth: CGFloat {
        return UIScreen.main.bounds.width * 0.18
    }
    
    var round: Round {
        viewModel.game.currentRound
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 4) {
                ForEach(round.opponent.cards, id: \.self.id) { card in
                    Image(card.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(8)
                        .frame(width: cardWidth)
                        .shadow(radius: 2)
                        .offset(y: card.isSelected ? 20 : 0)
                }
            }
            .frame(width: UIScreen.main.bounds.width)
            .padding([.top, .bottom], 24)
        }
    }
}

#Preview {
    let viewModel = GameViewModel()
    viewModel.game.newRound()
    @Namespace var animation
    return OpponentHandView(viewModel: viewModel, animation: animation)
        .border(.blue)
}
