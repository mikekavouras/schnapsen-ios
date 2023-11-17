//
//  ClosedHand.swift
//  CardsPlayin
//
//  Created by Mike Kavouras on 11/9/23.
//

import Foundation

struct ClosedHand {
    let score: Int
    let initiator: Player
    
    /// `pointsForScore` return the number of points awarded to the
    /// initiator assuming the initiator got 66
    func points() -> Int {
        if score == 0 { return 3 }
        return 2
    }
}
