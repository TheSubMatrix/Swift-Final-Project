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
    let spriteSize: CGSize = CGSize(width: 64, height: 64)
    var isRevealed: Bool = false
    var isFlagged: Bool = false
    var numberOfAdjacentBombs: Int = 0
    var lossAction: (() -> Void)?
    var clearedAction: (() -> Void)?
    let bombTexture = SKTexture(imageNamed: "TileMine")
    let tileTexture = SKTexture(imageNamed: "TileUnknown")
    let flagTexture = SKTexture(imageNamed: "TileFlag")
    let emptyTexture = SKTexture(imageNamed: "TileEmpty")
    let label = SKLabelNode()
    var adjacentTiles: [Tile] = []
    init(lossAction: @escaping () -> Void, clearedAction: @escaping () -> Void)
    {
        self.lossAction = lossAction
        self.clearedAction = clearedAction
        super.init(texture: tileTexture, color: .white, size: spriteSize)
        label.fontSize = 40
        label.fontColor = .black
        label.zPosition = 10
        label.verticalAlignmentMode = .center
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
    func ToggleFlag()
    {
        if(isRevealed) {return}
        isFlagged = !isFlagged
        self.texture = isFlagged ? flagTexture : tileTexture
    }
    func UpdateAdjacenctTiles(AdjacentTiles: [Tile])
    {
        adjacentTiles = AdjacentTiles
        for tile in adjacentTiles
        {
            if !tile.hasBomb{continue}
            numberOfAdjacentBombs += 1
        }
    }
    func OnActivated()
    {
        if(isFlagged || isRevealed){return}
        print(numberOfAdjacentBombs)
        if(hasBomb)
        {
            self.texture = bombTexture
            lossAction?()
            return
        }
        
        isRevealed = true  // Move this to happen first!
        self.texture = emptyTexture
        if numberOfAdjacentBombs > 0
        {
            label.text = "\(numberOfAdjacentBombs)"
            addChild(label)
            self.clearedAction?()
            return
        }
        self.clearedAction?()
        for tile in adjacentTiles {
            if !tile.isRevealed {
                tile.OnActivated()
            }
        }
    }
    func CheckTouch(touchPosition: CGPoint) -> Bool
    {
        return bounds.contains(touchPosition)
    }
}

class GameScene: SKScene
{
    let boardWidth: UInt = 10
    let boardHeight: UInt = 10
    let totalBombs : UInt = 10
    let tileSize: CGFloat = 64
    let scoreLabel = SKLabelNode()
    
    var remainingEmptyTiles: UInt = 0
    var board: [[Tile]] = []
    
    let minimumPressDuration: TimeInterval = 0.5
    func tileForTouchLocation(_ location: CGPoint) -> Tile? {
        let nodes = self.nodes(at: location)
        //Cool way of filtering nils!
        return nodes.compactMap { $0 as? Tile }.first
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .recognized, let view = self.view {
            let viewLocation = sender.location(in: view)
            let sceneLocation = self.convertPoint(fromView: viewLocation)
            if let tile = tileForTouchLocation(sceneLocation) {
                tile.OnActivated()
            }
        }
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began, let view = self.view {
            let viewLocation = sender.location(in: view)
            let sceneLocation = self.convertPoint(fromView: viewLocation)
            if let tile = tileForTouchLocation(sceneLocation) {
                tile.ToggleFlag()
            }
        }
    }
    func CreateBoard()
    {
        remainingEmptyTiles = boardWidth * boardHeight - totalBombs
        for row in 0..<Int(boardHeight)
        {
            var rowArray: [Tile] = []
            for col in 0..<Int(boardWidth)
            {
                let newTile = Tile(lossAction: GameOver, clearedAction: OnTileCleared)
                newTile.position = CalculateTilePosition(row: row, col: col)
                newTile.name = "Tile_\(row)_\(col)"
                rowArray.append(newTile)
                addChild(newTile)
            }
            board.append(rowArray)
        }
        PlaceBombs()
    }
    
    func CalculateTilePosition(row: Int, col: Int) -> CGPoint
    {
        let boardStartX = -(CGFloat(boardWidth) * tileSize) / 2.0 + tileSize / 2.0
        let boardStartY = -(CGFloat(boardHeight) * tileSize) / 2.0 + tileSize / 2.0
        let x = boardStartX + CGFloat(col) * tileSize
        let y = boardStartY + CGFloat(row) * tileSize
        return CGPoint(x: x, y: y)
    }
    func PlaceBombs()
    {
        if(totalBombs > boardWidth * boardHeight){return}
        var bombsPlaced: UInt = 0
        while bombsPlaced < totalBombs
        {
            let randomRow = Int.random(in: 0...Int(boardHeight) - 1)
            let randomCol = Int.random(in: 0...Int(boardWidth) - 1)
            let tile = board[randomRow][randomCol]
            if tile.hasBomb{continue}
            tile.PlaceBomb()
            bombsPlaced += 1
        }
    }
    func SetupNeighbors()
    {
        for row in 0..<Int(boardHeight)
        {
            for col in 0..<Int(boardWidth)
            {
                let currentTile = board[row][col]
                var neighbors: [Tile] = []
                for i in -1...1
                {
                    for j in -1...1
                    {
                        if i == 0 && j == 0 { continue }
                        let neighborRow = row + i
                        let neighborCol = col + j
                        if neighborRow >= 0 && neighborRow < Int(boardHeight) &&
                           neighborCol >= 0 && neighborCol < Int(boardWidth)
                        {
                            neighbors.append(board[neighborRow][neighborCol])
                        }
                    }
                }
                
                currentTile.UpdateAdjacenctTiles(AdjacentTiles: neighbors)
            }
        }
    }
    func OnTileCleared()
    {
        remainingEmptyTiles -= 1
        scoreLabel.text = "Remaining: \(remainingEmptyTiles)"
        if remainingEmptyTiles > 0 {return}
        
        guard let view = self.view else {return}
        if let winScene = GameCompleteScene(fileNamed: "WinScene") {
            winScene.scaleMode = .aspectFill
            view.presentScene(winScene)
        }
    }
    func GameOver()
    {
        guard let view = self.view else {return}
        if let winScene = GameCompleteScene(fileNamed: "LoseScene") {
            winScene.scaleMode = .aspectFill
            view.presentScene(winScene)
        }
    }
    override func didMove(to view: SKView)
    {
        CreateBoard()
        SetupNeighbors()
        
        //Figuring out how to set up gestures for holding and tapping was a giant pain
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        view.addGestureRecognizer(tapGesture)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        longPressGesture.minimumPressDuration = minimumPressDuration
        view.addGestureRecognizer(longPressGesture)
        tapGesture.require(toFail: longPressGesture)
        
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = .white
        scoreLabel.zPosition = 10
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: 0, y: (CGFloat(boardHeight) * tileSize) / 2 + 50)
        scoreLabel.text = "Remaining: \(remainingEmptyTiles)"
        addChild(scoreLabel)
    }
}
