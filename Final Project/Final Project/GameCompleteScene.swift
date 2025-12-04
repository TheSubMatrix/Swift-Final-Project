//
//  Win Scene.swift
//  Final Project
//
//  Created by Colin Whiteford on 12/1/25.
//

import Foundation
import SpriteKit
import GameplayKit

class GameCompleteScene : SKScene
{
    var replayButton : SKNode?
    var mainMenuButton : SKNode?
    override func didMove(to view: SKView)
    {
        replayButton = childNode(withName: "Play Again Button")
        mainMenuButton = childNode(withName: "Main Menu Button")
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        if replayButton!.frame.contains(location)
        {
            if let newScene = SKScene(fileNamed: "GameScene") as? GameScene
            {
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                newScene.scaleMode = .aspectFill
                scene?.view?.presentScene(newScene, transition: transition)
            }
        }
        if mainMenuButton!.frame.contains(location)
        {
            if let newScene = SKScene(fileNamed: "MainMenu") as? MainMenu
            {
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                newScene.scaleMode = .aspectFill
                scene?.view?.presentScene(newScene, transition: transition)
            }
        }
    }
}
