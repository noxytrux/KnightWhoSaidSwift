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

var KWSSharedSmokeEmitter = SKEmitterNode()
var KWSSharedBloodEmitter = SKEmitterNode()
var KWSSharedSparcleEmitter = SKEmitterNode()


protocol KWSPlayerDelegate {
    
    func playerDidDied()
}

class KWSPlayer: SKSpriteNode {
    
    var delegate : KWSPlayerDelegate?
    
    private var animationSpeed: CGFloat = 0.1
    private var animated = true
    private var attacking = false
    private var dying = false
    private var requestedAnimation = KWSActionType.IdleAction
    
    private var mirrorDirection : SKAction = SKAction.scaleXTo(-kKWSPlayerScale, y: kKWSPlayerScale, duration: 0.0)
    private var resetDirection : SKAction = SKAction.scaleXTo(kKWSPlayerScale, y: kKWSPlayerScale, duration: 0.0)
    private var movingSound : Bool = false
    
    internal var touchesGround : Bool = false
    internal var moveButtonActive : Bool = false
    internal var defenseButtonActive : Bool = false
    internal var movingLeft : Bool = false
    internal var externalControl : Bool = false
    internal var healt : Int = 100

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
    
    //MARK: helper method
    
    var playerScene: KWSGameScene {
        
        return self.scene as KWSGameScene
    }
    
    func resetPlayer() {
    
        healt = 100
        dying = false
        animated = true
        requestedAnimation = .IdleAction
    }
    
    //MARK: shader assets loading
    
    class func loadSharedAssets() {
        
        dispatch_once(&kKWSSharedAssetsOnceToken) {
            
            KWSSharedIdleAnimationFrames = loadFramesFromAtlasWithName("walk", baseFileName: "walk", numberOfFrames: 1)
            KWSSharedWalkAnimationFrames = loadFramesFromAtlasWithName("walk", baseFileName: "walk", numberOfFrames: 3)
            KWSSharedAttackAnimationFrames = loadFramesFromAtlasWithName("attack", baseFileName: "attack", numberOfFrames: 4)
            KWSSharedJumpAnimationFrames = loadFramesFromAtlasWithName("jump", baseFileName: "jump", numberOfFrames: 3)
            KWSSharedDeathAnimationFrames = loadFramesFromAtlasWithName("die", baseFileName: "dead", numberOfFrames: 5)
            KWSSharedDefenseAnimationFrames = loadFramesFromAtlasWithName("defense", baseFileName: "defense", numberOfFrames: 1)
            
            KWSSharedSmokeEmitter = .sharedSmokeEmitter()
            KWSSharedBloodEmitter = .sharedBloodEmitter()
            KWSSharedSparcleEmitter = .sharedSparkleEmitter()
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
        if !animated {
            
            return
        }
        
        if damage != 0 {
        
            KWSGameAudioManager.sharedInstance.playSound(soundNumber: KWSActionType.HitAction.toRaw() )
            
            let emitter = KWSSharedBloodEmitter.copy() as SKEmitterNode
            emitter.position = self.position
            
            playerScene.addNode(emitter, atWorldLayer: .foliage)
            runOneShotEmitter(emitter, withDuration: 0.15)
        }
        
        healt -= damage
        
        if healt <= 0 {
        
            healt = 0
            
            KWSGameAudioManager.sharedInstance.playSound(soundNumber: KWSActionType.DieAction.toRaw() )
            dying = true
        }
    }
    
    func collidedWith(enemy: KWSPlayer) {
        
        let ownFrame = CGRectInset(self.frame, -20, 0)
        let enemyFrame = CGRectInset(enemy.frame, -20, 0)
        
        let distance = self.position.x - enemy.position.x
        var canDefense = false
        
        if distance == 0 {
            
            canDefense = true
        }
        else if distance < 0 {
        
            canDefense = !self.movingLeft && enemy.movingLeft
        }
        else if distance > 0 {
        
            canDefense = self.movingLeft && !enemy.movingLeft
        }
        
        if CGRectIntersectsRect(ownFrame, enemyFrame) {
        
            if enemy.defenseButtonActive && canDefense {
                
                let emitter = KWSSharedSparcleEmitter.copy() as SKEmitterNode
                    emitter.position = CGPointMake(enemy.position.x, enemy.position.y - enemy.size.height * 0.3)
                    emitter.xAcceleration = movingLeft ? 1000 : -1000
                
                playerScene.addNode(emitter, atWorldLayer: .foliage)
                runOneShotEmitter(emitter, withDuration: 0.15)
                KWSGameAudioManager.sharedInstance.playSound(soundNumber: KWSActionType.DefenseAction.toRaw() )
                
                return
            }

            if !dying && attacking {
                
                enemy.applyDamage(20.0)
            }
        }
    }
    
    //MARK: Update
    
    func updateWithTimeSinceLastUpdate(interval: NSTimeInterval) {
        
        if !dying && !animated {
        
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
        
        if dying && animated {
            requestedAnimation = .DieAction
            animated = false
        }
        
        animationDidComplete(animationState)
    
        if !animated {
            
            return
        }
        
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
        
            requestedAnimation = .IdleAction
        }
    }

    func animationDidComplete(animation: KWSActionType) {
        
        switch animation {
            
        case .DieAction:
            let action = SKAction.runBlock{
                
                self.dying = false
                self.notifyPlayerDied()
            }
            
            runAction(action)
            
        default:
            ()
        }
    }

    func notifyPlayerDied() {
    
        self.delegate?.playerDidDied()
    }
    
    //MARK: player actions
    
    func lockedWalkSound() {
        
        if externalControl {
        
            return
        }
    
        if movingSound {
        
            return
        }
        
        movingSound = true
        KWSGameAudioManager.sharedInstance.playSound(soundNumber: KWSActionType.WalkAction.toRaw() )
        
        let runAfter : dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
        
        dispatch_after(runAfter, dispatch_get_main_queue()) { () -> Void in
            
            self.movingSound = false
        }

    }
    
    func playerMoveLeft() {
        
        if !animated {
         
            return
        }
        
        lockedWalkSound()
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
    
        if !animated {
            
            return
        }
        
        lockedWalkSound()
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
    
        if !animated {
            
            return
        }
        
        if self.touchesGround {
            
            if !externalControl {
    
                KWSGameAudioManager.sharedInstance.playSound(soundNumber: KWSActionType.JumpAction.toRaw() )
            }
            
            self.touchesGround = false
            
            var impulseY : CGFloat = 15.0
            
            self.physicsBody!.applyImpulse(CGVectorMake(0, impulseY), atPoint: self.position)
            
            requestedAnimation = .JumpAction
        }
    }

    func playerAttack() {
    
        if !animated {
            
            return
        }
        
        if attacking {
        
            return
        }
        
        if !externalControl {

            KWSGameAudioManager.sharedInstance.playSound(soundNumber: KWSActionType.AttackAction.toRaw() )
        }
        
        attacking = true
        requestedAnimation = .AttackAction
    }

    func playerDefense() {
        
        if !animated {
            
            return
        }
        
        requestedAnimation = .DefenseAction
    }

}

