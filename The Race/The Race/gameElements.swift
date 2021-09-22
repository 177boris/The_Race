//
//  gameElements.swift
//  The Race
//
//  Created by lanre on 06/11/2017.
//  Copyright © 2017 Lanre Borishade. All rights reserved.
//

import SpriteKit

struct CollisionBitMask {
    static let astroCategory:UInt32 = 0x1 << 0
    static let pillarCategory:UInt32 = 0x1 << 1
    static let coinCategory:UInt32 = 0x1 << 2
    static let groundCategory:UInt32 = 0x1 << 3
}

extension GameScene {
    
    // function to create the character icon - astro
    func createAstro() -> SKSpriteNode {
        
        //astro is character icon
        
        //1
        let astro = SKSpriteNode(texture: SKTextureAtlas(named:"player").textureNamed("rocket1"))
        astro.size = CGSize(width: 50, height: 50)
        astro.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
        
        //2
        astro.physicsBody = SKPhysicsBody(circleOfRadius: astro.size.width / 2)
        astro.physicsBody?.linearDamping = 1.1
        astro.physicsBody?.restitution = 0
        
        //3
        astro.physicsBody?.categoryBitMask = CollisionBitMask.astroCategory
        astro.physicsBody?.collisionBitMask = CollisionBitMask.pillarCategory | CollisionBitMask.groundCategory
        astro.physicsBody?.contactTestBitMask = CollisionBitMask.pillarCategory | CollisionBitMask.coinCategory | CollisionBitMask.groundCategory
        
        //4
        astro.physicsBody?.affectedByGravity = false
        astro.physicsBody?.isDynamic = true
        
        return astro
    }
    
    //1 create restart button
    func createRestartBtn() {
        restartBtn = SKSpriteNode(imageNamed: "restart")
        restartBtn.size = CGSize(width:100, height:100)
        restartBtn.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        restartBtn.zPosition = 6
        restartBtn.setScale(0)
        self.addChild(restartBtn)
        restartBtn.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    //2 create pause button
    func createPauseBtn() {
        pauseBtn = SKSpriteNode(imageNamed: "pause")
        pauseBtn.size = CGSize(width:40, height:40)
        pauseBtn.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 300)
        pauseBtn.zPosition = 6
        self.addChild(pauseBtn)
    }
    
    //3 create score label
    func createScoreLabel() -> SKLabelNode {
        let scoreLbl = SKLabelNode()
        scoreLbl.position = CGPoint(x: self.frame.width - 250, y: self.frame.midY + 300)
        scoreLbl.text = "\(score)"
        scoreLbl.zPosition = 5
        scoreLbl.fontSize = 20
        scoreLbl.fontName = "HelveticaNeue-BoldItalic"
        scoreLbl.fontColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1.0)

        return scoreLbl
    }
    
    //4 create high score label
    func createHighscoreLabel() -> SKLabelNode {
        let highscoreLbl = SKLabelNode()
        highscoreLbl.position = CGPoint(x: self.frame.width - 470, y: self.frame.midY + 300)
        if let highestScore = UserDefaults.standard.object(forKey: "highestScore"){
            highscoreLbl.text = "High Score: \(highestScore)"
        } else {
            highscoreLbl.text = "High Score: 0"
        }
        highscoreLbl.zPosition = 5
        highscoreLbl.fontSize = 15
        highscoreLbl.fontName = "HelveticaNeue-BoldItalic"
        highscoreLbl.fontColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1.0)
        return highscoreLbl
    }
    
    //5 create game logo
    func createLogo() {
        logoImg = SKSpriteNode()
        logoImg = SKSpriteNode(imageNamed: "logo")
        logoImg.size = CGSize(width: 400, height: 250)
        logoImg.position = CGPoint(x:self.frame.midX, y:self.frame.midY + 100)
        logoImg.setScale(0.5)
        self.addChild(logoImg)
        logoImg.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    //6 create tap to play label
    func createTaptoplayLabel() -> SKLabelNode {
        let taptoplayLbl = SKLabelNode()
        taptoplayLbl.position = CGPoint(x:self.frame.midX, y:self.frame.midY - 200)
        taptoplayLbl.text = "Tap to play"
        taptoplayLbl.fontColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1.0)
        taptoplayLbl.zPosition = 5
        taptoplayLbl.fontSize = 25
        taptoplayLbl.fontName = "HelveticaNeue-BoldItalic"
        return taptoplayLbl
    }
    
    //create pillars 
    func createWalls() -> SKNode  {
        // 1
        let coinNode = SKSpriteNode(imageNamed: "coin")
        coinNode.size = CGSize(width: 50, height: 50)
        coinNode.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2)
        coinNode.physicsBody = SKPhysicsBody(rectangleOf: coinNode.size)
        coinNode.physicsBody?.affectedByGravity = false
        coinNode.physicsBody?.isDynamic = false
        coinNode.physicsBody?.categoryBitMask = CollisionBitMask.coinCategory
        coinNode.physicsBody?.collisionBitMask = 0
        coinNode.physicsBody?.contactTestBitMask = CollisionBitMask.astroCategory
        coinNode.color = SKColor.blue
        
        // 2
        wallPair = SKNode()
        wallPair.name = "wallPair"
        
        let topWall = SKSpriteNode(imageNamed: "pillar")
        let btmWall = SKSpriteNode(imageNamed: "pillar")
        
        topWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 + 420)
        btmWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 - 420)
        
        topWall.setScale(0.5)
        btmWall.setScale(0.5)
        
        
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = CollisionBitMask.pillarCategory
        topWall.physicsBody?.collisionBitMask = CollisionBitMask.astroCategory
        topWall.physicsBody?.contactTestBitMask = CollisionBitMask.astroCategory
        topWall.physicsBody?.isDynamic = false
        topWall.physicsBody?.affectedByGravity = false
        
        
        btmWall.physicsBody = SKPhysicsBody(rectangleOf: btmWall.size)
        btmWall.physicsBody?.categoryBitMask = CollisionBitMask.pillarCategory
        btmWall.physicsBody?.collisionBitMask = CollisionBitMask.astroCategory
        btmWall.physicsBody?.contactTestBitMask = CollisionBitMask.astroCategory
        btmWall.physicsBody?.isDynamic = false
        btmWall.physicsBody?.affectedByGravity = false
        
        topWall.zRotation = CGFloat(Double.pi)
        
        wallPair.addChild(topWall)
        wallPair.addChild(btmWall)
        
        wallPair.zPosition = 1
        
        // 3
        let randomPosition = random(min: -275.0, max: -100.0)
        wallPair.position.y = wallPair.position.y +  randomPosition
        wallPair.addChild(coinNode)
        
        wallPair.run(moveAndRemove)
        
        return wallPair
    }
    func random() -> CGFloat{
        return CGFloat(Double(arc4random()) / 0xFFFFFFFF)
    }
    func random(min : CGFloat, max : CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }
    
    }



    

