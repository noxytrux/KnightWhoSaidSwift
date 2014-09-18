//
//  KWSGameScene.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 17.09.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import UIKit
import SpriteKit

let kKWSMaxLayerCount : Int! = 2
let kKWSAcceptValue : UInt8! = 200

enum WorldLayer: Int {
    
    case ground = 0, foliage
}

enum ColliderType: UInt32 {
    
    case Player = 1
    case Wall = 2
    case Ground = 4
}

class KWSGameScene: SKBaseScene, SKPhysicsContactDelegate {
    
    private var gameWorld = SKNode()
    private var gameLayers = [SKNode]()
    
    internal var sceneLoaded:Bool = false
   
    internal var mapSizeX : Int = 0
    internal var mapSizeY : Int = 0
    internal var mapBinaryData : UnsafePointer<mapDataStruct> = UnsafePointer<mapDataStruct>()
    
    internal var enviroAtlas : SKTextureAtlas!
    internal var playerSpawnPosition : CGPoint!
    
    override func didMoveToView(view: SKView) {

        physicsWorld.gravity = CGVector(0, -9.8)
        physicsWorld.contactDelegate = self

        gameWorld.name = "mainNode"
        
        for i in 0..<kKWSMaxLayerCount {
            
            let layer = SKNode()
            layer.zPosition = CGFloat(i - kKWSMaxLayerCount)
            gameWorld.addChild(layer)
            gameLayers.append(layer)
        }
        
        self.addChild(gameWorld)
        
        self.loadScene()
    }
    
    func loadScene() {
        
        self.insertBackgroundNode()
        
        let queue = dispatch_get_main_queue()
        let backgroundQueue = dispatch_get_global_queue(CLong(DISPATCH_QUEUE_PRIORITY_HIGH), 0)
        
        dispatch_async(backgroundQueue) {
        
            self.enviroAtlas = SKTextureAtlas(named:"Enviro.atlas")
            
            dispatch_async(queue, { () -> Void in
                
                self.loadClouds()
                self.loadMap()
                
                self.centerWorldOnPosition(self.playerSpawnPosition)
        
                self.sceneLoaded = true
            })
        }
    
    }
    
    func loadMap() {
        
        var levelMap = loadMapData("mapimage.png")
        self.mapSizeX = Int(levelMap.width)
        self.mapSizeY = Int(levelMap.height)
        self.mapBinaryData = UnsafePointer<mapDataStruct>(levelMap.data)
        
        let blockOffset : CGFloat = kKWSBlockSize / 2.0
        
        for y in 0..<self.mapSizeY {
            
            for x in 0..<self.mapSizeX {
                
                let location = CGPoint(x: x, y: y)
                let tileData = queryData(location)
                
                let mapPosition = CGPoint(x: location.x, y: CGFloat(self.mapSizeY - y))
                let worldPoint = (mapPosition * kKWSBlockSize) + blockOffset
                
                if tileData.playerSpawn <= kKWSAcceptValue {
                    
                    self.playerSpawnPosition = worldPoint
                    
                } else if tileData.wall >= kKWSAcceptValue {
                    
                    let sprite = SKSpriteNode(texture:self.enviroAtlas.textureNamed("Enviro_prefix_4"))
                    
                    sprite.size = CGSizeMake(32, 32)
                    sprite.xScale = 2.0
                    sprite.yScale = 2.0
                    sprite.zPosition = 0
                    sprite.position = worldPoint
                
                    sprite.physicsBody = SKPhysicsBody(rectangleOfSize: size)
                    sprite.physicsBody!.dynamic = false
                    sprite.physicsBody!.categoryBitMask = ColliderType.Wall.toRaw()
                    sprite.physicsBody!.collisionBitMask = 0
                    
                    self.addNode(sprite, atWorldLayer: .ground)
                    
                } else if tileData.grass >= kKWSAcceptValue {
                   
                    
                    let sprite = SKSpriteNode(texture:self.enviroAtlas.textureNamed("Enviro_prefix_6"))
                    
                    sprite.size = CGSizeMake(32, 32)
                    sprite.xScale = 2.0
                    sprite.yScale = 2.0
                    sprite.zPosition = 0
                    sprite.position = worldPoint
                    
                    self.addNode(sprite, atWorldLayer: .foliage)
                    
                } else if tileData.ground >= kKWSAcceptValue {
                
                    let sprite = SKSpriteNode(texture:self.enviroAtlas.textureNamed("Enviro_prefix_3"))

                    sprite.size = CGSizeMake(32, 32)
                    sprite.xScale = 2.0
                    sprite.yScale = 2.0
                    sprite.zPosition = 0
                    sprite.position = worldPoint

                    sprite.physicsBody = SKPhysicsBody(rectangleOfSize: size)
                    sprite.physicsBody!.dynamic = false
                    sprite.physicsBody!.categoryBitMask = ColliderType.Ground.toRaw()
                    sprite.physicsBody!.collisionBitMask = 0
                    
                    self.addNode(sprite, atWorldLayer: .ground)
                }
            }
        }
        
    }
    
    func queryData(point: CGPoint) -> mapDataStruct {
        
        let index = (Int(point.y) * Int(self.mapSizeX)) + Int(point.x)
        return mapBinaryData[index]
    }
    
    override func update(currentTime: CFTimeInterval) {
        
        if !self.sceneLoaded {
        
            return
        }
        
        self.animateClouds(currentTime)
    }
    
    func insertBackgroundNode() {
    
        let sprite = SKSpriteNode(imageNamed: "bg")

        sprite.size = CGSizeMake(CGRectGetMaxX(self.frame), CGRectGetMaxY(self.frame))
        sprite.xScale = 1.0
        sprite.yScale = 1.0
        sprite.zPosition = -5
        sprite.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
        self.addChild(sprite)
    }
    
    func addNode(node: SKNode, atWorldLayer layer: WorldLayer) {
        
        let layerNode = gameLayers[layer.toRaw()]
        layerNode.addChild(node)
    }
    
    func centerWorldOnPosition(position: CGPoint) {
        
        gameWorld.position = CGPoint(x: -position.x + CGRectGetMidX(frame),
                                     y: -position.y + CGRectGetMidY(frame))

    }

    //MARK: SKPhysicsContactDelegate methods
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        
    }
    
    func didEndContact(contact: SKPhysicsContact) {
    
        
    }
}
