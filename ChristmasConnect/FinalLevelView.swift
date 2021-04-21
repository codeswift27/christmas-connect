//
//  FinalLevelView.swift
//  ChristmasConnect
//
//  Created by Lexline Johnson on 1/4/21.
//

import SpriteKit
import SwiftUI

class FinalLevelView: SKScene {
    // Declare variables
    var collectedOrnaments = UserDefaults.standard.array(forKey: "collectedOrnaments") as? [String] ?? []
    var tree: SKSpriteNode?
    var triggerEnd = false
    
    // Create new scene
    class func newLevelView() -> FinalLevelView {
        let scene = FinalLevelView(size: CGSize(width: 768, height: 1024))
        
        //Set the anchor point to the center of the view
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        //Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        return scene
    }
    
    // Set up scene
    override func didMove(to view: SKView) {
        setUpBackground()
        addTree()
        addOrnaments()
    }
    
    // Set up background
    func setUpBackground() {
        let background = SKSpriteNode(imageNamed: "christmas_background")
        background.zPosition = 0
        background.isUserInteractionEnabled = false
        background.size = size
        addChild(background)
    }
    
    // Add tree
    func addTree() {
        tree = SKSpriteNode(imageNamed: "christmas_tree")
        tree?.zPosition = 1
        tree?.size = CGSize(width: 450.58, height: 628.5)
        tree?.anchorPoint = CGPoint(x: 0.5, y: 0)
        tree?.position = CGPoint(x: 0, y: 161 - size.height / 2)
        addChild(tree!)
    }
    
    // Add ornaments
    func addOrnaments() {
        for i in 0..<collectedOrnaments.endIndex {
            // Calculate x-location
            let x = 130 + 127 * i - Int(size.width / 2)
            
            // Add ornaments
            let ornament = Ornament(imageName: collectedOrnaments[i])
            ornament.zPosition = 2
            ornament.name = "ornament"
            ornament.size = CGSize(width: 98, height: 98)
            ornament.position = CGPoint(x: x, y: 83 - Int(size.height) / 2)
            addChild(ornament)
        }
    }
    
    // Present end scene
    func fin() {
        let scene = TextView.newView()
        scene.text = "Merry (late) Christmas!"
        scene.level = 6
        scene.win = true
        self.view?.presentScene(scene, transition: .moveIn(with: .up, duration: 0.8))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // if triggerEnd is true, present end scene
        if triggerEnd {
            fin()
        }
        // Get first touch, else return
        guard let touch = touches.first else { return }
        
        // Get location and nodes
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        // Get first node
        guard let node = touchedNodes.first else { return }
        
        if let ornament = node as? Ornament {
            // Move ornament to front and set offset value
            ornament.zPosition = 3
            ornament.offset = CGPoint(x: ornament.position.x - location.x, y: ornament.position.y - location.y)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            // Get location and nodes
            let location = touch.location(in: self)
            let touchedNodes = nodes(at: location)
            
            for node in touchedNodes {
                if let ornament = node as? Ornament {
                    // If ornament has offset, set its new position based off of it and touch location
                    if ornament.offset != nil {
                        ornament.position = CGPoint(x: location.x + ornament.offset!.x, y: location.y + ornament.offset!.y)
                        print(node)
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Get first touch, else return
        guard let touch = touches.first else { return }
        
        // Get locations and nodes
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if let ornament = node as? Ornament {
                // Determine if ornaments are touching the tree
                if touchedNodes.contains(tree!) {
                    ornament.isTouchingTree = true
                } else {
                    ornament.isTouchingTree = false
                }
                // Reset values
                ornament.zPosition = 2
                ornament.offset = nil
            }
        }
        var allNodesTouchingTree = true
        // Enumerate through all ornaments and set allNodesTouchingTree to false if at least one ornament is not touching the tree
        enumerateChildNodes(withName: "ornament") {
            (node, stop) in
            if let ornament = node as? Ornament {
                if !ornament.isTouchingTree {
                    allNodesTouchingTree = false
                }
            }
        }
        // If all nodes are touching the tree, change tree texture and trigger the end scene on next touch
        if allNodesTouchingTree {
            tree?.texture = SKTexture(imageNamed: "christmas_tree_decorated")
            tree?.size = CGSize(width: tree!.size.width, height: 700.5)
            triggerEnd = true
        }
    }
}
