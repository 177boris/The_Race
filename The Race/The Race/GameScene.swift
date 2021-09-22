//
//  GameScene.swift
//  The Race
//
//  Created by Lanre on 06/11/2017.
//  Copyright © 2017 Lanre Borishade. All rights reserved.
//

import UIKit
import SpriteKit
import SQLite3


class GameScene: SKScene , SKPhysicsContactDelegate {
  
  var isGameStarted = Bool(false)
  var isDied = Bool(false)
  
  
  var obstacleDelay = 0.8
  var obstacleTimer = CGFloat(0.005)
  
  var score = Int(0)
  var scoreLbl = SKLabelNode()
  var highscoreLbl = SKLabelNode()
  var taptoplayLbl = SKLabelNode()
  var restartBtn = SKSpriteNode()
  var pauseBtn = SKSpriteNode()
  var logoImg = SKSpriteNode()
  var wallPair = SKNode()
  var moveAndRemove = SKAction()
  var background = SKSpriteNode()
  
  
  //CREATE THE TEXTURE ATLAS FOR ANIMATION
  let astroAtlas = SKTextureAtlas(named:"player")
  var astroSprites = Array<Any>()
  var astro = SKSpriteNode()
  var repeatActionAstro = SKAction()
  
  
  override func didMove(to view: SKView) {
    //setup the game scene here
    
    self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    createScene()
    
    
  }
  
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //Determines what happens when the user touches the screen
    
    
    if isGameStarted == false{
      
      //1
      
      isGameStarted =  true
      astro.physicsBody?.affectedByGravity = true
      createPauseBtn()
    
      
      //2
      
      logoImg.run(SKAction.scale(to: 0.25, duration: 0.3), completion: {
        self.logoImg.removeFromParent()
      })
      
      taptoplayLbl.removeFromParent()
      
      //3
      
      self.astro.run(repeatActionAstro)
      
      
      //Obstacle movement and generation
      
      //1
      
      let spawn = SKAction.run({
        () in
        self.wallPair = self.createWalls()
        self.addChild(self.wallPair)
      })
      
      //2
      

      
      
      
      let delay = SKAction.wait(forDuration: obstacleDelay)
      let SpawnDelay = SKAction.sequence([spawn, delay])
      let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
      self.run(spawnDelayForever)
      
      
      
      //3
      
      let distance = CGFloat(self.frame.width + wallPair.frame.width)
      
      let movePillars = SKAction.moveBy(x: -distance - 80, y: 0, duration: TimeInterval(obstacleTimer * distance))
      
      let removePillars = SKAction.removeFromParent()
      moveAndRemove = SKAction.sequence([movePillars, removePillars])
      
      astro.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
      astro.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
    } else {
      
      //4
      
      if isDied == false {
        astro.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        astro.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
      }
    }
    for touch in touches{
      let location = touch.location(in: self)
      
      //1
      
      if isDied == true{
        if restartBtn.contains(location){
          if UserDefaults.standard.object(forKey: "highestScore") != nil {
            let hscore = UserDefaults.standard.integer(forKey: "highestScore")
            if hscore < Int(scoreLbl.text!)!{
              UserDefaults.standard.set(scoreLbl.text, forKey: "highestScore")
            }
          } else {
            UserDefaults.standard.set(0, forKey: "highestScore")
          }
          restartScene()
        }
      } else {
        
        //2
        
        if pauseBtn.contains(location){
          if self.isPaused == false{
            self.isPaused = true
            pauseBtn.texture = SKTexture(imageNamed: "play")
          } else {
            self.isPaused = false
            pauseBtn.texture = SKTexture(imageNamed: "pause")
          }
        }
      }
    }
  }
  
  
  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered
    
    moveScene()
    
    
  }
  
  func createScene(){
    
    //creates the background and scene of the game
    
    self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
    self.physicsBody?.categoryBitMask = CollisionBitMask.groundCategory
    self.physicsBody?.collisionBitMask = CollisionBitMask.astroCategory
    self.physicsBody?.contactTestBitMask = CollisionBitMask.astroCategory
    self.physicsBody?.isDynamic = false
    self.physicsBody?.affectedByGravity = false
    
    self.physicsWorld.contactDelegate = self
    self.backgroundColor = SKColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    
    //loop to make the background image move endlessly
    for i in 0...3
    {
      //specify the image used for background
      let background = SKSpriteNode(imageNamed: "space")
      background.name = "background"
      
      //specify the size of the background image, width of the phone screen and height of the phone screen
      background.size = CGSize(width: (self.scene?.size.width)!, height: ((self.scene?.size.height)!)*2)
      background.anchorPoint = CGPoint(x : 0.5, y: 0.5)
      
      //specify position of the background image
      background.position = CGPoint(x: CGFloat(i) * background.size.width, y: -(self.frame.size.height / 2))
      
      //add the background to the gamescene
      self.addChild(background)
      
    }
    
    //SET UP THE SPRITES FOR ANIMATION
    astroSprites.append(astroAtlas.textureNamed("rocket1"))
    astroSprites.append(astroAtlas.textureNamed("rocket1"))
    astroSprites.append(astroAtlas.textureNamed("rocket1"))
    
    
    self.astro = createAstro()
    self.addChild(astro)
    
    //ANIMATE THE CHARACTER AND REPEAT THE ANIMATION FOREVER
    let animateAstro = SKAction.animate(with: self.astroSprites as! [SKTexture], timePerFrame: 0.1)
    self.repeatActionAstro = SKAction.repeatForever(animateAstro)
    
    scoreLbl = createScoreLabel()
    self.addChild(scoreLbl)
    
    highscoreLbl = createHighscoreLabel()
    self.addChild(highscoreLbl)
    
    createLogo()
    
    taptoplayLbl = createTaptoplayLabel()
    self.addChild(taptoplayLbl)
  }
  
  
  func moveScene(){
    
    //function to create the infinite scrolling background
    
    self.enumerateChildNodes(withName: "background", using: ({
      (node,error) in
      
      node.position.x -= 2
      
      if node.position.x < -((self.scene?.size.width)!) {
        
        node.position.x += (self.scene?.size.width)! * 3
        
      }
      
    }))
  }
  
  func didBegin(_ contact: SKPhysicsContact) {
    let firstBody = contact.bodyA
    let secondBody = contact.bodyB
    
    if firstBody.categoryBitMask == CollisionBitMask.astroCategory && secondBody.categoryBitMask == CollisionBitMask.pillarCategory || firstBody.categoryBitMask == CollisionBitMask.pillarCategory && secondBody.categoryBitMask == CollisionBitMask.astroCategory || firstBody.categoryBitMask == CollisionBitMask.astroCategory && secondBody.categoryBitMask == CollisionBitMask.groundCategory || firstBody.categoryBitMask == CollisionBitMask.groundCategory && secondBody.categoryBitMask == CollisionBitMask.astroCategory {
      enumerateChildNodes(withName: "wallPair", using: ({
        (node, error) in
        node.speed = 0
        self.removeAllActions()
      }))
      if isDied == false{
        isDied = true
        //play crash sound effect
        run(SKAction.playSoundFileNamed("crashSound.wav", waitForCompletion: false))
        createRestartBtn()
        pauseBtn.removeFromParent()
        self.astro.removeAllActions()
        
      }
    } else if firstBody.categoryBitMask == CollisionBitMask.astroCategory && secondBody.categoryBitMask == CollisionBitMask.coinCategory {
      //play coin sound effect
      run(SKAction.playSoundFileNamed("coinSound.wav", waitForCompletion: false))
      //increase the score by 1
      score += 1
      scoreLbl.text = "\(score)"
      secondBody.node?.removeFromParent()
    } else if firstBody.categoryBitMask == CollisionBitMask.coinCategory && secondBody.categoryBitMask == CollisionBitMask.astroCategory {
      //play coin sound effect
      run(SKAction.playSoundFileNamed("coinSound.wav", waitForCompletion: false))
      //increase the score by 1
      score += 1
      scoreLbl.text = "\(score)"
      firstBody.node?.removeFromParent()
      
    }
  }
  
  func delayObstacles(){
    
    //check if score has gone up by 5
    
    let rem = score % 2
    
    //if score has gone up by 5, reduce obstacle delay by 0.1 seconds, obstacles generated faster over time
    if rem == 0 && obstacleDelay != 0.4{
      obstacleDelay = obstacleDelay - 0.2
      obstacleTimer = obstacleTimer - 0.002
      
      print("remainder : \(rem)")
      print("Delay: \(obstacleDelay)")
      print("Timer: \(obstacleTimer)")
      
    }
    
  }
  
  func updateScoresDB(){
    //SQLite database for scores
    
    var db: OpaquePointer?
    
    //create the file to save the score database
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Scores.sqlite")
    
    
    //open the database file and print an error message if it can't open the file
    if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
      print("error opening database")
    }
    
    //print statement to confirm that the program runs the function
    //print("Y")
    
    //create the scores table, ID as an integer and primary key, Score as an integer
    if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Scores (ID INTEGER PRIMARY KEY AUTOINCREMENT, Score INTEGER)", nil, nil,nil) != SQLITE_OK {
      let errmsg = String(cString: sqlite3_errmsg(db)!)
      print("error creating table: \(errmsg)")
    }
    
    //print statement to confirm that the program runs the function
    //print("Y")
    
    
    //insert score in table
    
    var stmt: OpaquePointer?
    
    //query to insert the score for each session into the scores table
    let queryString = "INSERT INTO Scores (Score) VALUES (?)"
    
    //prepare the SQL statement to insert score into the table
    if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
      let errmsg = String(cString: sqlite3_errmsg(db)!)
      print("error preparing insert: \(errmsg)")
      return
    }
    
    //save the score as a temporary variable for insertion
    let scoreTemp = (score)
    let scoreSTR = String(scoreTemp)
    
    //print the string to make sure it converts properly
    //print (scoreSTR)
    
    //Run the SQL query to insert the score
    if sqlite3_bind_int(stmt, 1, (scoreSTR as NSString).intValue) != SQLITE_OK{
      let errmsg = String(cString: sqlite3_errmsg(db)!)
      print("failure inserting score: \(errmsg)")
      return
    }
    
    //Check to see if the query was successful and the score has been recorded
    if sqlite3_step(stmt) != SQLITE_DONE {
      let errmsg = String(cString: sqlite3_errmsg(db)!)
      print("failure inserting score: \(errmsg)")
      return
    }
    
    //print statement to confirm the score has been recorded in the table
    //print("Score saved successfully")
    
  }
  
  
  
  //restart game when user collides with obstacle or edge of the screen
  func restartScene(){
    
    //update the scores database
    updateScoresDB()
    
    self.removeAllChildren()
    self.removeAllActions()
    isDied = false
    isGameStarted = false
    
    //store the score to display at the end of the next run
    //var previousScore = score
    
    
    //reset the score for the next run
    score = 0
    createScene()
  }
  
}
