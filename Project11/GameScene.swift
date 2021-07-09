//
//  GameScene.swift
//  Project11
//
//  Created by Андрей Бородкин on 07.07.2021.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel: SKLabelNode!
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var ballCount = 5 {
        didSet {
            livesLabel.text = "Lives: \(ballCount)"
        }
    }
    
    
    var editLabel: SKLabelNode!
    
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    var livesLabel: SKLabelNode!
    
    var barrierArray: [SKSpriteNode]?
    
   
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        livesLabel = SKLabelNode(fontNamed: "Chalkduster")
        livesLabel.text = "Lives: 5"
        livesLabel.horizontalAlignmentMode = .right
        livesLabel.position = CGPoint(x: 980, y: 650)
        addChild(livesLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        physicsWorld.contactDelegate = self
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        
       
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        let objects = nodes(at: location)
        
        if objects.contains(editLabel) {
            editingMode.toggle()
        } else {
            
            if editingMode {
                // create a box
                let size = CGSize(width: Int.random(in: 16...128), height: 16)
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = location
                
                box.physicsBody = SKPhysicsBody(rectangleOf: size)
                box.physicsBody?.isDynamic = false
                
                box.name = "box"
                addChild(box)
                barrierArray?.append(box)
            } else {
                let ball = ballCreator()
                
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                ball.physicsBody?.restitution = 0.4
                ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                ball.position = CGPoint(x: location.x, y: 700)
                ball.name = "ball"
                
                addChild(ball)

            }
        }
    }
    
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = CGPoint(x: position.x, y: position.y)
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collision(between ball: SKNode, object: SKNode) {
        guard ballCount > 0 else {
            let ac = UIAlertController(title: "Game Over", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Restart", style: .default) { [weak self] _ in
                self?.score = 0
                self?.ballCount = 0
                if let barrierArray = self?.barrierArray {
                    for barrier in barrierArray {
                        barrier.removeFromParent()
                    }
                }
               
            })
            return
        }
        if object.name == "box" {
            destroy(ball: ball)
            ballCount -= 1
            
            print(ballCount)
        } else if object.name == "good" {
            destroy(ball: ball)
            score += 1
            ballCount += 1
            
            print(ballCount)
        } else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
        }
    }
    
    func destroy(ball: SKNode) {
        
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        
        
        
        ball.removeFromParent()
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else {return}
        guard let nodeB = contact.bodyB.node else {return}
        
        if nodeA.name == "ball" {
            collision(between: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collision(between: nodeB, object: nodeA)
        }
    }
    
    func ballCreator() -> SKSpriteNode{
        
        
        enum Color: Int {
            case blue = 1, cyan, green, grey, purple, red, yellow
            
            var color: String {
                switch self {
                case .blue:
                    return "ballBlue"
                case .cyan:
                    return "ballCyan"
                case .green:
                    return "ballGreen"
                case .grey:
                    return "ballGrey"
                case .purple:
                    return "ballPurple"
                case .red:
                    return "ballRed"
                case .yellow:
                    return "ballYellow"
                }
            }
        }
    
        
        return SKSpriteNode(imageNamed: Color(rawValue: Int.random(in: 1...7))!.color)
        
    }
    
}
