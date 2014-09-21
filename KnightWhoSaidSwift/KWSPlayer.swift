//
//  KWSPlayer.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 20.09.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import SpriteKit

var kKWSSharedAssetsOnceToken: dispatch_once_t = 0

var KWSSharedIdleAnimationFrames = [SKTexture]()
var KWSSharedWalkAnimationFrames = [SKTexture]()
var KWSSharedAttackAnimationFrames = [SKTexture]()
var KWSSharedJumpAnimationFrames = [SKTexture]()
var KWSSharedDeathAnimationFrames = [SKTexture]()
var KWSSharedDefenseAnimationFrames = [SKTexture]()

let kKWSPlayerScale : CGFloat! = 4
let kKWSMaxPlayerMovement : CGFloat = 32

//MARK: player animation keys 

let kKWSMoveActionKey : String! = "moving_key"
let kKWSJumpActionKey : String! = "jump_key"

let kKWSWalkKey : String! = "anim_walk"
let kKWSAttackKey : String! = "anim_attack"
let kKWSDeadKey : String! = "anim_death"
let kKWSIdleKey : String! = "anim_idle"
let kKWSJumpKey : String! = "anim_jump"
let kKWSDefenseKey : String! = "anim_defense"

class KWSPlayer: SKSpriteNode {
    
    private var animationSpeed: CGFloat = 0.1
    private var healt = 100
    private var animated = true
    private var attacking = false
    private var dying = false
    private var requestedAnimation = KWSActionType.IdleAction
    
    private var mirrorDirection : SKAction = SKAction.scaleXTo(-kKWSPlayerScale, y: kKWSPlayerScale, duration: 0.0)
    private var resetDirection : SKAction = SKAction.scaleXTo(kKWSPlayerScale, y: kKWSPlayerScale, duration: 0.0)

    internal var touchesGround : Bool = false
    internal var moveButtonActive : Bool = false
    internal var defenseButtonActive : Bool = false
    internal var movingLeft : Bool = false
    
    //MARK: init

    init(atPosition position: CGPoint, redPlayer: Bool) {
    
        let atlas = SKTextureAtlas(named: "walk")
        let texture = atlas.textureNamed("walk_prefix_1.png")
        let size = CGSize(width: 32, height: 32)
        
        super.init(texture: texture, color: SKColor.whiteColor(), size: size)
        
        self.position = position
        
        configurePhysicsBody()
        
        xScale = kKWSPlayerScale
        yScale = kKWSPlayerScale
        
        zRotation = CGFloat(0)
        zPosition = -0.25
        name = "Player"
        
        //if it is red player add Shader that will color it
        
        if redPlayer {
        
            applyRedShader()
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }

    class func loadSharedAssets() {
        
        dispatch_once(&kKWSSharedAssetsOnceToken) {
            
            KWSSharedIdleAnimationFrames = loadFramesFromAtlasWithName("walk", baseFileName: "walk", numberOfFrames: 1)
            KWSSharedWalkAnimationFrames = loadFramesFromAtlasWithName("walk", baseFileName: "walk", numberOfFrames: 3)
            KWSSharedAttackAnimationFrames = loadFramesFromAtlasWithName("attack", baseFileName: "attack", numberOfFrames: 4)
            KWSSharedJumpAnimationFrames = loadFramesFromAtlasWithName("jump", baseFileName: "jump", numberOfFrames: 3)
            KWSSharedDeathAnimationFrames = loadFramesFromAtlasWithName("die", baseFileName: "dead", numberOfFrames: 5)
            KWSSharedDefenseAnimationFrames = loadFramesFromAtlasWithName("defense", baseFileName: "defense", numberOfFrames: 1)
        }
    }

    func applyRedShader() {
    
        let playerShader = SKShader(fileNamed: "Shader.fsh")
        
        self.shader = playerShader
    }
    
    //MARK: game logic
    
    func configurePhysicsBody() {
        
        physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(20, 20), center: CGPointMake(0, -6))
        
        if let physicsBody = physicsBody {
        
            physicsBody.categoryBitMask = ColliderType.Player.toRaw()
            physicsBody.collisionBitMask = ColliderType.Wall.toRaw() | ColliderType.Ground.toRaw()
            physicsBody.contactTestBitMask = ColliderType.Wall.toRaw() | ColliderType.Ground.toRaw() | ColliderType.Player.toRaw()
            physicsBody.allowsRotation = false
            physicsBody.dynamic = true
        }
    }
    
    func applyDamage(damage: Int)
    {
        healt -= damage
        
        if healt == 0 {
        
            dying = true
        }
    }
    
    func collidedWith(other: SKPhysicsBody) {
        
        if let enemy = other.node as? KWSPlayer {
            
            //TODO: add guarding
            if !enemy.dying && enemy.attacking {
                
                applyDamage(5.0)
            }
        }
    }
    
    //MARK: Update
    
    func updateWithTimeSinceLastUpdate(interval: NSTimeInterval) {
        
        if !animated {
            return
        }
       
        resolveRequestedAnimation()
    }
    
    //MARK: Animations
    
    func resolveRequestedAnimation() {
        
        var (frames, key) = animationFramesAndKeyForState(requestedAnimation)
        
        fireAnimationForState(requestedAnimation, usingTextures: frames, withKey: key)
    }
    
    func animationFramesAndKeyForState(state: KWSActionType) -> ([SKTexture], String) {
        
        switch state {
        case .WalkAction:
            return (KWSSharedWalkAnimationFrames, kKWSWalkKey)
            
        case .AttackAction:
            return (KWSSharedAttackAnimationFrames, kKWSAttackKey)
            
        case .DieAction:
            return (KWSSharedDeathAnimationFrames, kKWSDeadKey)
            
        case .IdleAction:
            return (KWSSharedIdleAnimationFrames, kKWSIdleKey)
       
        case .JumpAction:
            return (KWSSharedJumpAnimationFrames, kKWSJumpKey)
            
        case .DefenseAction:
            return (KWSSharedDefenseAnimationFrames, kKWSDefenseKey)
            
        default:
            return ([SKTexture](),"unknown")
        }
    }
    
    func fireAnimationForState(animationState: KWSActionType, usingTextures frames: [SKTexture], withKey key: String) {
    
        var animAction = actionForKey(key)
        
        if animAction != nil || frames.count < 1 {
            return
        }
    
        let animationAction = SKAction.animateWithTextures(frames, timePerFrame: NSTimeInterval(animationSpeed), resize: true, restore: false)
        
        let blockAction = SKAction.runBlock {
            self.animationHasCompleted(animationState)
        }
        
        var animateWithDirection : SKAction = movingLeft ? SKAction.group([mirrorDirection, animationAction]) : SKAction.group([resetDirection, animationAction])
        
        runAction(SKAction.sequence([animateWithDirection, blockAction]), withKey: key)
    }
    
    func animationHasCompleted(animationState: KWSActionType) {
        
        if dying {
            animated = false
        }
        
        animationDidComplete(animationState)
    
        if attacking && (animationState == KWSActionType.AttackAction) {
            
            attacking = false
        }
        
        if self.defenseButtonActive {
        
            requestedAnimation = .DefenseAction
            return
        }
        
        var actionMove   = actionForKey(kKWSMoveActionKey)
        var endJumping = self.touchesGround
        
        if self.touchesGround == false && (animationState == KWSActionType.JumpAction) {
        
            endJumping = true
        }
        
        if !attacking && actionMove == nil && endJumping {
        
            requestedAnimation = dying ? .DieAction : .IdleAction
        }
    }

    
    func animationDidComplete(animation: KWSActionType) {
        
        switch animation {
            
        case .DieAction:
            let actions = [SKAction.waitForDuration(1.0),
                
                SKAction.runBlock {

                    //delegate call to main controller
                },
                SKAction.removeFromParent()]
            
            runAction(SKAction.sequence(actions))
            
        default:
            ()
        }
    }

    //MARK: player actions
    
    func playerMoveLeft() {
        
        movingLeft = true
        
        var action: SKAction = SKAction.moveByX(-kKWSMaxPlayerMovement, y: 0, duration: 0.1)
        requestedAnimation = .WalkAction
        
        let moveFinishAction = SKAction.runBlock {
            
            if self.moveButtonActive {
                
                self.playerMoveLeft()
            }
        }
        
        runAction(SKAction.sequence([action, moveFinishAction]), withKey: kKWSMoveActionKey)
    }
    
    func playerMoveRight() {
    
        movingLeft = false
        
        var action: SKAction = SKAction.moveByX(kKWSMaxPlayerMovement, y: 0, duration: 0.1)
        requestedAnimation = .WalkAction
        
        let moveFinishAction = SKAction.runBlock {
           
            if self.moveButtonActive {
            
                self.playerMoveRight()
            }
        }
        
        runAction(SKAction.sequence([action, moveFinishAction]), withKey: kKWSMoveActionKey)
    }
    
    func playerJump() {
    
        if self.touchesGround {
    
            self.touchesGround = false
            
            var impulseY : CGFloat = 15.0
            
            self.physicsBody!.applyImpulse(CGVectorMake(0, impulseY), atPoint: self.position)
            
            requestedAnimation = .JumpAction
        }
    }

    func playerAttack() {
    
        attacking = true
        requestedAnimation = .AttackAction
    }

    func playerDefense() {
        
        requestedAnimation = .DefenseAction
    }

}

