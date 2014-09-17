//
//  GameViewController.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 27.08.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import UIKit
import SpriteKit

let kDebugOption : Bool = 1

class KWSMainMenuViewController: UIViewController, UIPopoverPresentationControllerDelegate{

    let kKWSSettingsSegueIdentifier : String! = "kKWSSettingsSegueIdentifier"
    let kKWSPlayGameSegueIdentifier : String! = "kKWSPlayGameSegueIdentifier"
    
    var gameAudio : KWSGameAudioManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = KWSMainMenuScene.unarchiveFromFile("KWSMainMenuScene") as? KWSMainMenuScene {
          
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
        
        self.gameAudio = KWSGameAudioManager.sharedInstance
        self.gameAudio!.playMusic(musicName: "Menu")
        self.gameAudio!.setMusicVolume(volume: 0.3)
    }

    @IBAction func didPressMenuButton(sender: AnyObject) {
        
        let gameAudio = KWSGameAudioManager.sharedInstance
            gameAudio.playClickButtonSound()
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if kKWSPlayGameSegueIdentifier == segue.identifier {
        
            let runAfter : dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
            
            dispatch_after(runAfter, dispatch_get_main_queue()) { () -> Void in
                
                
                if let gameAudio = self.gameAudio {
                
                    gameAudio.playMusic(musicName: "Level")
                    gameAudio.setMusicVolume(volume: 0.3)
                }
            }
        }
    }

}
