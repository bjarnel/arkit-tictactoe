//
//  Board.swift
//  AR-TicTacToe
//
//  Created by Bjarne Møller Lundgren on 20/06/2017.
//  Copyright © 2017 Bjarne Møller Lundgren. All rights reserved.
//

import Foundation
import SceneKit

class Board {
    let node:SCNNode
    let nodeToSquare:[SCNNode:(Int,Int)]
    
    init() {
        node = SCNNode()
        var nodeToSquare = [SCNNode:(Int,Int)]()
        // var squareToNode = [String:SCNNode]()
        // var squareLocations = [SCNVector3]()
        
        
        let length = Dimensions.SQUARE_SIZE * 4
        let height:CGFloat = Dimensions.BOARD_GRID_HEIGHT
        let width:CGFloat = Dimensions.BOARD_GRID_WIDTH
        
        //let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.25))
        //sphereNode.position = SCNVector3(0, 0.4, 0)
        //boardNode.addChildNode(sphereNode)
        
        for l in 0..<4 {
            let lineOffset = length * 0.5 - (CGFloat(l + 1) * Dimensions.SQUARE_SIZE - Dimensions.SQUARE_SIZE * 0.5)
            
            // squares
            if l > 0 {
                for r in 0..<3 {
                    let position = SCNVector3(lineOffset + Dimensions.SQUARE_SIZE * 0.5,
                                              0.01,
                                              //TODO: do a rowOffset like above for this, this is ugly!
                        CGFloat(r - 1) * Dimensions.SQUARE_SIZE)
                    let square = (l - 1, r)
                    
                    let geometry = SCNPlane(width: Dimensions.SQUARE_SIZE,
                                            height: Dimensions.SQUARE_SIZE)
                    geometry.firstMaterial!.diffuse.contents = UIColor.clear
                    //geometry.firstMaterial!.specular.contents = UIColor.white
                    
                    let squareNode = SCNNode(geometry: geometry)
                    squareNode.position = position
                    squareNode.eulerAngles = SCNVector3(-90.0.degreesToRadians, 0, 0)
                    
                    node.addChildNode(squareNode)
                    nodeToSquare[squareNode] = square
                }
            }
            
            
            // grid lines..
            let geometry = SCNBox(width: width,
                                  height: height,
                                  length: length,
                                  chamferRadius: 0)
            geometry.firstMaterial!.diffuse.contents = UIColor.darkGray
            geometry.firstMaterial!.specular.contents = UIColor.white
            
            let vgeometry = SCNBox(width: width,
                                   height: height,
                                   length: length,
                                   chamferRadius: 0)
            vgeometry.firstMaterial!.diffuse.contents = UIColor.darkGray
            vgeometry.firstMaterial!.specular.contents = UIColor.white
            
            
            
            
            let horizontalLineNode = SCNNode(geometry: geometry)
            horizontalLineNode.position = SCNVector3(lineOffset, height * 0.5, 0)
            node.addChildNode(horizontalLineNode)
            
            let verticalLineNode = SCNNode(geometry: vgeometry)
            
            // using euler angles the object rotates around itself ;)
            verticalLineNode.eulerAngles = SCNVector3(0, 90.0.degreesToRadians, 0)
            verticalLineNode.position = SCNVector3(0, height * 0.5, lineOffset)
            node.addChildNode(verticalLineNode)
        }
        
        self.nodeToSquare = nodeToSquare
    }
    
    
}
