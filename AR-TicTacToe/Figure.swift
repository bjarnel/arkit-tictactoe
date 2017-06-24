//
//  Figure.swift
//  AR-TicTacToe
//
//  Created by Bjarne Møller Lundgren on 20/06/2017.
//  Copyright © 2017 Bjarne Møller Lundgren. All rights reserved.
//

import Foundation
import SceneKit

class Figure {
    class func figure(for player:GamePlayer) -> SCNNode {
        switch player {
        case .x: return xFigure()
        case .o: return oFigure()
        }
    }
    
    class func xFigure() -> SCNNode {
        let geometry = SCNCylinder(radius: Dimensions.FIGURE_RADIUS,
                                   height: Dimensions.SQUARE_SIZE)
        geometry.firstMaterial?.lightingModel = .physicallyBased
        geometry.firstMaterial?.diffuse.contents = UIImage(named: "Media.scnassets/scuffed-plastic6-alb.png")
        geometry.firstMaterial?.roughness.contents = UIImage(named: "Media.scnassets/scuffed-plastic-rough.png")
        geometry.firstMaterial?.metalness.contents = UIImage(named: "Media.scnassets/scuffed-plastic-metal.png")
        geometry.firstMaterial?.normal.contents = UIImage(named: "Media.scnassets/scuffed-plastic-normal.png")
        geometry.firstMaterial?.ambientOcclusion.contents = UIImage(named: "Media.scnassets/scuffed-plastic-ao.png")
        
        let cylinderNode1 = SCNNode(geometry: geometry)
        cylinderNode1.eulerAngles = SCNVector3(-90.0.degreesToRadians, 45.0.degreesToRadians, 0)
        cylinderNode1.position = SCNVector3(0, Dimensions.FIGURE_RADIUS * 0.5, 0)
        
        let cylinderNode2 = SCNNode(geometry: geometry)
        cylinderNode2.eulerAngles = SCNVector3(-90.0.degreesToRadians, -45.0.degreesToRadians, 0)
        cylinderNode2.position = SCNVector3(0, Dimensions.FIGURE_RADIUS * 0.5, 0)
        
        let node = SCNNode()
        node.addChildNode(cylinderNode1)
        node.addChildNode(cylinderNode2)
        return node
    }
    
    class func oFigure() -> SCNNode {
        let geometry = SCNTorus(ringRadius: Dimensions.SQUARE_SIZE * 0.3,
                                pipeRadius: Dimensions.FIGURE_RADIUS)
        geometry.firstMaterial?.lightingModel = .physicallyBased
        geometry.firstMaterial?.diffuse.contents = UIImage(named: "Media.scnassets/scuffed-plastic4-alb.png")
        geometry.firstMaterial?.roughness.contents = UIImage(named: "Media.scnassets/scuffed-plastic-rough.png")
        geometry.firstMaterial?.metalness.contents = UIImage(named: "Media.scnassets/scuffed-plastic-metal.png")
        geometry.firstMaterial?.normal.contents = UIImage(named: "Media.scnassets/scuffed-plastic-normal.png")
        geometry.firstMaterial?.ambientOcclusion.contents = UIImage(named: "Media.scnassets/scuffed-plastic-ao.png")
        
        // applying PBR: https://medium.com/@avihay/amazing-physically-based-rendering-using-the-new-ios-10-scenekit-2489e43f7021
        
        let torusNode = SCNNode(geometry: geometry)
        torusNode.position = SCNVector3(0, Dimensions.FIGURE_RADIUS * 0.5, 0)
        
        let node = SCNNode()
        node.addChildNode(torusNode)
        return node
    }
}
