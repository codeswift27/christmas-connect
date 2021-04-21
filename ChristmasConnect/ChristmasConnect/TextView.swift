//
//  TextView.swift
//  ChristmasConnect
//
//  Created by Lexline Johnson on 1/3/21.
//

import SpriteKit
import SwiftUI

class TextView: SKScene {
    // Declare variables
    var text: String?
    var level: Int?
    var win: Bool?
    
    let defaults = UserDefaults.standard
    
    // Create new scene
    class func newView() -> TextView {
        let scene = TextView(size: CGSize(width: 768, height: 1024))
        
        //Set the anchor point to the center of the view
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        //Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        return scene
    }
    
    // Set up scene
    override func didMove(to view: SKView) {
        addText()
    }
    
    // Add text
    func addText() {
        let label = SKLabelNode.init(text: text)
        label.fontSize = 60
        label.fontColor = UIColor.white
        label.position = CGPoint(x: 0, y: 0)
        addChild(label)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Create number formatter
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        let number = formatter.string(from: level! as NSNumber)!
        print(number.capitalized)
        
        if win! {
            // If win is true, set the values as true, else do nothing
            defaults.setValue(true, forKey: "level\(number.capitalized)")
        }
        
        // Present map scene
        let scene = MapView.newView()
        self.view?.presentScene(scene, transition: .reveal(with: .up, duration: 0.8))
    }
}
