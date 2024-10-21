//
//  GameScene.swift
//  Commotion
//
//  Created by Eric Larson on 9/6/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//

import UIKit
import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {

    //@IBOutlet weak var scoreLabel: UILabel!
    
    // MARK: Raw Motion Functions
    let motion = CMMotionManager()
    func startMotionUpdates(){
        // some internal inconsistency here: we need to ask the device manager for device
        
        if self.motion.isDeviceMotionAvailable{
            self.motion.deviceMotionUpdateInterval = 0.1
            self.motion.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: self.handleMotion )
        }
    }
    
    func handleMotion(_ motionData:CMDeviceMotion?, error:Error?){
        if let gravity = motionData?.gravity {
            self.physicsWorld.gravity = CGVector(dx: CGFloat(9.8*gravity.x), dy: CGFloat(9.8*gravity.y))
        }
    }
    
    // MARK: View Hierarchy Functions
    let spinBlock = SKSpriteNode()
    let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    var score:Int = 0 {
        willSet(newValue){
            DispatchQueue.main.async{
                self.scoreLabel.text = "Score: \(newValue)"
            }
        }
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.darkGray
        
        // start motion for gravity
        self.startMotionUpdates()
        
        // make sides to the screen
        self.addSidesAndTop()
        
        // add some stationary blocks
        
        //sets up plinko game
        self.addPlinkoGrid()
        self.addEntryBumpers()
        self.addContainers()
        
        // add a spinning block
//        self.addBlockAtPoint(CGPoint(x: size.width * 0.5, y: size.height * 0.35))
        
        self.addPuck()
        
        self.addScore()
        
        self.score = 0
    }
    
    // MARK: Create Sprites Functions
    func addScore(){
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = SKColor.blue
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY)
        
        addChild(scoreLabel)
    }
    
    
    func addPuck(){
        let radius = size.width*0.15
        let mask = SKShapeNode(circleOfRadius: radius)
        
        mask.fillColor = .white
        mask.strokeColor = .clear
        
        let puckImg = SKSpriteNode(imageNamed: "fireball")
        puckImg.size = CGSize(width:radius,height:radius)
        
        let puckA = SKCropNode()
        puckA.maskNode = mask
        puckA.addChild(puckImg)
        
        let randNumber = random(min: CGFloat(0.1), max: CGFloat(0.9))
        puckA.position = CGPoint(x: size.width * randNumber, y: size.height * 0.9)
        
        puckA.physicsBody = SKPhysicsBody(circleOfRadius:radius/2)
        puckA.physicsBody?.restitution = random(min: CGFloat(0.8), max: CGFloat(1.0))
        puckA.physicsBody?.isDynamic = true
        puckA.physicsBody?.contactTestBitMask = 0x00000001
        puckA.physicsBody?.collisionBitMask = 0x00000001
        puckA.physicsBody?.categoryBitMask = 0x00000001
        
        self.addChild(puckA)
    }
    
    func addBlockAtPoint(_ point:CGPoint){
        
        spinBlock.color = UIColor.red
        spinBlock.size = CGSize(width:size.width*0.15,height:size.height * 0.05)
        spinBlock.position = point
        
        spinBlock.physicsBody = SKPhysicsBody(rectangleOf:spinBlock.size)
        spinBlock.physicsBody?.contactTestBitMask = 0x00000001
        spinBlock.physicsBody?.collisionBitMask = 0x00000001
        spinBlock.physicsBody?.categoryBitMask = 0x00000001
        spinBlock.physicsBody?.isDynamic = true
        spinBlock.physicsBody?.pinned = true
        
        self.addChild(spinBlock)

    }
    
    func addStaticBlockAtPoint(_ point:CGPoint, color myCol:UIColor){
        let radius = size.width*0.05
        let block = SKShapeNode(circleOfRadius: radius)
        
        block.fillColor = myCol
        block.position = point
        
        block.physicsBody = SKPhysicsBody(circleOfRadius:radius)
        block.physicsBody?.isDynamic = false
        block.physicsBody?.pinned = true
        
        self.addChild(block)
        
    }
    
    func addSidesAndTop(){
        let left = SKSpriteNode()
        let right = SKSpriteNode()
       
        
        left.size = CGSize(width:size.width*0.01,height:size.height)
        left.position = CGPoint(x:0, y:size.height*0.5)
        
        right.size = CGSize(width:size.width*0.01,height:size.height)
        right.position = CGPoint(x:size.width, y:size.height*0.5)
        
        for obj in [left,right]{
            obj.color = UIColor.darkGray
            obj.physicsBody = SKPhysicsBody(rectangleOf:obj.size)
            obj.physicsBody?.isDynamic = true
            obj.physicsBody?.pinned = true
            obj.physicsBody?.allowsRotation = false
            self.addChild(obj)
        }
    }
    
    func addPlinkoGrid(){
        
        //top pegs
        self.addStaticBlockAtPoint(CGPoint(x: size.width * 0.5, y: size.height * 0.55), color:UIColor.red)
        
        //second row
        self.addStaticBlockAtPoint(CGPoint(x: size.width * 0.35, y: size.height * 0.4), color:UIColor.blue)
        self.addStaticBlockAtPoint(CGPoint(x: size.width * 0.65, y: size.height * 0.4), color:UIColor.blue)
        
        //third row
        self.addStaticBlockAtPoint(CGPoint(x: size.width * 0.23, y: size.height * 0.23), color:UIColor.green)
        self.addStaticBlockAtPoint(CGPoint(x: size.width * 0.5, y: size.height * 0.23), color:UIColor.green)
        self.addStaticBlockAtPoint(CGPoint(x: size.width * 0.77, y: size.height * 0.23), color:UIColor.green)
    }
    
    func addEntryBumpers(){
        self.addStaticBlockAtPoint(CGPoint(x: size.width * 0.5, y: size.height * 0.81), color:UIColor.red)
        
        let left = SKSpriteNode()
        let right = SKSpriteNode()
        
        left.size = CGSize(width:size.width*0.04,height:size.width*0.6)
        left.position = CGPoint(x:size.width*0.1, y:size.height*0.8)
        left.zRotation = .pi/3
        
        right.size = CGSize(width:size.width*0.04,height:size.width*0.6)
        right.position = CGPoint(x:size.width*0.9, y:size.height*0.8)
        right.zRotation = (.pi/3) * -1
        
        for obj in [left,right]{
            obj.color = UIColor.yellow
            obj.physicsBody = SKPhysicsBody(rectangleOf:obj.size)
            obj.physicsBody?.isDynamic = true
            obj.physicsBody?.pinned = true
            obj.physicsBody?.allowsRotation = false
            self.addChild(obj)
        }
    }
    
    func addContainers(){
        let left1 = SKSpriteNode()
        let left2 = SKSpriteNode()
        let right1 = SKSpriteNode()
        let right2 = SKSpriteNode()
        
        left1.size = CGSize(width:size.width*0.01,height:size.height*0.1)
        left1.position = CGPoint(x:size.width*0.2, y:size.height*0.05)
        
        left2.size = CGSize(width:size.width*0.01,height:size.height*0.1)
        left2.position = CGPoint(x:size.width*0.4, y:size.height*0.05)
        
        right1.size = CGSize(width:size.width*0.01,height:size.height*0.1)
        right1.position = CGPoint(x:size.width*0.6, y:size.height*0.05)
        
        right2.size = CGSize(width:size.width*0.01,height:size.height*0.1)
        right2.position = CGPoint(x:size.width*0.8, y:size.height*0.05)
        
        for obj in [left1, left2, right1, right2]{
            obj.color = UIColor.yellow
            obj.physicsBody = SKPhysicsBody(rectangleOf:obj.size)
            obj.physicsBody?.isDynamic = true
            obj.physicsBody?.pinned = true
            obj.physicsBody?.allowsRotation = false
            self.addChild(obj)
        }
    }
    
    // MARK: =====Delegate Functions=====
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.addPuck()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node == spinBlock || contact.bodyB.node == spinBlock {
            self.score += 1
        }
    }
    
    // MARK: Utility Functions (thanks ray wenderlich!)
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(Int.max))
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
}
