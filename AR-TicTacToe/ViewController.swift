//
//  ViewController.swift
//  AR-TicTacToe
//
//  Created by Bjarne Møller Lundgren on 20/06/2017.
//  Copyright © 2017 Bjarne Møller Lundgren. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    // UI
    @IBOutlet weak var planeSearchLabel: UILabel!
    @IBOutlet weak var planeSearchOverlay: UIView!
    @IBOutlet weak var gameStateLabel: UILabel!
    @IBAction func didTapStartOver(_ sender: Any) { reset() }
    @IBOutlet weak var sceneView: ARSCNView!
    
    // State
    private func updatePlaneOverlay() {
        DispatchQueue.main.async {
            
        self.planeSearchOverlay.isHidden = self.currentPlane != nil
        
        if self.planeCount == 0 {
            self.planeSearchLabel.text = "Move around to allow the app the find a plane..."
        } else {
            self.planeSearchLabel.text = "Tap on a plane surface to place board..."
        }
            
        }
    }
    
    var planeCount = 0 {
        didSet {
            updatePlaneOverlay()
        }
    }
    var currentPlane:SCNNode? {
        didSet {
            updatePlaneOverlay()
        }
    }
    let board = Board()
    var gameState = GameState(currentPlayer: GameState.DefaultPlayer,
                              mode: GameState.DefaultMode,
                              board: GameState.EmptyBoard) {
        didSet {
            var s = gameState.currentPlayer.rawValue + " "
            switch gameState.mode {
            case .put: s += "put"
            case .move: s += "move"
            }
            gameStateLabel.text = s
            
            if let winner = gameState.currentWinner {
                let alert = UIAlertController(title: "Game Over", message: "\(winner.rawValue) wins!!!!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    self.reset()
                }))
                present(alert, animated: true, completion: nil)
            }
        }
    }
    var figures:[String:SCNNode] = [:]
    var draggingFrom:GamePosition? = nil
    var draggingFromPosition:SCNVector3? = nil
    
    // from demo APP
    // Use average of recent virtual object distances to avoid rapid changes in object scale.
    var recentVirtualObjectDistances = [CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        //sceneView.showsStatistics = true
        sceneView.scene = SCNScene()
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(didTap))
        sceneView.addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer()
        pan.addTarget(self, action: #selector(didPan))
        sceneView.addGestureRecognizer(pan)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingSessionConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    private func reset() {
        gameState = GameState(currentPlayer: GameState.DefaultPlayer,
                              mode: GameState.DefaultMode,
                              board: GameState.EmptyBoard)
        
        removeAllFigures()
        
        figures.removeAll()
    }
    
    private func removeAllFigures() {
        for (_, figure) in figures {
            figure.removeFromParentNode()
        }
    }
    
    private func restoreGame(at position:SCNVector3) {
        board.node.position = position
        sceneView.scene.rootNode.addChildNode(board.node)
        
        for (key, figure) in figures {
            //TODO: how to get the coordinates for these?!?!?
        }
    }
    
    private func groundPositionFrom(location:CGPoint) -> SCNVector3? {
        let results = sceneView.hitTest(location,
                                        types: ARHitTestResult.ResultType.existingPlaneUsingExtent)
        
        guard results.count > 0 else { return nil }
        
        return SCNVector3.positionFromTransform(results[0].worldTransform)
    }
    
    private func anyPlaneFrom(location:CGPoint) -> (SCNNode, SCNVector3)? {
        let results = sceneView.hitTest(location,
                                        types: ARHitTestResult.ResultType.existingPlaneUsingExtent)
        
        guard results.count > 0,
              let anchor = results[0].anchor,
              let node = sceneView.node(for: anchor) else { return nil }
        
        return (node, SCNVector3.positionFromTransform(results[0].worldTransform))
    }
    
    private func squareFrom(location:CGPoint) -> ((Int, Int), SCNNode)? {
        guard let _ = currentPlane else { return nil }
        
        let hitResults = sceneView.hitTest(location, options: [SCNHitTestOption.firstFoundOnly: false,
                                                               SCNHitTestOption.rootNode:       board.node])
        
        for result in hitResults {
            if let square = board.nodeToSquare[result.node] {
                return (square, result.node)
            }
        }
        
        return nil
    }
    
    private func revertDrag() {
        if let draggingFrom = draggingFrom {
            
            let restorePosition = sceneView.scene.rootNode.convertPosition(draggingFromPosition!, from: board.node)
            let action = SCNAction.move(to: restorePosition, duration: 0.3)
            figures["\(draggingFrom.x)x\(draggingFrom.y)"]?.runAction(action)
            
            self.draggingFrom = nil
            self.draggingFromPosition = nil
        }
    }
    
    // MARK: - Gestures
    
    @objc func didPan(_ sender:UIPanGestureRecognizer) {
        guard case .move = gameState.mode else { return }
        
        let location = sender.location(in: sceneView)
        
        switch sender.state {
        case .began:
            print("begin \(location)")
            guard let square = squareFrom(location: location) else { return }
            draggingFrom = (x: square.0.0, y: square.0.1)
            draggingFromPosition = square.1.position
            
        case .cancelled:
            print("cancelled \(location)")
            revertDrag()
            
        case .changed:
            print("changed \(location)")
            guard let draggingFrom = draggingFrom,
                let groundPosition = groundPositionFrom(location: location) else { return }
            
            let action = SCNAction.move(to: SCNVector3(groundPosition.x, groundPosition.y + Float(Dimensions.DRAG_LIFTOFF), groundPosition.z),
                                        duration: 0.1)
            figures["\(draggingFrom.x)x\(draggingFrom.y)"]?.runAction(action)
            
        case .ended:
            print("ended \(location)")
            let figure = Figure.figure(for: gameState.currentPlayer)
            
            guard let draggingFrom = draggingFrom,
                let square = squareFrom(location: location),
                square.0.0 != draggingFrom.x || square.0.1 != draggingFrom.y,
                let newGameState = gameState.move(from: draggingFrom, to: (x: square.0.0, y: square.0.1)) else {
                    revertDrag()
                    return
            }
            
            gameState = newGameState
            
            // remove node!
            //figures["\(draggingFrom.x)x\(draggingFrom.y)"]?.removeFromParentNode()
            
            // move in model!
            figures["\(square.0.0)x\(square.0.1)"] = figures["\(draggingFrom.x)x\(draggingFrom.y)"]
            figures["\(draggingFrom.x)x\(draggingFrom.y)"] = nil
            self.draggingFrom = nil
            
            //AAAh ah ah, MOVE NODE!
            // copy pasted insert thingie
            let newPosition = sceneView.scene.rootNode.convertPosition(square.1.position, from: square.1.parent)
            let action = SCNAction.move(to: newPosition,
                                        duration: 0.1)
            figures["\(square.0.0)x\(square.0.1)"]?.runAction(action)
            
            
            //figure.position = square.1.position
            
            //sceneView.scene.rootNode.addChildNode(figure)
            //figures["\(square.0.0)x\(square.0.1)"] = figure
            
            
        case .failed:
            print("failed \(location)")
            revertDrag()
            
        default: break
        }
    }
    
    @objc func didTap(_ sender:UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        
        // tap to place board..
        guard let currentPlane = currentPlane else {
            print("hit testing...")
            guard let newPlaneData = anyPlaneFrom(location: location) else { return }
            
            self.currentPlane = newPlaneData.0
            restoreGame(at: newPlaneData.1)
            return
        }
        
        // otherwise tap to place board piece..
        guard case .put = gameState.mode else { return }
        
        let figure = Figure.figure(for: gameState.currentPlayer)
        
        if let squareData = squareFrom(location: location),
           let newGameState = gameState.put(at: (x: squareData.0.0, y: squareData.0.1)) {
            gameState = newGameState
            
            // https://stackoverflow.com/questions/30392579/convert-local-coordinates-to-scene-coordinates-in-scenekit
            // this works!
            figure.position = sceneView.scene.rootNode.convertPosition(squareData.1.position, from: squareData.1.parent)
            sceneView.scene.rootNode.addChildNode(figure)
            figures["\(squareData.0.0)x\(squareData.0.1)"] = figure
        }
    }
    
    // MARK: - ARSCNViewDelegate
    
    // did at plane(?)
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("didAdd")
        planeCount += 1
    }
    
    // did update plane?
    func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {

    }
    
    // did remove plane?
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        print("didRemove")
        
        if node == currentPlane {
            removeAllFigures()
            board.node.removeFromParentNode()
            currentPlane = nil
        }
        
        if planeCount > 0 {
            planeCount -= 1
        }
    }
    
}

