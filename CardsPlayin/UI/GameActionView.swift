//
//  GameActionView.swift
//  CardsPlayin
//
//  Created by Mike Kavouras on 11/6/23.
//

import SwiftUI

struct GameActionView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var showCloseHandConfirmation: Bool
    var animation: Namespace.ID
    var cardWidth: CGFloat {
        return UIScreen.main.bounds.width * 0.18
    }
    
    var round: Round {
        viewModel.game.currentRound
    }

    var body: some View {
        HStack(alignment: .center) {
            ZStack {
                ForEach(Array(round.deck.cards.enumerated()), id: \.element.id) { (idx, card) in
                    Image(card.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: cardWidth)
                        .cornerRadius(8)
                        .shadow(radius: 2)
                        .offset(x: CGFloat(idx) * 1)
                        .onTapGesture {
                            withAnimation {
                                viewModel.didTapDeck(card) {
                                    confirmCloseHand()
                                }
                            }
                        }
                }
            }
            if let pCard = round.principalCard {
                Image(pCard.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: cardWidth)
                    .cornerRadius(8.0)
                    .shadow(radius: 2)
                    .padding(.leading, 10)
                    .onTapGesture {
                        withAnimation {
                            viewModel.didTapPrincipalCard()
                        }
                    }
                    .matchedGeometryEffect(id: pCard.id, in: animation)
            }
            HStack {
                VStack {
                    if let oCard = round.currentTurn.opponentPlay {
                        Image(oCard.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(8.0)
                            .frame(width: cardWidth)
                            .shadow(radius: 2)
                    } else {
                        Image("empty")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: cardWidth)
                            .shadow(radius: 2)
                    }
                    if let vCard = round.currentTurn.viewerPlay {
//                        Group {
                            Image(vCard.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: cardWidth)
                                .cornerRadius(8.0)
                                .shadow(radius: 2)
//                                .offset(y: -24)
                                .matchedGeometryEffect(id: vCard.id, in: animation)
//                        }.offset(y: 24)
                    } else {
                        Image("empty")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: cardWidth)
                            .shadow(radius: 2)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(alignment: .leading)
        .padding([.leading, .trailing], 10)
    }
    
    private func confirmCloseHand() {
        guard viewModel.canCloseHand() else { return }
        
        withAnimation {
            showCloseHandConfirmation.toggle()
        }
    }
}

#Preview {
    @Namespace var animation
    let viewModel = GameViewModel()
    viewModel.game.newRound()
    
    var vCard = Card(.ace(11), .spades)
    vCard.isFlipped = false
    viewModel.game.currentRound.currentTurn.viewerPlay = vCard
    
    var oCard = Card(.jack(2), .spades)
    oCard.isFlipped = false
    viewModel.game.currentRound.currentTurn.opponentPlay = oCard
    
    return GameActionView(
        viewModel: viewModel,
        showCloseHandConfirmation: .constant(false),
        animation: animation
    )
        .border(.blue)
}
