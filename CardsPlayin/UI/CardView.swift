//
//  CardView.swift
//  CardsPlayin
//
//  Created by Mike Kavouras on 11/13/23.
//

import SwiftUI

class CardViewModel: ObservableObject {
    @Published var card: Card
    private var tapHandler: (Card) -> Bool
    
    init(_ card: Card, tapHandler: @escaping (Card) -> Bool) {
        self.card = card
        self.tapHandler = tapHandler
    }
    
    func toggleSelected(_ card: Card) -> Bool {
        return tapHandler(card)
    }
}

struct CardView: View {
    private var viewModel: CardViewModel
    let selectionFeedback = UISelectionFeedbackGenerator()
    
    @State private var translation: CGSize = .zero
    
    private var card: Card { viewModel.card }
    private var cardWidth: CGFloat {
        return UIScreen.main.bounds.width * 0.18
    }

    init(_ viewModel: CardViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Image(card.imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: cardWidth)
            .cornerRadius(8)
            .shadow(radius: card.isSelected ? 8 : 2)
            .onTapGesture {
                withAnimation(Animation.easeOut(duration: 0.16)) {
                    toggleSelectedCard(card) }
            }
            .offset(x: translation.width, y: (card.isSelected ? -24 : 0) + translation.height)
            .gesture(
                simpleDrag
            )
            .onAppear {
                selectionFeedback.prepare()
            }
    }
    
    func toggleSelectedCard(_ card: Card) {
        let enabled = viewModel.toggleSelected(card)
        if !enabled {
            selectionFeedback.selectionChanged()
        }
    }
    
    private var simpleDrag: some Gesture {
        DragGesture(coordinateSpace: .local)
            .onChanged { value in
                translation = value.translation
            }
            .onEnded { _ in
                withAnimation(.spring()) {
                    translation = .zero
                }
            }
    }
}

#Preview {
    var card = Card(.ace(11), .hearts)
    card.isFlipped = false
    let cardViewModel = CardViewModel(card) { card in
        return true
    }

    return CardView(cardViewModel)
}
