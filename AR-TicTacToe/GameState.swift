//
//  GameState.swift
//  AR-TicTacToe
//
//  Created by Bjarne Møller Lundgren on 20/06/2017.
//  Copyright © 2017 Bjarne Møller Lundgren. All rights reserved.
//

import Foundation

typealias GamePosition = (x:Int, y:Int)

enum GameMode {
    case put
    case move
}

enum GamePlayer:String {
    case x = "x"
    case o = "o"
    
    var next:GamePlayer {
        switch self {
        case .x: return .o
        case .o: return .x
        }
    }
}

struct GameState {
    let currentPlayer:GamePlayer
    let mode:GameMode
    let board:[[String]]
    
    static let DefaultPlayer = GamePlayer.x
    static let DefaultMode = GameMode.put
    static let EmptyBoard = [["","",""],["","",""],["","",""]]
    
    // number of squares used, (if >= 6 then we need to MOVE elements)
    private var numberOfSquaresUsed:Int {
        return board.reduce(0, {
            return $1.reduce($0, { return $0 + ($1 != "" ? 1 : 0) })
        })
    }
    
    // put for current player
    func put(at position:GamePosition) -> GameState? {
        guard case .put = mode,
            board[position.x][position.y] == "" else { return nil }
        
        var newBoard = board
        newBoard[position.x][position.y] = currentPlayer.rawValue
        
        return GameState(currentPlayer: currentPlayer.next,
                         mode: numberOfSquaresUsed >= 5 ? .move : .put,
                         board: newBoard)
    }
    
    // move for current player
    func move(from fromPosition:GamePosition, to toPosition:GamePosition) -> GameState? {
        guard case .move = mode,
            board[fromPosition.x][fromPosition.y] == currentPlayer.rawValue,
            board[toPosition.x][toPosition.y] == "" else { return nil }
        
        var newBoard = board
        newBoard[fromPosition.x][fromPosition.y] = ""
        newBoard[toPosition.x][toPosition.y] = currentPlayer.rawValue
        
        return GameState(currentPlayer: currentPlayer.next,
                         mode: .move,
                         board: newBoard)
    }
    
    // is there a winner?
    var currentWinner:GamePlayer? {
        get {
            // checking lines
            for l in 0..<3 {
                if board[l][0] != "" &&
                    board[l][0] == board[l][1] && board[l][0] == board[l][2] {
                    // horizontal line victory!
                    return GamePlayer(rawValue: board[l][0])
                    
                }
                if board[0][l] != "" &&
                    board[0][l] == board[1][l] && board[0][l] == board[2][l] {
                    // vertical line victory!
                    return GamePlayer(rawValue: board[0][l])
                    
                }
            }
            // accross check
            if board[0][0] != "" &&
                board[0][0] == board[1][1] && board[0][0] == board[2][2] {
                // top left - bottom right victory!
                return GamePlayer(rawValue: board[0][0])
                
            }
            if board[0][2] != "" &&
                board[0][2] == board[1][1] && board[0][2] == board[2][0] {
                // top right - bottom left victory!
                return GamePlayer(rawValue: board[0][2])
                
            }
            return nil
        }
    }
}
