//
//  Levels.swift
//  ChristmasConnect
//
//  Created by Lexline Johnson on 1/7/21.
//

import SpriteKit
import SwiftUI

// Level sprite
class LevelNode: SKShapeNode {
    var level: Level
    
    func openLevel(view: MapView) {
        let scene = LevelView.newLevel()
        scene.levelNumber = level.levelNumber
        scene.requiredScore = level.requiredScore
        scene.originalMoves = level.moves
        view.view?.presentScene(scene, transition: .crossFade(withDuration: 0.8))
    }
    
    init(radius: CGFloat, level: Level) {
        self.level = level
        super.init()
        let diameter = radius * 2
        self.path = CGPath(ellipseIn: CGRect(origin: CGPoint(x: self.position.x - radius, y: self.position.y - radius), size: CGSize(width: diameter, height: diameter)), transform: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Level
struct Level {
    let location: CGPoint
    let levelNumber: Int
    let requiredScore: Int?
    let moves: Int?
    let isComplete: Bool
    var isCurrent: Bool
    let isEnd: Bool
}

// Object sprite
class Object: SKSpriteNode {
    func fall(by spaces: Int) {
        let location = self.position.y
        var falls: [SKAction] = []
        for i in 1...spaces * 85 {
            let previousTime = (Double((i * 1000) - 1) / (0.5 * (9.8))).squareRoot()
            let time = (Double(i * 1000) / (0.5 * (9.8))).squareRoot() - previousTime
            
            falls.append(SKAction.moveTo(y: location - CGFloat(i), duration: time))
        }
        for i in stride(from: 0.1, through: 1, by: 0.1) {
            let height = 20 - 80 * pow((i - 0.5), 2)
            let newLocation = Double(location) - Double(85) * Double(spaces) + height
            
            falls.append(SKAction.moveTo(y: CGFloat(newLocation), duration: 0.01))
        }
        let fallSequence = SKAction.sequence(falls)
        self.run(fallSequence)
    }
    
    init(imageName: String) {
        let texture = SKTexture(imageNamed: imageName)
        super.init(texture: texture, color: .clear, size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Gift object sprite
class Gift: Object {
    var giftColor: Color
    
    init(imageName: String, giftColor: Color) {
        self.giftColor = giftColor
        super.init(imageName: imageName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Ornament object sprites
class Ornament: Object {
    var offset: CGPoint?
    var isTouchingTree: Bool = false
    
    override init(imageName: String) {
        super.init(imageName: imageName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
