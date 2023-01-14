# Alpha0C4

## A short description of Aplha0C4 framework API
---

    //
    //  Alpha0Connect4.swift
    //  Alpha0Connect4
    //
    //  Created by Guenole C. Silvestre on 10/01/2019.
    //  Copyright © 2022 UCD. All rights reserved.
    //

    import Foundation
    import CoreML    
    

## GameSessionProtocol
---

    protocol GameSessionProtocol {
        typealias SessionState = GameSession.State
        typealias DiscColor = GameSession.DiscColor

        func stateChanged(_ GameSession, state: SessionState, for: DiscColor, textLog: String)
        func didDropDisc(_ GameSession, color: DiscColor, at: (row: Int, column: Int), index: Int, textLog: String)
        func turnToPlay(_ GameSession, color: DiscColor)
        func didEnd(_ GameSession, color: DiscColor?, winningActions: [(row: Int, column: Int)])
    }


## GameSession class
---

    class GameSession {
        var boardLayout: (rows: Int, columns: Int) { get }
        var playedActions: [Int] { get }
        var winningPositions: [(row: Int, column: Int)] { get }
        var playerPositions: [(row: Int, column: Int)] { get }
        var state: GameSession.State { get }

        var delegate: GameSessionProtocol?

        init()

        func startGame(delegate: GameSessionProtocol? = nil, 
                       botPlays: DiscColor = .yellow, 
                       first: Bool = false, 
                       initialPositions: [(row: Int, column: Int)] = [(Int, Int)]())

        func dropDisc()
        func dropDiscAt(Int)
        func isValidMove(Int) -> Bool
    }


## GameState and DiscColor Enum
---

    extension GameSession {

        enum State {
            case cleared
            case idle(GameSession.DiscColor)
            case thinking(GameSession.DiscColor)
            case ended(GameSession.DiscColor?)
        }

        enum DiscColor : Int, CustomStringConvertible {
            var description: String { get }
            case red
            case yellow
            prefix static func !(color: DiscColor) -> DiscColor
        }
    }













