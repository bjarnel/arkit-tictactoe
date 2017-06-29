//
//  GameAI.swift
//  AR-TicTacToe
//
//  Created by Bjarne Lundgren on 29/06/2017.
//  Copyright © 2017 Bjarne Møller Lundgren. All rights reserved.
//

import Foundation

/// this very simple Tic-Tac-Toe AI takes full advantage of the fact that the GameState
/// is an immutable struct..
struct GameAI {
    let game:GameState
    
    /// simply returns list of squares that contain pieces belonging to player
    /// or is empty (player == nil)
    private func gameSquaresWhere(playerIs player:GamePlayer?) -> [GamePosition] {
        var positions = [GamePosition]()
        
        for x in 0..<game.board.count {
            for y in 0..<game.board[x].count {
                if (player != nil && game.board[x][y] == player!.rawValue) ||
                   (player == nil && game.board[x][y].isEmpty) {
                    positions.append(GamePosition(x: x,
                                                  y: y))
                }
            }
        }
        
        return positions
    }
    
    private func possibleActions() -> [GameAction] {
        let emptySquares = gameSquaresWhere(playerIs: nil)
        
        // if in "put" mode then every possible action is to put a piece in any empty square
        if game.mode == .put {
            return emptySquares.map { GameAction.put(at: $0) }
        }
        
        var actions = [GameAction]()
        
        // everyone of the currentPlayers pieces
        for sourceSquare in gameSquaresWhere(playerIs: game.currentPlayer) {
            // each can be moved to any empty square..
            for destinationSquare in emptySquares {
                actions.append(.move(from: sourceSquare,
                                     to: destinationSquare))
            }
        }
        
        return actions
    }
    
    var bestAction:GameAction {
        // determine every possible action
        let actions = possibleActions()
        
        // score every possible action
        //TODO: recursively..
        
        // return action with highest score
        //TODO
        
        return actions[Int(arc4random_uniform(UInt32(actions.count)))]
    }
}
