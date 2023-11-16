//
//  Rank.swift
//  CardsPlayin
//
//  Created by Mike Kavouras on 7/26/23.
//

enum Rank: CustomDebugStringConvertible {
    case two(Int)
    case three(Int)
    case four(Int)
    case five(Int)
    case six(Int)
    case seven(Int)
    case eight(Int)
    case nine(Int)
    case ten(Int)
    case jack(Int)
    case queen(Int)
    case king(Int)
    case ace(Int)
    
    var value: Int {
        switch self {
        case .two(let val): return val
        case .three(let val): return val
        case .four(let val): return val
        case .five(let val): return val
        case .six(let val): return val
        case .seven(let val): return val
        case .eight(let val): return val
        case .nine(let val): return val
        case .ten(let val): return val
        case .jack(let val): return val
        case .queen(let val): return val
        case .king(let val): return val
        case .ace(let val): return val
        }
    }
    
    var imageName: String {
        switch self {
        case .two: return "2"
        case .three: return "3"
        case .four: return "4"
        case .five: return "5"
        case .six: return "6"
        case .seven: return "7"
        case .eight: return "8"
        case .nine: return "9"
        case .ten: return "10"
        case .jack: return "jack"
        case .queen: return "queen"
        case .king: return "king"
        case .ace: return "ace"
        }

    }
    
    var debugDescription: String {
        switch self {
        case .two: return "2"
        case .three: return "3"
        case .four: return "4"
        case .five: return "5"
        case .six: return "6"
        case .seven: return "7"
        case .eight: return "8"
        case .nine: return "9"
        case .ten: return "10"
        case .jack: return "J"
        case .queen: return "Q"
        case .king: return "K"
        case .ace: return "A"
        }
    }
}

extension Rank: Equatable {
    /**
     Two ranks are considered == if they're the same, without consideration for
     their associated values. If the associated value is something to consider, it can be done
     so with something like the following:
     
     ```
     case (let .two(lVal), let .two(rVal):
        return lVal == rVal
     ```
     */
    static func ==(lhs: Rank, rhs: Rank) -> Bool {
        switch (lhs, rhs) {
        case (.two, .two): return true
        case (.three, .three): return true
        case (.four, .four): return true
        case (.five, .five): return true
        case (.six, .six): return true
        case (.seven, .seven): return true
        case (.eight, .eight): return true
        case (.nine, .nine): return true
        case (.ten, .ten): return true
        case (.jack, .jack): return true
        case (.queen, .queen): return true
        case (.king, .king): return true
        case (.ace, .ace): return true
        default: return false
        }
    }
}

extension Rank: Comparable {
    static func >(lhs: Rank, rhs: Rank) -> Bool {
        return lhs.value > rhs.value
    }
    
    static func <(lhs: Rank, rhs: Rank) -> Bool {
        return lhs.value < rhs.value
    }
    
    static func >=(lhs: Rank, rhs: Rank) -> Bool {
        return lhs.value < rhs.value
    }
    
    static func <=(lhs: Rank, rhs: Rank) -> Bool {
        return lhs.value <= rhs.value
    }
}

