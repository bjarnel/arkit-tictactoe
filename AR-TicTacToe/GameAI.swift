//
//  GameAI.swift
//  AR-TicTacToe
//
//  Created by Bjarne Lundgren on 29/06/2017.
//  Copyright © 2017 Bjarne Møller Lundgren. All rights reserved.
//

import Foundation

private let MAX_ITERATIONS = 3
private let SCORE_WINNING = 100

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
    
    /// returns list of possible actions given the GameState
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
    
    /// returns list of SCORED possible actions given GameState and a player bias (player who we want to win)
    /// Recursively simulates actions and the effect of actions..
    private func scoredPossibleActions(playerBias:GamePlayer,
                                       iterationCount:Int = 0) -> [(score:Int, action:GameAction)] {
        var scoredActions = [(score:Int, action:GameAction)]()
        
        for action in possibleActions() {
            var score = 0
            guard let gameStatePostAction = game.perform(action: action) else { fatalError() }
            
            if let winner = gameStatePostAction.currentWinner {
                let scoreForWin = SCORE_WINNING - iterationCount
                if winner == playerBias {    // if playerBias wins it's positive score!
                    score += scoreForWin
                } else {    // otherwise big negative score!
                    score -= scoreForWin * 2
                }
                
            } else {
                // add worst follow-up action score..
                if iterationCount < MAX_ITERATIONS {
                    let followUpActions = GameAI(game: gameStatePostAction).scoredPossibleActions(playerBias: playerBias,
                                                                                                  iterationCount: iterationCount + 1)
                    var minScoredAction:(score:Int, action:GameAction)? = nil
                    for scoredAction in followUpActions {
                        if minScoredAction == nil || minScoredAction!.score > scoredAction.score {
                            minScoredAction = scoredAction
                        }
                    }
                    score += minScoredAction!.score
                }
                
            }
            
            scoredActions.append((score: score, action: action))
        }
        
        return scoredActions
    }
    
    var bestAction:GameAction {
        var topScoredAction:(score:Int, action:GameAction)? = nil
        for scoredAction in scoredPossibleActions(playerBias: game.currentPlayer) {
            if topScoredAction == nil || topScoredAction!.score < scoredAction.score {
                topScoredAction = scoredAction
            }
        }
        return topScoredAction!.action
    }
}
