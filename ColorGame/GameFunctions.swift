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
            player.run(moveAction) {
                self.movingToTrack = false
            }
            
            currentTrack += 1
            
            self.run(moveSound)
        }
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
    
    
    
    
    
    
}
