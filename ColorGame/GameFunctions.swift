//
//  GameFunctions.swift
//  ColorGame
//
//  Created by Arman Husic on 4/2/19.
//  Copyright © 2019 Arman Husic. All rights reserved.
//

import SpriteKit
import GameplayKit

extension GameScene {
    
    // create a timer
    func launchGameTimer() {
        // repeat sequence to minus 1 from time every 1 second
        let timeAction = SKAction.repeatForever(SKAction.sequence([SKAction.run({
            self.remainingTime -= 1
        }), SKAction.wait(forDuration: 1)]))
        
        //add to time label
        timeLabel?.run(timeAction)
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
    
    func moveToNextTrack() {
        player?.removeAllActions()
        movingToTrack = true
        
        guard let nextTrack = tracksArray?[currentTrack + 1].position else {
            return
        }
        if let player = self.player {
            
            let moveAction = SKAction.move(to: CGPoint(x: nextTrack.x, y: player.position.y), duration: 0.2)
            
            let up = directionArray[currentTrack+1]
            
            player.run(moveAction) {
                self.movingToTrack = false
                
                // check if current track is not the last track with the target
                if self.currentTrack != 8 {
                    // inside enclosure we can call self checking if player is moving up or down to add appropriate velocity
                    self.player?.physicsBody?.velocity = up ? CGVector(dx: 0, dy: self.velocityArray[self.currentTrack]) : CGVector(dx: 0, dy: -self.velocityArray[self.currentTrack])
                    
                }else {
                    //stop movement
                    self.player?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                }
             }
            
            currentTrack += 1
            
            self.run(moveSound)
        }
    }
    
    // spawn enemies func to be called in didMoveToView
    func spawnEnemies () {
        // create place to call powerup
        var randomTrackNumber = 0
        let createPowerUp = GKRandomSource.sharedRandom().nextBool()
        
        if createPowerUp {
            randomTrackNumber = GKRandomSource.sharedRandom().nextInt(upperBound: 6) + 1
            if let powerUpObject = self.createPowerUp(forTrack: randomTrackNumber){
                self.addChild(powerUpObject)
            }
        }
        
        
        // we are looping through tracks 1 - 7, none on (0,8)
        for i in 1 ... 7 {
            
            if randomTrackNumber != i {
                let randomEnemyType = Enemies(rawValue: GKRandomSource.sharedRandom().nextInt(upperBound: 3))!
                if let newEnemy = createEnemy(type: randomEnemyType, forTrack: i){
                    self.addChild(newEnemy)
                }
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
    
    // Move player back to the start -> if player ends up sliding off the screen with a track
    func movePlayerToStart() {
        //must unwrap optional player to see if it is available
        if let player = self.player {
            // remove it from the gamescene
            player.removeFromParent()
            // get rid of the player
            self.player = nil
            //create a new player
            self.createPlayer()
            // reset the current track back to the start
            self.currentTrack = 0
        }
    }
    
    
    
    // Function that uses the reward animation fireworks
    func nextLevel (playerPhysicsBody:SKPhysicsBody) {
        // add points here because nextLevel is level reset
        currentScore += 1
        
        self.run(SKAction.playSoundFileNamed("levelUp", waitForCompletion: true))
        // attach the fireworks to the player
        let emitter = SKEmitterNode(fileNamed: "fireworks.sks")
        playerPhysicsBody.node?.addChild(emitter!)
        
        self.run(SKAction.wait(forDuration: 0.5)){
            emitter?.removeFromParent()
            self.movePlayerToStart()
        }
    }
    
    
    
}
