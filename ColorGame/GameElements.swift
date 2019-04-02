//
//  GameElements.swift
//  ColorGame
//
//  Created by Arman Husic on 4/2/19.
//  Copyright © 2019 Arman Husic. All rights reserved.
//

import SpriteKit
import GameplayKit



// enumerate 3 enemy tyes
enum Enemies: Int {
    case small
    case medium
    case large
}

extension GameScene {
    
    
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
        // initialize player to skspritenode image named player
        player = SKSpriteNode(imageNamed: "player")
        // give player a physics body
        player?.physicsBody = SKPhysicsBody(circleOfRadius: player!.size.width / 2)
        player?.physicsBody?.linearDamping = 0
        player?.physicsBody?.categoryBitMask = playerCategory
        player?.physicsBody?.collisionBitMask = 0 // deactivate the bitmask so it does not infulence all other aspects such as target
        player?.physicsBody?.contactTestBitMask = enemyCategory | targetCategory  // notified when interacting with enemy and also the target
        
        
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
    
    
    
    // create target function
    func createTarget() {
        target = self.childNode(withName: "target") as? SKSpriteNode
        target?.physicsBody = SKPhysicsBody(circleOfRadius: target!.size.width / 2)
        //for the actual collision
        target?.physicsBody?.categoryBitMask = targetCategory
        
        // can add a line of code that disbles collision for the target
        target?.physicsBody?.collisionBitMask = 0
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
        enemySprite.physicsBody?.categoryBitMask = enemyCategory
        enemySprite.physicsBody?.velocity = up ? CGVector(dx: 0, dy: velocityArray[track]) : CGVector(dx: 0, dy: -velocityArray[track])
        
        
        return enemySprite
        
    }
    
    
    
    
    
    
    
}
