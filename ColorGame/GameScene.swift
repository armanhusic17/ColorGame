//
//  GameScene.swift
//  ColorGame
//
//  Created by Arman Husic on 3/27/19.
//  Copyright © 2019 Arman Husic. All rights reserved.
//

import SpriteKit
import GameplayKit



class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    
    var tracksArray:[SKSpriteNode]?  = [SKSpriteNode]()
    var player:SKSpriteNode?
    var target:SKSpriteNode?
    var currentTrack = 0
    var movingToTrack = false
    
    
    let moveSound = SKAction.playSoundFileNamed("move.wav", waitForCompletion: false)
    
    // values for speed of enemy, direction enemy blocks are travelling
    let trackVelocities = [180, 200, 250]
    var directionArray = [Bool]()
    var velocityArray = [Int]()
    
    
    // Bitmask Categories for collision detection
    let playerCategory:UInt32 = 0x1 << 0 // 1
    let enemyCategory:UInt32 = 0x1 << 1  // 2
    let targetCategory:UInt32 = 0x1 << 2 // 4
    
    
    // Game Entry Point
    override func didMove(to view: SKView) {
        setupTracks()
        createPlayer()
        createTarget()
        
        // notifications about contacts between objects
        self.physicsWorld.contactDelegate = self
        
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
    
    
    
    
    // Touch / Movement Controls
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
    
    // Stopping player movement
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !movingToTrack {
            player?.removeAllActions()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        player?.removeAllActions()
    }
    
    // function dealing with all contacts
    func didBegin(_ contact: SKPhysicsContact) {
        var playerBody:SKPhysicsBody
        var otherBody:SKPhysicsBody
        
        
        //check if bodyA or bodyB is the player -> if this condition is true player is always bodyA
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            playerBody = contact.bodyA
            otherBody = contact.bodyB
            
        } else {
            // reverse of the above logic
            playerBody = contact.bodyB
            otherBody = contact.bodyA
        }
        
        if playerBody.categoryBitMask == playerCategory && otherBody.categoryBitMask == enemyCategory {
            print("ENEMY HIT")
        } else if playerBody.categoryBitMask == playerCategory && otherBody.categoryBitMask == targetCategory{
            print("TARGET HIT")
        }
        
    }
    
    
}
