//
//  GameState.swift
//  AR-TicTacToe
//
//  Created by Bjarne Møller Lundgren on 20/06/2017.
//  Copyright © 2017 Bjarne Møller Lundgren. All rights reserved.
//

import Foundation

typealias GamePosition = (x:Int, y:Int)

enum GamePlayerType:String {
    case human = "human"
    case ai = "ai"
}

enum GameMode:String {
    case put = "put"
    case move = "move"
}

enum GamePlayer:String {
    case x = "x"
    case o = "o"
}

/// we have made the game actions generic in order to make it easier to implement the AI
enum GameAction {
    case put(at:GamePosition)
    case move(from:GamePosition, to:GamePosition)
}

/// our completely immutable implementation of Tic-Tac-Toe
struct GameState {
    let currentPlayer:GamePlayer
    let mode:GameMode
    let board:[[String]]
    
    /// When you create a new game (GameState) you get a certain default state, which you cant
    /// modify in any way
    init() {
        self.init(currentPlayer: arc4random_uniform(2) == 0 ? .x : .o,  // random start player
                  mode: .put,   // start mode is to put/drop pieces
                  board: [["","",""],["","",""],["","",""]])    // board is empty
    }
    
    /// this private init allows the perform func to return a new GameState
    private init(currentPlayer:GamePlayer,
                 mode:GameMode,
                 board:[[String]]) {
        self.currentPlayer = currentPlayer
        self.mode = mode
        self.board = board
    }
    
    // perform action in the game, if successful returns new GameState
    func perform(action:GameAction) -> GameState? {
        switch action {
        case .put(let at):
            // are we in "put" mode and is the destination square empty?
            guard case .put = mode,
                  board[at.x][at.y] == "" else { return nil }
            
            // generate a new board state
            var newBoard = board
            newBoard[at.x][at.y] = currentPlayer.rawValue
            
            // determine how many pieces has been placed
            let numberOfSquaresUsed = newBoard.reduce(0, {
                return $1.reduce($0, { return $0 + ($1 != "" ? 1 : 0) })
            })
            
            // generate new game state and return it
            return GameState(currentPlayer: currentPlayer == .x ? .o : .x,
                             mode: numberOfSquaresUsed >= 6 ? .move : .put,
                             board: newBoard)
            
        case .move(let from, let to):
            // are we in "move" mode and does the from piece match the current player
            // and is the destination square empty?
            guard case .move = mode,
                  board[from.x][from.y] == currentPlayer.rawValue,
                  board[to.x][to.y] == "" else { return nil }
            
            // generate a new board state
            var newBoard = board
            newBoard[from.x][from.y] = ""
            newBoard[to.x][to.y] = currentPlayer.rawValue
            
            // generate new game state and return it
            return GameState(currentPlayer: currentPlayer == .x ? .o : .x,
                             mode: .move,
                             board: newBoard)
            
        }
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
