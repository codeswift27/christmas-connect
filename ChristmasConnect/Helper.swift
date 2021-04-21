//
//  Helper.swift
//  ChristmasConnect
//
//  Created by Lexline Johnson on 1/7/21.
//

import SpriteKit
import SwiftUI

class Helper {
    //  Set up levels
    func initializeLevels() -> [Level] {
        let view = MapView.newView()
        
        // Set values
        let levelOne = Level(location: CGPoint(x: 404 - view.size.width / 2, y: 171 - view.size.height / 2), levelNumber: 1, requiredScore: 200, moves: 15, isComplete: UserDefaults.standard.bool(forKey: "levelOne"), isCurrent: false, isEnd: false)
        let levelTwo = Level(location: CGPoint(x: 237 - view.size.width / 2, y: 346 - view.size.height / 2), levelNumber: 2, requiredScore: 400, moves: 20, isComplete: UserDefaults.standard.bool(forKey: "levelTwo"), isCurrent: false, isEnd: false)
        let levelThree = Level(location: CGPoint(x: 504 - view.size.width / 2, y: 512 - view.size.height / 2), levelNumber: 3, requiredScore: 600, moves: 24, isComplete: UserDefaults.standard.bool(forKey: "levelThree"), isCurrent: false, isEnd: false)
        let levelFour = Level(location: CGPoint(x: 304 - view.size.width / 2, y: 714 - view.size.height / 2), levelNumber: 4, requiredScore: 800, moves: 26, isComplete: UserDefaults.standard.bool(forKey: "levelFour"), isCurrent: false, isEnd: false)
        let levelFive = Level(location: CGPoint(x: 434 - view.size.width / 2, y: 966 - view.size.height / 2), levelNumber: 5, requiredScore: 1000, moves: 30, isComplete: UserDefaults.standard.bool(forKey: "levelFive"), isCurrent: false, isEnd: false)
        let levelSix = Level(location: CGPoint(x: 0, y: 1225 - view.size.height / 2), levelNumber: 6, requiredScore: nil, moves: nil, isComplete: UserDefaults.standard.bool(forKey: "levelSix"), isCurrent: false, isEnd: true)
        
        // Create array
        let levels = [levelOne, levelTwo, levelThree, levelFour, levelFive, levelSix]
        return levels
    }
    
    // Save completed points
    func savePoints(points: [CGPoint]) {
        do {
            // Encode points to JSON
            let encoder = JSONEncoder()
            let data = try encoder.encode(points)
            // Save data
            UserDefaults.standard.setValue(data, forKey: "completedPoints")
        } catch {
            print("Could not save points")
            return
        }
    }
    
    // Retrieve completed points
    func decodePoints() -> [CGPoint]? {
        // Retrieve data
        guard let data = UserDefaults.standard.data(forKey: "completedPoints") else {
            print("Could not retrieve data")
            return nil
        }
        
        do {
            // Decode JSON data and return value
            let decoder = JSONDecoder()
            let points = try decoder.decode([CGPoint].self, from: data)
            return points
        } catch {
            print("Could not decode data")
            return nil
        }
    }
    
    // Return a random color
    func randomColor() -> Color {
        let randomNumber = Int(arc4random_uniform(4))
        
        switch randomNumber {
        case 0:
            return Color.blue
        case 1:
            return Color.green
        case 2:
            return Color.pink
        case 3:
            return Color.yellow
        default:
            return Color.blue
        }
    }
}
