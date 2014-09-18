//
//  KWSGameViewController.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 17.09.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import UIKit
import SpriteKit

class KWSGameViewController: UIViewController, KWSBlueToothLEDelegate {
    
    private var communicationInterface : KWSBluetoothLEInterface?
    private var gameButtons = [UIButton]()
    
    @IBOutlet weak var becomeServerButton: UIButton!
    @IBOutlet weak var becomeClientButton: UIButton!
    
    @IBOutlet weak var moveLeftButton: UIButton!
    @IBOutlet weak var moveRightButton: UIButton!
    @IBOutlet weak var jumpButton: UIButton!
    @IBOutlet weak var guardButton: UIButton!
    @IBOutlet weak var attackButton: UIButton!

    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
    
        for button in self.gameButtons {
        
            button.alpha = 0.0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.moveLeftButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        
        if let scene = KWSGameScene.unarchiveFromFile("KWSGameScene") as? KWSGameScene {
            
            let skView = self.view as SKView
        
            skView.ignoresSiblingOrder = true
            skView.shouldCullNonVisibleNodes = true
            
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        }
        
        self.gameButtons.append(self.moveLeftButton)
        self.gameButtons.append(self.moveRightButton)
        self.gameButtons.append(self.jumpButton)
        self.gameButtons.append(self.guardButton)
        self.gameButtons.append(self.attackButton)
    }
    
    @IBAction func popGameController(sender: UIButton) {
        
        self.navigationController?.popViewControllerAnimated(true)
        
        let gameAudio = KWSGameAudioManager.sharedInstance
            gameAudio.playMusic(musicName: "Menu")
            gameAudio.setMusicVolume(volume: 0.3)
    }
    
    @IBAction func becomeServerPress(sender: UIButton) {
        
        self.communicationInterface = KWSBluetoothLEServer(ownerController: self, delegate: self)
        self.showGameButtons()
    }
    
    @IBAction func becomeClientPress(sender: UIButton) {
        
        self.communicationInterface = KWSBluetoothLEClient(ownerController: self, delegate: self)
        self.showGameButtons()
    }
    
    func showGameButtons() {
    
        UIView.animateWithDuration(kKWSAnimationDuration, animations: { () -> Void in
        
            self.becomeClientButton.alpha = 0.0
            self.becomeServerButton.alpha = 0.0
            
            for button in self.gameButtons {
                
                button.alpha = 1.0
            }
        })
    }
    
    //MARK: LE interface delegate 
    
    func interfaceDidUpdate(#interface: BTLEInterface, command: KWSPacketType, data: NSData!)
    {
    
    }
}
