//
//  GameScene.swift
//  ColorGame
//
//  Created by Arman Husic on 3/27/19.
//  Copyright © 2019 Arman Husic. All rights reserved.
//

import SpriteKit
import GameplayKit


// enumerate 3 enemies
enum Enemies: Int {
    case small
    case medium
    case large
}




class GameScene: SKScene {
    
    var tracksArray:[SKSpriteNode]?  = [SKSpriteNode]()
    var player:SKSpriteNode?
    
    var currentTrack = 0
    var movingToTrack = false
    
    
    let moveSound = SKAction.playSoundFileNamed("move.wav", waitForCompletion: false)
    
    // values for speed of enemy, direction enemy blocks are travelling
    let trackVelocities = [180, 200, 250]
    var directionArray = [Bool]()
    var velocityArray = [Int]()
    
    func setupTracks(){
        for i in 0 ... 8 {
            // wer using with name i becuz our sprites r named 0 ... 8
            if let track = self.childNode(withName: "\(i)") as? SKSpriteNode{
                tracksArray?.append(track)
            }
        }
    }
    
    
    
    // Create the player and add animation to centerpoint of sprite
    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        // access the initialized array and place the player in the middle of the first track
        guard let playerPosition = tracksArray?.first?.position.x else {
            return
        }
        // self refers to game scene and getting its size / 2 = midpoint
        player?.position = CGPoint(x: playerPosition, y: self.size.height / 2)
        
        //add to node tree, force unwrap player only if initialized correctly or put this in gaurd statement
        self.addChild(player!)
        
        let pulseAnimation = SKEmitterNode(fileNamed: "spark")!
        player?.addChild(pulseAnimation)
        pulseAnimation.position = CGPoint(x: 0, y: 0)
        
        
    }
    
    // create enemies for player to interact with
    func createEnemy(type: Enemies, forTrack track:Int) -> SKShapeNode? {
        let enemySprite = SKShapeNode()
        enemySprite.name = "ENEMY"
        switch type {
        case .small:
            enemySprite.path = CGPath(roundedRect: CGRect(x: -10, y: 0, width:20, height: 70), cornerWidth: 8, cornerHeight: 8, transform: nil)
            enemySprite.fillColor = UIColor(red: 0.4431, green: 0.5529, blue: 0.7451, alpha: 1)
        case .medium:
            enemySprite.path = CGPath(roundedRect: CGRect(x: -10, y: 0, width:20, height: 100), cornerWidth: 8, cornerHeight: 8, transform: nil)
            enemySprite.fillColor = UIColor(red: 0.7804, green: 0.4039, blue: 0.4039, alpha: 1)
        case .large:
            enemySprite.path = CGPath(roundedRect: CGRect(x: -10, y: 0, width:20, height: 130), cornerWidth: 8, cornerHeight: 8, transform: nil)
            enemySprite.fillColor = UIColor(red: 0.7804, green: 0.6392, blue: 0.4039, alpha: 1)
            
        }
        
        guard let enemyPosition = tracksArray?[track].position else {return nil}
        
        let up = directionArray[track]
        
        enemySprite.position.x = enemyPosition.x
        enemySprite.position.y = up ? -130 : self.size.height + 130
        
        
        enemySprite.physicsBody = SKPhysicsBody(edgeLoopFrom: enemySprite.path!)
        enemySprite.physicsBody?.velocity = up ? CGVector(dx: 0, dy: velocityArray[track]) : CGVector(dx: 0, dy: -velocityArray[track])
        
        
        return enemySprite
        
    }
    
    // spawn enemies func to be called in didMoveToView
    func spawnEnemies () {
        // we are looping through tracks 1 - 7, none on (0,8)
        for i in 1 ... 7 {
            let randomEnemyType = Enemies(rawValue: GKRandomSource.sharedRandom().nextInt(upperBound: 3))!
            if let newEnemy = createEnemy(type: randomEnemyType, forTrack: i){
                self.addChild(newEnemy)
            }
        }
        self.enumerateChildNodes(withName: "ENEMY") { (node: SKNode, nil) in
            //going thru each child nodes looking for children with name ENEMY
            if node.position.y < -150 || node.position.y >  self.size.height + 150 {
                // if the enemy leaves the screen area remove the node
                node.removeFromParent()
            }
        }
    }
    
    
    override func didMove(to view: SKView) {
        setupTracks()
        createPlayer()
        
        tracksArray?.first?.color = UIColor.green
        
        //check if tracks are available
        if let numOfTracks = tracksArray?.count {
            for _ in 0 ... numOfTracks {
                // random velocity with upper bound 0-2 corresponding to the 0-2 velocities in our velocity array
                let randomNumberForVelocity = GKRandomSource.sharedRandom().nextInt(upperBound: 3)
                velocityArray.append(trackVelocities[randomNumberForVelocity])
                directionArray.append(GKRandomSource.sharedRandom().nextBool())
            }
        }
        
        // a sequence that repeats forever to spawn enemies every 2 seconds
        self.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
            self.spawnEnemies()
            }, SKAction.wait(forDuration: 2)])))
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.previousLocation(in: self)
            let node = self.nodes(at: location).first
            
            if node?.name == "right" {
                moveToNextTrack()
            } else if node?.name == "up" {
                moveVertically(up: true)
            } else if node?.name == "down" {
                moveVertically(up: false)
            }
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !movingToTrack {
            player?.removeAllActions()
        }
    }
    
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        player?.removeAllActions()
    }

    
    
    func moveToNextTrack() {
        player?.removeAllActions()
        movingToTrack = true
        
        guard let nextTrack = tracksArray?[currentTrack + 1].position else {
           return
        }
        if let player = self.player {
            let moveAction = SKAction.move(to: CGPoint(x: nextTrack.x, y: player.position.y), duration: 0.2)
            player.run(moveAction) {
                self.movingToTrack = false
            }
            
            currentTrack += 1
            
            self.run(moveSound)
            
        }
    }
    
    func moveVertically(up:Bool) {
        if up {
            let moveAction = SKAction.moveBy(x: 0, y: 3, duration: 0.01)
            let repeatAction = SKAction.repeatForever(moveAction)
            player?.run(repeatAction)
        }else {
            let moveAction = SKAction.moveBy(x: 0, y: -3, duration: 0.01)
            let repeatAction = SKAction.repeatForever(moveAction)
            player?.run(repeatAction)
        }
    }
    
    
}
