//
//  GameScene.swift
//  Final Project
//
//  Created by Colin Whiteford on 11/19/25.
//

import SpriteKit
import GameplayKit

public class Tile: SKSpriteNode
{
    let spriteSize: CGSize = CGSize(width: 32, height: 32)
    var isRevealed: Bool = false
    var isFlagged: Bool = false
    var numberOfAdjacentBombs: Int = 0
    var lossAction: (() -> Void)?
    var clearedAction: (() -> Void)?
    var bombTexture = SKTexture(imageNamed: "bomb")
    var tileTexture = SKTexture(imageNamed: "tile")
    var flagTexture = SKTexture(imageNamed: "flag")
    var emptyTexture = SKTexture(imageNamed: "emptyTexture")
    var label = SKLabelNode()
    var adjacentTiles: [Tile] = []
    init(lossAction: @escaping () -> Void, clearedAction: @escaping () -> Void)
    {
        self.lossAction = lossAction
        self.clearedAction = clearedAction
        super.init(texture: tileTexture, color: .white, size: spriteSize)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    var hasBomb: Bool = false
    func PlaceBomb()
    {
        hasBomb = true
    }
    func FlagSpace()
    {
        isFlagged = true
        self.texture = flagTexture
    }
    func UpdateAdjacenctTiles(AdjacentTiles: [Tile])
    {
        adjacentTiles = AdjacentTiles
        for tile in adjacentTiles
        {
            if !tile.hasBomb{continue}
            numberOfAdjacentBombs += 1
        }
        label.text = "\(numberOfAdjacentBombs)"
    }
    func OnActivated()
    {
        if(isFlagged){return}
        if(hasBomb)
        {
            self.texture = bombTexture
            lossAction?()
            return
        }
        self.texture = emptyTexture
        self.clearedAction?()
        if(numberOfAdjacentBombs <= 0){return}
        else
        {
            for tile in adjacentTiles
            {
                if tile.numberOfAdjacentBombs <= 0{continue}
                tile.OnActivated()
            }
        }
        addChild(label)
    }
    
}

class GameScene: SKScene
{
    let boardWidth: UInt32 = 10
    let boardHeight: UInt32 = 10
    var board: [[Tile]] = []
    override func didMove(to view: SKView)
    {

    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
 
    }
    

    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
