//
//  ViewerHandView.swift
//  CardsPlayin
//
//  Created by Mike Kavouras on 11/6/23.
//

import SwiftUI

struct ViewerHandView: View {
    @ObservedObject var viewModel: GameViewModel
    let animation: Namespace.ID
    
    var round: Round {
        viewModel.game.currentRound
    }

    var body: some View {
        VStack {
            HStack(spacing: 4) {
                ForEach(round.viewer.cards, id: \.self.id) { card in
                    CardView(
                        CardViewModel(card, tapHandler: viewModel.handleTap)
                    )
                    .matchedGeometryEffect(id: card.id, in: animation)
                }
            }
            .frame(width: UIScreen.main.bounds.width)
            .padding([.top, .bottom], 24)
        }
    }
}

#Preview {
    @Namespace var animation
    let viewModel = GameViewModel()
    viewModel.game.newRound()
    return ViewerHandView(viewModel: viewModel, animation: animation)
}
