//
//  GameViewController.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 27.08.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import UIKit
import SpriteKit

let kDebugOption : Bool = 1;

extension SKNode {
    
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        
        let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks")
        
        var sceneData = NSData.dataWithContentsOfFile(path, options: .DataReadingMappedIfSafe, error: nil)
        var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
        
        archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
        let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as MainMenuScene
        archiver.finishDecoding()
        return scene
    }
}

class MainMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = MainMenuScene.unarchiveFromFile("MainMenuScene") as? MainMenuScene {
          
            let skView = self.view as SKView
            
            if kDebugOption {
        
                skView.showsFPS = true
                skView.showsNodeCount = true
            }
        
            skView.ignoresSiblingOrder = true
            skView.shouldCullNonVisibleNodes = true
            
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        }
    }

    override func shouldAutorotate() -> Bool {
        
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        
       return Int(UIInterfaceOrientationMask.Landscape.toRaw())
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }

    override func prefersStatusBarHidden() -> Bool {
        
        return true
    }
}
