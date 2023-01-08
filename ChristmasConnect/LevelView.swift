//
//  LevelView.swift
//  ChristmasConnect
//
//  Created by Lexline Johnson on 12/13/20.
//

import SpriteKit
import SwiftUI

class LevelView: SKScene {
    // Declare variables
    var levelNumber: Int?
    var requiredScore: Int?
    var originalMoves: Int?
    
    var moves: Int?
    var collectedOrnaments = UserDefaults.standard.array(forKey: "collectedOrnaments") as? [String] ?? []
    var colorblindModeEnabled = UserDefaults.standard.bool(forKey: "colorblindModeEnabled")
    
    var firstLocation: CGPoint?
    var firstColor: Color?
    var line = SKShapeNode()
    var giftLocations: [CGPoint] = []
    var score = 0
    var ornament: Ornament?
    
    var scoreLabel: SKLabelNode?
    var movesLabel: SKLabelNode?
    
    var menuView: SKNode?
    var menuIsOpen = false
    
    // Create new scene
    class func newLevel() -> LevelView {
        let scene = LevelView(size: CGSize(width: 768, height: 1024))
        
        //Set the anchor point to the center of the view
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        //Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        return scene
    }
    
    // Set up scene
    override func didMove(to view: SKView) {
        moves = originalMoves
        setUpBackground()
        addMenu()
        addScoreLabel()
        addMovesLabel()
        initializeGifts()
    }
    
    // Set up background
    func setUpBackground() {
        let background = SKSpriteNode(imageNamed: "ocean")
        background.zPosition = 0
        background.isUserInteractionEnabled = false
        background.size = size
        addChild(background)
    }
    
    // Create menu
    func addMenu() {
        // Create menu button
        let menuButton = SKSpriteNode(imageNamed: "menu")
        menuButton.zPosition = 4
        menuButton.name = "menu"
        menuButton.size = CGSize(width: 27, height: 18)
        menuButton.anchorPoint = CGPoint(x: 0, y: 1)
        menuButton.position = CGPoint(x: 25 - size.width / 2, y: 999 - size.height / 2)
        addChild(menuButton)
        // Adjust touch area
        let menuTouch = SKShapeNode(rectOf: CGSize(width: 50, height: 50))
        menuTouch.fillColor = .clear
        menuTouch.strokeColor = .clear
        menuButton.addChild(menuTouch)
        
        // Create a node to contain all menu objects
        menuView = SKNode()
        menuView?.zPosition = 3
        menuView?.position = CGPoint(x: -360, y: 0)
        addChild(menuView!)
        
        //  Create menu
        let menu = SKShapeNode(rectOf: CGSize(width: 360, height: size.height))
        menu.zPosition = 0
        menu.fillColor = .init(red: 30 / 255, green: 30 / 255, blue: 30 / 255, alpha: 1)
        menu.strokeColor = .clear
        menu.position = CGPoint(x: 180 - size.width / 2, y: 0)
        menuView?.addChild(menu)
        
        // Retrieve font
        let font = CTFontCreateUIFontForLanguage(.menuItem, 0, nil)
        
        // Create restart label
        let restartLabel = SKLabelNode(text: "Restart")
        restartLabel.zPosition = 1
        restartLabel.name = "restart"
        restartLabel.fontName = String(CTFontCopyFullName(font!))
        restartLabel.fontSize = 20
        restartLabel.color = .white
        restartLabel.horizontalAlignmentMode = .left
        restartLabel.position = CGPoint(x: 73 - size.width / 2, y: 891 - size.height / 2)
        menuView?.addChild(restartLabel)
        // Adjust Touch area
        let restartLabelTouch = SKShapeNode(rectOf: CGSize(width: menu.frame.width, height: 40))
        restartLabelTouch.fillColor = .clear
        restartLabelTouch.strokeColor = .clear
        restartLabelTouch.position = CGPoint(x: 106, y: 9)
        restartLabel.addChild(restartLabelTouch)
        
        // Create return to map label
        let returnToMapLabel = SKLabelNode(text: "Return to map")
        returnToMapLabel.zPosition = 1
        returnToMapLabel.name = "returnToMap"
        returnToMapLabel.fontName = String(CTFontCopyFullName(font!))
        returnToMapLabel.fontSize = 20
        returnToMapLabel.color = .white
        returnToMapLabel.horizontalAlignmentMode = .left
        returnToMapLabel.position = CGPoint(x: 73 - size.width / 2, y: 831 - size.height / 2)
        menuView?.addChild(returnToMapLabel)
        // Adjust touch area
        let returnLabelTouch = SKShapeNode(rectOf: CGSize(width: menu.frame.width, height: 40))
        returnLabelTouch.fillColor = .clear
        returnLabelTouch.strokeColor = .clear
        returnLabelTouch.position = CGPoint(x: 106, y: 9)
        returnToMapLabel.addChild(returnLabelTouch)
        
        // Create colorblind mode label
        let colorblindModeLabel = SKLabelNode()
        colorblindModeLabel.text = "\(colorblindModeEnabled ? "Disable" : "Enable") colorblind mode"
        colorblindModeLabel.zPosition = 1
        colorblindModeLabel.name = "colorblindMode"
        colorblindModeLabel.fontName = String(CTFontCopyFullName(font!))
        colorblindModeLabel.fontSize = 20
        colorblindModeLabel.color = .white
        colorblindModeLabel.horizontalAlignmentMode = .left
        colorblindModeLabel.position = CGPoint(x: 73 - size.width / 2, y: 773 - size.height / 2)
        menuView?.addChild(colorblindModeLabel)
        // Adjust touch area
        let colorblindLabelTouch = SKShapeNode(rectOf: CGSize(width: menu.frame.width, height: 40))
        colorblindLabelTouch.fillColor = .clear
        colorblindLabelTouch.strokeColor = .clear
        colorblindLabelTouch.position = CGPoint(x: 106, y: 9)
        colorblindModeLabel.addChild(colorblindLabelTouch)
        
        // Create restart icon
        guard let restartImage = UIImage(systemName: "arrow.clockwise", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .regular, scale: .default))?.withTintColor(.white) else { return }
        guard let restartImageData = restartImage.pngData() else { return }
        guard let restartTintedImage = UIImage(data: restartImageData) else { return }
        let restartTexture = SKTexture(image: restartTintedImage)
        let restartIcon = SKSpriteNode(texture: restartTexture)
        restartIcon.zPosition = 1
        restartIcon.name = "restartIcon"
        restartIcon.position = CGPoint(x: 44 - size.width / 2, y: 901 - size.height / 2)
        menuView?.addChild(restartIcon)
        
        // Create map icon
        guard let mapImage = UIImage(systemName: "map", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .regular, scale: .default))?.withTintColor(.white) else { return }
        guard let mapImageData = mapImage.pngData() else { return }
        guard let mapTintedImage = UIImage(data: mapImageData) else { return }
        let mapTexture = SKTexture(image: mapTintedImage)
        let mapIcon = SKSpriteNode(texture: mapTexture)
        mapIcon.zPosition = 1
        mapIcon.name = "mapIcon"
        mapIcon.position = CGPoint(x: 44 - size.width / 2, y: 841 - size.height / 2)
        menuView?.addChild(mapIcon)
        
        // Create eye icon
        guard let eyeImage = UIImage(systemName: "eye\(colorblindModeEnabled ? ".fill" : "")", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .regular, scale: .default))?.withTintColor(.white) else { return }
        guard let eyeImageData = eyeImage.pngData() else { return }
        guard let eyeTintedImage = UIImage(data: eyeImageData) else { return }
        let eyeTexture = SKTexture(image: eyeTintedImage)
        let eyeIcon = SKSpriteNode(texture: eyeTexture)
        eyeIcon.zPosition = 1
        eyeIcon.name = "eyeIcon"
        eyeIcon.position = CGPoint(x: 44 - size.width / 2, y: 781 - size.height / 2)
        menuView?.addChild(eyeIcon)
    }
    
    // Open menu by moving it onto the scene
    func openMenu() {
        let slideOpen = SKAction.moveTo(x: 0, duration: 0.2)
        slideOpen.timingMode = .easeIn
        menuView?.run(slideOpen)
        menuIsOpen = true
    }
    
    // Close menu by hiding it offscreen
    func closeMenu() {
        let slideClose = SKAction.moveTo(x: -360, duration: 0.2)
        slideClose.timingMode = .easeOut
        menuView?.run(slideClose)
        menuIsOpen = false
    }
    
    // Create score label
    func addScoreLabel() {
        // Return if label already exists
        if let label = scoreLabel {
            if self.contains(label) { return }
        }
        
        // Create a number formatter
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        // Format numbers with commas
        guard let score = formatter.string(from: score as NSNumber) else { return }
        guard let requiredScore = formatter.string(from: requiredScore! as NSNumber) else { return }
        // Create attributed string
        let scoreLabelText = NSMutableAttributedString.init(string: "\(score)/\(requiredScore) points")
        scoreLabelText.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 40, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor.white], range: NSMakeRange(0, score.count))
        scoreLabelText.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.white], range: NSMakeRange(score.count, requiredScore.count + 8))
        // Create label
        scoreLabel = SKLabelNode.init()
        scoreLabel?.zPosition = 1
        scoreLabel?.attributedText = scoreLabelText
        scoreLabel?.position = CGPoint(x: 90 - size.width / 2, y: 887 - size.height / 2)
        scoreLabel?.horizontalAlignmentMode = .left
        addChild(scoreLabel!)
    }
    
    // Create moves label
    func addMovesLabel() {
        // Return if moves is null
        guard let moves = moves else { return }
        
        // Create attributed string
        let movesLabelText = NSMutableAttributedString.init(string: "\(moves) moves")
        movesLabelText.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 40, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor.white], range: NSMakeRange(0, String(moves).count))
        movesLabelText.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.white], range: NSMakeRange(String(moves).count, 6))
        // Create label
        movesLabel = SKLabelNode.init()
        movesLabel?.zPosition = 1
        movesLabel?.attributedText = movesLabelText
        movesLabel?.position = CGPoint(x: 679 - size.width / 2, y: 887 - size.height / 2)
        movesLabel?.horizontalAlignmentMode = .right
        addChild(movesLabel!)
    }
    
    // Add gifts
    func initializeGifts() {
        // Get two random numbers; first number cannot be 8 because it would map to the bottom of the view (and the ornaments can't start out at the bottom)
        let numbers = [Int(arc4random_uniform(7)), Int(arc4random_uniform(8))]
        for i in 0...7 {
            for j in 0...7 {
                // Get a random color
                let color = Helper().randomColor()
                
                // Calculate locations
                let x: Int = (115 + 77 * j) - Int(size.width) / 2
                let y: Int = (809 - 85 * i) - Int(size.height) / 2
                
                // If random numbers are equal to i and j respectively, add ornament
                if numbers[0] == i && numbers[1] == j {
                    ornament = Ornament(imageName: "ornament_\(levelNumber ?? 0)")
                    ornament?.zPosition = 1
                    ornament?.name = "ornament"
                    ornament?.position = CGPoint(x: x, y: y)
                    ornament?.size = CGSize(width: 58, height: 58)
                    addChild(ornament!)
                // Else add gift
                } else {
                    let gift = Gift(imageName: "gift_\(color)\(colorblindModeEnabled ? "_shape" : "")", giftColor: color)
                    gift.zPosition = 1
                    gift.name = "gift"
                    gift.position = CGPoint(x: x, y: y)
                    gift.size = CGSize(width: 50, height: 58)
                    addChild(gift)
                }
            }
        }
    }
    
    // Move gifts downward when gifts below it disappear
    func moveGifts(giftLocations: [CGPoint]) {
        var locationsAboveCount: [CGFloat: [CGFloat: Int]] = [:]
        var emptyLocationsCount: [CGFloat: Int] = [:]
        
        var locationsAbove: [CGPoint] = []
        var emptyLocations: [CGPoint] = []
        
        // For each location, find all gifts locations above
        for location in giftLocations {
            for i in stride(from: location.y, through: 809 - size.height / 2, by: 85) {
                // Count duplicates
                locationsAboveCount[location.x] = locationsAboveCount[location.x] ?? [i: 0]
                let value = (locationsAboveCount[location.x]?[i]) ?? 0
                locationsAboveCount[location.x]?.updateValue(value + 1, forKey: i)
                
                // Filter out duplicates
                if !locationsAbove.contains(CGPoint(x: location.x, y: i)) {
                    locationsAbove.append(CGPoint(x: location.x, y: i))
                }
            }
            
            // Count empty location duplicates
            emptyLocationsCount.updateValue((locationsAboveCount[location.x]?[809 - size.height / 2])!, forKey: location.x)
            // For each empty x-location, including duplicates, calculate locations
            for i in 0..<emptyLocationsCount[location.x]! {
                // Count locations starting from the top and add append all unique values
                let emptyY: CGFloat = 809 - size.height / 2 - 85 * CGFloat(i)
                if !emptyLocations.contains(CGPoint(x: location.x, y: emptyY)) {
                    emptyLocations.append(CGPoint(x: location.x, y: emptyY))
                }
            }
        }
        
        // Sort locations from bottom to top, for a more realistic look
        for location in locationsAbove.sorted(by: { $0.y < $1.y }) {
            // Find all object nodes at locations and make them fall
            let fallingNodes = nodes(at: location)
            for node in fallingNodes {
                if let object = node as? Object {
                    object.fall(by: locationsAboveCount[location.x]?[location.y] ?? 1)
                }
            }
        }
        // Pass empty locations into addGifts()
        addGifts(emptyLocations: emptyLocations, locationCount: emptyLocationsCount)
    }
    
    // Add new gifts
    func addGifts(emptyLocations: [CGPoint], locationCount: [CGFloat: Int]) {
        for location in emptyLocations {
            // Get a random color
            let color = Helper().randomColor()
            
            // Add gift
            let gift = Gift(imageName: "gift_\(color)\(colorblindModeEnabled ? "_shape" : "")", giftColor: color)
            gift.zPosition = 1
            gift.name = "gift"
            gift.position = CGPoint(x: location.x, y: location.y + CGFloat(85 * locationCount[location.x]!))
            gift.size = CGSize(width: 50, height: 58)
            addChild(gift)
            // Make gift fall into place
            gift.fall(by: locationCount[location.x] ?? 0)
        }
    }
    
    // Create line
    func createLine(color: Color, location: CGPoint) {
        // If line already exists, return
        if self.contains(line) { return }
        
        // Create path
        let path = CGMutablePath()
        path.move(to: CGPoint(x: location.x, y: location.y - 10))
        path.addLine(to: CGPoint(x: location.x, y: location.y - 10))
        
        // Create line
        line.path = path
        line.zPosition = 2
        line.strokeColor = UIColor(color)
        line.lineWidth = 8
        line.lineCap = .round
        addChild(line)
    }
    
    // Make line connect gifts and follow current touch
    func moveLine(currentLocation: CGPoint) {
        // If line doesn't already exist, return
        if !self.contains(line) { return }
        
        // Create path
        let path = CGMutablePath()
        path.move(to: CGPoint(x: firstLocation!.x, y: firstLocation!.y - 10))
        // Add line to every location in giftLocations
        for location in giftLocations {
            path.addLine(to: CGPoint(x: location.x, y: location.y - 10))
        }
        // Add line to current touch location
        path.addLine(to: currentLocation)
        // Update line path
        line.path = path
    }
    
    // Remove ornament from scene when it falls to the bottom of the gameboard
    func removeOrnament() {
        if ornament?.position.y == 224 - size.height / 2 {
            ornament?.removeFromParent()
            // Move gifts above down
            moveGifts(giftLocations: [position])
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // If first touch doesn't exist, return
        guard let touch = touches.first else { return }
        
        // Get touched locations and nodes
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            // If gift is touched, create line where gift is
            if let gift = node as? Gift {
                createLine(color: gift.giftColor, location: gift.position)
                firstColor = gift.giftColor
                firstLocation = gift.position
            // Else if menu is touched, toggle menu
            } else if node.name == "menu" {
                if menuIsOpen {
                    closeMenu()
                } else {
                    openMenu()
                }
            // Else if restart button is touched, reset scores and remove labels and gifts and reinitialize them
            } else if node.name == "restart" {
                scoreLabel?.removeFromParent()
                movesLabel?.removeFromParent()
                enumerateChildNodes(withName: "gift") {
                    (node, stop) in
                    node.removeFromParent()
                }
                childNode(withName: "ornament")?.removeFromParent()
                score = 0
                moves = originalMoves
                addScoreLabel()
                addMovesLabel()
                initializeGifts()
            // Else if return to map button is touched, return to map
            } else if node.name == "returnToMap" {
                let scene = MapView.newView()
                self.view?.presentScene(scene, transition: .crossFade(withDuration: 0.8))
            // Else if colorblind mode is touched, toggle colorblind mode
            } else if node.name == "colorblindMode" {
                enumerateChildNodes(withName: "gift") {
                    (node, stop) in
                    if let gift = node as? Gift {
                        // Change gift texture
                        let texture = SKTexture(imageNamed: "gift_\(gift.giftColor)\(self.colorblindModeEnabled ? "" : "_shape")")
                        gift.texture = texture
                    }
                }
                // Change colorblind mode label text
                if let label = menuView?.childNode(withName: "colorblindMode") as? SKLabelNode {
                    label.text = "\(colorblindModeEnabled ? "Enable" : "Disable") colorblind mode"
                }
                // Change colorblind mode icon
                if let icon = menuView?.childNode(withName: "eyeIcon") as? SKSpriteNode {
                    guard let eyeImage = UIImage(systemName: "eye\(colorblindModeEnabled ? "" : ".fill")", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .regular, scale: .default))?.withTintColor(.white) else { return }
                    guard let eyeImageData = eyeImage.pngData() else { return }
                    guard let eyeTintedImage = UIImage(data: eyeImageData) else { return }
                    let eyeTexture = SKTexture(image: eyeTintedImage)
                    icon.texture = eyeTexture
                }
                // Save new settings
                colorblindModeEnabled = !colorblindModeEnabled
                UserDefaults.standard.setValue(colorblindModeEnabled, forKey: "colorblindModeEnabled")
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            // Get touched locations and nodes
            let location = touch.location(in: self)
            let touchedNodes = nodes(at: location)
            
            for node in touchedNodes {
                if let gift = node as? Gift {
                    var isWithinRange = true
                    var beforeRange = false
                    if let lastLocation = giftLocations.last {
                        // Check if gift is within maximum range and is vertical or horizontal from previous gift
                        isWithinRange = abs(lastLocation.x - gift.position.x) <= 77 && abs(lastLocation.y - gift.position.y) <= 85 && (lastLocation.x == gift.position.x || lastLocation.y == gift.position.y)
                        
                        let arrayCount = giftLocations.endIndex
                        if arrayCount >= 2 {
                            // Find the second-to-last location
                            let index = giftLocations.index(arrayCount, offsetBy: -2)
                            // If current location is closer to second-to-last location than last gift location is, beforeRange is true
                            beforeRange = abs(giftLocations[index].x - location.x) < abs(giftLocations[index].x - lastLocation.x) - 15 || abs(giftLocations[index].y - location.y) < abs(giftLocations[index].y - lastLocation.y) - 15
                        }
                    }
                    // If gift color is the same as original gift color, location is not already in the array, and gift is within range, append gift location
                    if gift.giftColor == firstColor && !giftLocations.contains(gift.position) && isWithinRange {
                        giftLocations.append(gift.position)
                    // Else if beforeRange, remove last gift location
                    } else if beforeRange {
                        giftLocations.removeLast()
                    }
                }
            }
            // Update line
            moveLine(currentLocation: location)
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Remove line
        line.removeFromParent()
        
        // If there is one or less gift locations in the array, reset values and return
        if giftLocations.endIndex <= 1 {
            firstColor = nil
            giftLocations.removeAll()
            return
        }
        
        // Remove connected gifts
        for location in giftLocations {
            let selectedNodes = nodes(at: location)
            
            for node in selectedNodes {
                if let gift = node as? Gift {
                    gift.removeFromParent()
                }
            }
        }
        // Move gifts above down
        moveGifts(giftLocations: giftLocations)
        
        // Calculate points and update score label
        let points = (giftLocations.endIndex - 1) * 10
        score += points
        scoreLabel?.removeFromParent()
        addScoreLabel()
        
        // Decrement moves
        moves! -= 1
        movesLabel?.removeFromParent()
        addMovesLabel()
        
        // Reset values
        firstColor = nil
        giftLocations.removeAll()
        
        // If score is greater or equal to the required score, user wins
        if score >= requiredScore! {
            // Save collected ornaments
            UserDefaults.standard.setValue(collectedOrnaments, forKey: "collectedOrnaments")
            
            // Present win scene
            let scene = TextView.newView()
            scene.text = "You won!"
            scene.level = levelNumber
            scene.win = true
            self.view?.presentScene(scene, transition: .moveIn(with: .up, duration: 0.8))
        // Else if moves is less than or equal to 0, user loses
        } else if moves! <= 0 {
            // Present lose scene
            let scene = TextView.newView()
            scene.text = "You lost :("
            scene.level = levelNumber
            scene.win = false
            self.view?.presentScene(scene, transition: .moveIn(with: .up, duration: 0.8))
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // If ornament exists and is at the bottom of the gameboard, remove ornament
        if self.contains(ornament!) && ornament?.position.y == 214 - size.height / 2 {
            ornament?.removeFromParent()
            let ornamentName = "ornament_\(levelNumber!)"
            // Append ornament name to array
            if !collectedOrnaments.contains(ornamentName) {
                collectedOrnaments.append(ornamentName)
            }
            // Move above gifts down
            moveGifts(giftLocations: [ornament!.position])
        }
    }
}
