//
//  MapView.swift
//  ChristmasConnect
//
//  Created by Lexline Johnson on 1/2/21.
//

import SpriteKit
import SwiftUI

class MapView: SKScene {
    // Declare variables
    var completedPoints = Helper().decodePoints() ?? []
    
    var levels: [Level] = []
    var scrollView: SKNode?
    var firstYLocation: CGFloat?
    var previousYLocation: CGFloat?
    var firstTime: TimeInterval?
    var tappedLevel: Bool = false
    var line: SKShapeNode?
    
    var sign: CGFloat?
    var m: CGFloat?
    var b: CGFloat?
    var startPoint: CGPoint?
    var endPoint: CGPoint?
    var currentXPos: CGFloat?
    
    var height: CGFloat = 0
    var fill = SKShapeNode()
    
    // Create new scene
    class func newView() -> MapView {
        let scene = MapView(size: CGSize(width: 688, height: 1024))
        
        //Set the anchor point to the center of the view
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        //Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        return scene
    }
    
    // Set up scene
    override func didMove(to view: SKView) {
        setUpView()
        setUpBackground()
        addLevels()
    }
    
    // Set up scroll view
    func setUpView() {
        // Auto-scroll depending on previous points
        var y = 0
        if let yPoint = completedPoints.last?.y {
            y = Int(-(yPoint + size.height / 2) / 2)
        }
        scrollView = SKNode()
        scrollView?.position = CGPoint(x: 0, y: y)
        addChild(scrollView!)
    }
    
    // Set up background
    func setUpBackground() {
        // Static background
        let background = SKSpriteNode(imageNamed: "ocean")
        background.zPosition = 0
        background.isUserInteractionEnabled = false
        background.size = size
        addChild(background)
        
        // Scroll background
        let northPole = SKSpriteNode(imageNamed: "north_pole")
        northPole.zPosition = 1
        northPole.isUserInteractionEnabled = false
        northPole.position = CGPoint(x: 0, y: 644 + size.height / 2)
        northPole.size = CGSize(width: 768, height: 1119)
        scrollView?.addChild(northPole)
    }
    
    // Add levels
    func addLevels() {
        // Initialize levels
        levels = Helper().initializeLevels()
        for i in 0..<levels.endIndex {
            // The first level is always either current or completed
            if i == 0 {
                levels[i].isCurrent = true
            }
            if levels[i].isComplete {
                if i + 1 < levels.endIndex {
                    // If level is complete, next level must be current or completed
                    levels[i + 1].isCurrent = true
                    // Draw a line between completed/current levels
                    createLine(levels[i + 1].isComplete, startLocation: levels[i].location, endLocation: levels[i + 1].location)
                }
                // Add a check on completed levels
                addCheck(at: levels[i].location)
            }
            // Create level nodes
            let levelNode = LevelNode(radius: 50, level: levels[i])
            levelNode.zPosition = 3
            levelNode.name = "level"
            levelNode.position = levels[i].location
            // Fill red if completed or current, else fill grey
            levelNode.fillColor = levels[i].isComplete || completedPoints.contains(levels[i].location) || i == 0 ? .red : levels[i].isEnd ? .lightGray : .darkGray
            levelNode.strokeColor = .clear
            scrollView?.addChild(levelNode)
        }
    }
    
    // Draw a line between completed/current levels
    func createLine(_ isComplete: Bool, startLocation: CGPoint, endLocation: CGPoint) {
        // If second node is not complete and its location is not in the array of connected node locations, animate the drawing of the line
        if !isComplete && !completedPoints.contains(endLocation) {
            createAnimatedLine(startLocation: startLocation, endLocation: endLocation)
            return
        }
        
        // Create a path for the line
        let path = CGMutablePath()
        path.move(to: startLocation)
        path.addLine(to: endLocation)

        // Create a shape node from the path
        let line = SKShapeNode(path: path)
        line.zPosition = 2
        line.strokeColor = .red
        line.lineWidth = 18
        line.lineCap = .round
        scrollView?.addChild(line)
    }
    
    // Initialize line that will be animated
    func createAnimatedLine(startLocation: CGPoint, endLocation: CGPoint) {
        // Calculate slope and y-intercept
        m = (endLocation.y - startLocation.y) / (endLocation.x - startLocation.x)
        b = startLocation.y - m! * startLocation.x
        
        // Determine if change in location is positive or negative
        if startLocation.x < endLocation.x {
            sign = 1
        } else {
            sign = -1
        }
        
        // Create path
        let path = CGMutablePath()
        path.move(to: startLocation)
        path.addLine(to: startLocation)
        
        // Initialize line
        line = SKShapeNode()
        line?.zPosition = 2
        line?.path = path
        line?.strokeColor = .red
        line?.lineWidth = 18
        line?.lineCap = .round
        scrollView?.addChild(line!)
        
        // Set global variables
        startPoint = startLocation
        endPoint = endLocation
        currentXPos = startPoint?.x
    }
    
    // Animate line
    func animateLine() {
        // Calculate height using y = mx + b
        let y = m! * currentXPos! + b!
        // Create new path
        let newPath = CGMutablePath()
        newPath.move(to: startPoint!)
        newPath.addLine(to: CGPoint(x: currentXPos!, y: y))
        // Update line path
        line?.path = newPath
    }
    
    // Initialize level fill
    func createFill() {
        // Get level node
        var level: LevelNode?
        let nodesAtLocation = scrollView?.nodes(at: endPoint!)
        for node in nodesAtLocation! {
            if let levelNode = node as? LevelNode {
                level = levelNode
            }
        }
        // Create mask from level node
        let cropNode = SKCropNode()
        cropNode.maskNode = level
        cropNode.zPosition = 4
        scrollView?.addChild(cropNode)
        
        // Create path from rectangle
        let rect = CGRect(x: endPoint!.x - 50, y: endPoint!.y - 50, width: 100, height: height)
        let path = CGPath(rect: rect, transform: nil)
        
        // Initialize line with path and mask it
        fill.path = path
        fill.fillColor = .red
        fill.strokeColor = .clear
        cropNode.addChild(fill)
    }
    
    // Animate level fill
    func animateFill() {
        // Create a new path with new height
        let rect = CGRect(x: endPoint!.x - 50, y: endPoint!.y - 50, width: 100, height: height)
        let path = CGPath(rect: rect, transform: nil)
        
        // Update fill path
        fill.path = path
    }
    
    // Add checkmark to completed levels
    func addCheck(at location: CGPoint) {
        // Retrieve symbol from SF Symbols and recolor it
        guard let image = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 0, weight: .regular, scale: .default))?.withTintColor(.white) else { return }
        guard let imageData = image.pngData() else { return }
        guard let tintedImage = UIImage(data: imageData) else { return }
        let texture = SKTexture(image: tintedImage)
        // Create checkmark node
        let check = SKSpriteNode(texture: texture)
        check.zPosition = 5
        check.position = location
        check.size = CGSize(width: 50, height: 50)
        scrollView?.addChild(check)
    }
    
    // Scroll the view up or down depending on touches
    func scroll(currentYLocation: CGFloat) {
        // If the previous location doesn't exist, return
        guard let previousYLocation = previousYLocation else { return }
        // Calculate the change in location
        let y = currentYLocation - previousYLocation
        let newYLocation = ((scrollView?.position.y) ?? 0) + y
        // If the new location is out of range, return
        if newYLocation >= 0 || newYLocation <= -985 { return }
        // Update scroll view position
        scrollView?.position = CGPoint(x: (scrollView?.position.x) ?? 0, y: newYLocation)
        // Set current location as the previous one
        self.previousYLocation = currentYLocation
    }
    
    // Continue scrolling after touch is finished depending on scroll momentum
    func scrollMomentum(momentum: Double) {
        guard var location = scrollView?.position.y else { return }
        
        var momentum = momentum
        var hitEdge = false
        var moves: [SKAction] = []
        
        for i in 1...10 {
            // If momentum is less than the minimum or the first location is no longer null (meaning the screen was tapped again), break
            if abs(momentum) < 0.5 || (firstYLocation != nil) { break }
            
            // Calculate new location
            momentum *= 0.2
            let distance = momentum * Double(i)
            let newLocation = location + CGFloat(distance)
            
            // If new location is out of range, set it back in range and switch directions (to create a "bounce" effect)
            if hitEdge {
                location -= CGFloat(distance / 4)
            } else if newLocation >= 0 {
                location = 0
                hitEdge = true
            } else if newLocation <= -985 {
                location = -985
                hitEdge = true
            } else {
                location = newLocation
            }
            
            // Append to action array
            moves.append(SKAction.moveTo(y: location, duration: 0.1))
        }

        // Run action sequence
        let moveSequence = SKAction.sequence(moves)
        scrollView?.run(moveSequence)
    }
    
    // Respond to touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Get first touch, else return
        guard let touch = touches.first else { return }
        
        // Find touched location and touched nodes
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        // Initialize y-locations for calculating scroll
        firstYLocation = location.y
        previousYLocation = location.y
        // Save current time
        firstTime = touch.timestamp
        
        for node in touchedNodes {
            if node is LevelNode {
                // If level node is tapped, remember that
                tappedLevel = true
            }
        }
    }
    
    // Respond to drag
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            // Pass current location into scroll()
            let location = touch.location(in: self)
            scroll(currentYLocation: location.y)
            // If touch moved, tapped level becomes false again
            tappedLevel = false
        }
    }
    
    // Respond to last touch
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Get first touch, else reset values and return
        guard let touch = touches.first else {
            firstYLocation = nil
            firstTime = nil
            tappedLevel = false
            return
        }
        
        // Find touched location and touched nodes
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if let levelNode = node as? LevelNode {
                // If level is tapped and is current or complete, open level
                if tappedLevel && (levelNode.level.isCurrent || levelNode.level.isComplete) {
                    if !levelNode.level.isEnd {
                        levelNode.openLevel(view: self)
                    } else {
                        let scene = FinalLevelView.newLevelView()
                        self.view?.presentScene(scene)
                    }
                }
            }
        }
        
        // Calculate scroll distance and time and pass into scrollMomentum()
        let scrollDistance = location.y - (firstYLocation ?? CGFloat(0))
        let timeInterval = touch.timestamp - (firstTime ?? Double(0))
        
        // Reset values
        firstYLocation = nil
        firstTime = nil
        tappedLevel = false
        
        scrollMomentum(momentum: Double(scrollDistance) / timeInterval)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // If end point doesn't exist, return
        guard let endPoint = endPoint else { return }
        // Check if current x-position exists
        if let currentXPos = currentXPos {
            guard let startPoint = startPoint else { return }
            // If current position is between start and end point, continue drawing the line
            if (currentXPos >= startPoint.x && currentXPos <= endPoint.x) || (currentXPos <= startPoint.x && currentXPos >= endPoint.x) {
                animateLine()
                // Calculate increment
                let inc = abs(endPoint.x - startPoint.x) / 75
                self.currentXPos! += inc * sign!
            } else {
                // Append unique points to array and save
                if !completedPoints.contains(startPoint) {
                    completedPoints.append(startPoint)
                }
                if !completedPoints.contains(endPoint) {
                    completedPoints.append(endPoint)
                }
                Helper().savePoints(points: completedPoints)
                // Reset values
                self.currentXPos = nil
                self.startPoint = nil
                // Initialize fill
                createFill()
            }
        // If height is less than or equal to 100 (level height), keep filling fill and increment height
        } else if height <= 102 {
            animateFill()
            height += 3
        }
    }
}
