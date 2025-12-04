//
//  Main Menu.swift
//  Final Project
//
//  Created by Colin Whiteford on 12/3/25.
//

import Foundation
import SpriteKit
import GameplayKit
class MainMenu : SKScene
{
    var button : SKNode?
    override func didMove(to view: SKView)
    {
        button = childNode(withName: "Play Button")
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        guard let button = button else {return}
        let location = touch.location(in: self)
        if button.frame.contains(location)
        {
            if let newScene = SKScene(fileNamed: "GameScene") as? GameScene
            {
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                newScene.scaleMode = .aspectFill
                scene?.view?.presentScene(newScene, transition: transition)
            }
        }
    }
}
