//
//  KWSGameViewController.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 17.09.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import UIKit
import SpriteKit

class KWSGameViewController: UIViewController, KWSBlueToothLEDelegate,KWSPlayerDelegate {
    
    private var communicationInterface : KWSBluetoothLEInterface?
    private var gameButtons = [UIButton]()
    
    private var gameScene : KWSGameScene!
    private var isSerwer : Bool = false
    private var interfaceConnected : Bool = false
    private var continueLoop : Bool = false
    
    @IBOutlet weak var becomeServerButton: UIButton!
    @IBOutlet weak var becomeClientButton: UIButton!
    
    @IBOutlet weak var moveLeftButton: UIButton!
    @IBOutlet weak var moveRightButton: UIButton!
    @IBOutlet weak var jumpButton: UIButton!
    @IBOutlet weak var guardButton: UIButton!
    @IBOutlet weak var attackButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!

    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
    
        for button in self.gameButtons {
        
            button.alpha = 0.0
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.sharedApplication().idleTimerDisabled = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        UIApplication.sharedApplication().idleTimerDisabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.moveLeftButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        
        let classString = NSStringFromClass(KWSGameScene)
        let realClassName = classString.componentsSeparatedByString(".")[1]
        
        if let scene = KWSGameScene.unarchiveFromFile(realClassName) as? KWSGameScene {
            
            let skView = self.view as SKView
        
            skView.ignoresSiblingOrder = true
            skView.shouldCullNonVisibleNodes = true
            
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
            
            self.gameScene = scene
        }
        
        self.gameButtons.append(self.moveLeftButton)
        self.gameButtons.append(self.moveRightButton)
        self.gameButtons.append(self.jumpButton)
        self.gameButtons.append(self.guardButton)
        self.gameButtons.append(self.attackButton)
    }
    
    func closeAndChangeMusic() {
    
        self.navigationController?.popViewControllerAnimated(true)
        
        let gameAudio = KWSGameAudioManager.sharedInstance
            gameAudio.playMusic(musicName: "Menu")
            gameAudio.setMusicVolume(volume: 0.3)
    
    }
    
    @IBAction func popGameController(sender: UIButton) {
        
        closeAndChangeMusic()
        
        if interfaceConnected {
        
            self.communicationInterface!.sendCommand(command: .Disconnect, data: nil)
        }
    }
    
    @IBAction func becomeServerPress(sender: UIButton) {
        
        self.isSerwer = true
        self.communicationInterface = KWSBluetoothLEServer(ownerController: self, delegate: self)
        self.showGameButtons()
        
        self.gameScene.selectedPlayer = self.gameScene.players[1]
        self.gameScene.otherPlayer = self.gameScene.players[0]
        self.gameScene.otherPlayer!.externalControl = true;
        
        self.gameScene.selectedPlayer!.delegate = self
        self.gameScene.otherPlayer!.delegate = self
    }
    
    @IBAction func becomeClientPress(sender: UIButton) {
        
        self.isSerwer = false
        self.communicationInterface = KWSBluetoothLEClient(ownerController: self, delegate: self)
        self.showGameButtons()
        
        self.gameScene.selectedPlayer = self.gameScene.players[0]
        self.gameScene.otherPlayer = self.gameScene.players[1]
        self.gameScene.otherPlayer!.externalControl = true;
        
        self.gameScene.selectedPlayer!.delegate = self
        self.gameScene.otherPlayer!.delegate = self
    }
    
    func showGameButtons() {
    
        UIView.animateWithDuration(kKWSAnimationDuration, animations: { () -> Void in
        
            self.becomeClientButton.alpha = 0.0
            self.becomeServerButton.alpha = 0.0
            
            for button in self.gameButtons {
                
                button.alpha = 1.0
                button.userInteractionEnabled = false
            }
        })
    }
    
    deinit {
    
        continueLoop = false
    }
    

    //MARK: LE interface delegate
    
    func interfaceDidUpdate(#interface: BTLEInterface, command: KWSPacketType, data: NSData?)
    {
        if !interfaceConnected && (command == KWSPacketType.Connect) {
            
            for button in self.gameButtons {
                
                button.userInteractionEnabled = true
            }
            
            interfaceConnected = true
            
            //run hearBeat loop
            continueLoop = true
            heartBeat()
            
            return;
        }
        
        if !interfaceConnected {
        
            return
        }
        
        switch( command ) {
            
        case .HearBeat:
            
            if let data = data {
                
                let subData : NSData = data.subdataWithRange(NSMakeRange(0, sizeof(syncPacket)))
                let packetMemory = UnsafePointer<syncPacket>(subData.bytes)
                let packet = packetMemory.memory
                
                self.gameScene.otherPlayer!.healt = packet.healt
                self.gameScene.otherPlayer!.applyDamage(0)
                
                let position = CGPointMake(CGFloat(packet.posx), CGFloat(packet.posy))
                var realPos = self.gameScene.otherPlayer!.position
                
                self.gameScene.otherPlayer!.position = position
            }
            
        case .Attack:
            self.gameScene.otherPlayer!.playerAttack()
            self.gameScene.otherPlayer!.collidedWith(self.gameScene.selectedPlayer!)
        
        case .DefenseDown:
            self.gameScene.otherPlayer!.defenseButtonActive = true
            self.gameScene.otherPlayer!.playerDefense()
        
        case .DefenseUp:
            self.gameScene.otherPlayer!.defenseButtonActive = false
        
        case .Jump:
            self.gameScene.otherPlayer!.playerJump()

        case .MoveDown:
            
            if let data = data {
            
                self.gameScene.otherPlayer!.moveButtonActive = true
                
                let body : NSData = data.subdataWithRange(NSMakeRange(0, sizeof(Bool)))
                let value : UnsafePointer<Bool> = UnsafePointer<Bool>(body.bytes)
                let direction : Bool = value.memory
                
                if direction {
                
                    self.gameScene.otherPlayer!.playerMoveLeft()
                
                } else {
                
                    self.gameScene.otherPlayer!.playerMoveRight()
                }
            }
            
        case .MoveUp:
            self.gameScene.otherPlayer!.moveButtonActive = false
            
        case .Disconnect:
            
            continueLoop = false
            
            interfaceConnected = false
            
            for button in self.gameButtons {
                
                button.userInteractionEnabled = false
            }
            
            let KWSAlertController = UIAlertController( title: NSLocalizedString("Error", comment: ""),
                                                      message: NSLocalizedString("Other player has been disconnect", comment: ""),
                                               preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                         style: .Cancel,
                                       handler: { (action: UIAlertAction!) -> Void in
                    
                                            self.closeAndChangeMusic()
                                        })
            
            KWSAlertController.addAction(okAction)
            
            self.presentViewController(KWSAlertController, animated: true, completion: nil)
            
        case .Restart:
            
            self.unlockControls()
            
        case .GameEnd:
            
            self.lockControls()
            
        default:
            ()
        }
    }
    
    func lockControls() {
    
        UIView.animateWithDuration(kKWSAnimationDuration, animations: { () -> Void in
            
            self.restartButton.alpha = 1.0
            
            for button in self.gameButtons {
                
                button.alpha = 0.0
            }
        })
    }
    
    func unlockControls() {
    
        self.gameScene.selectedPlayer!.resetPlayer()
        self.gameScene.otherPlayer!.resetPlayer()
        
        UIView.animateWithDuration(kKWSAnimationDuration, animations: { () -> Void in
            
            self.restartButton.alpha = 0.0
            
            for button in self.gameButtons {
                
                button.alpha = 1.0
            }
        })
    }
    
    //MARK: player delegate

    func playerDidDied() {
    
        if interfaceConnected {
            
            self.communicationInterface!.sendCommand(command: .GameEnd, data: nil)
        }

        //reset menu etc.
        self.lockControls()
    }
    
    func heartBeat() {

        var currentPlayer = self.gameScene.selectedPlayer
        
        var packet = syncPacket()
            packet.healt = currentPlayer!.healt
            packet.posx = Float32(currentPlayer!.position.x)
            packet.posy = Float32(currentPlayer!.position.y)
        
        var packetData = NSData(bytes: &packet, length: sizeof(syncPacket))
        
        self.communicationInterface!.sendCommand(command: .HearBeat, data: packetData)
        
        if continueLoop {
        
            let runAfter : dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
            
            dispatch_after(runAfter, dispatch_get_main_queue()) { () -> Void in
                
                self.heartBeat()
            }
        }
    }
    
    @IBAction func restartButtonPress(sender: UIButton) {
        
        if interfaceConnected {
            
            self.communicationInterface!.sendCommand(command: .Restart, data: nil)
        }
        
        self.unlockControls()
    }
    
    //MARK: player sterring
    
    @IBAction func pressLeftButton(sender: UIButton) {
        
        var currentPlayer = self.gameScene.selectedPlayer

        currentPlayer!.moveButtonActive = true
        currentPlayer!.playerMoveLeft()

        if interfaceConnected {
        
            var directionData = NSData(bytes: &currentPlayer!.movingLeft, length: sizeof(Bool))
            self.communicationInterface!.sendCommand(command: .MoveDown, data: directionData)
        }
    }
    
    @IBAction func pressRightButton(sender: UIButton) {

        var currentPlayer = self.gameScene.selectedPlayer
        
        currentPlayer!.moveButtonActive = true
        currentPlayer!.playerMoveRight()
        
        if interfaceConnected {
        
            var directionData = NSData(bytes: &currentPlayer!.movingLeft, length: sizeof(Bool))
            self.communicationInterface!.sendCommand(command: .MoveDown, data: directionData)
        }
    }
    
    @IBAction func unpressLeftButton(sender: UIButton) {
        
        var currentPlayer = self.gameScene.selectedPlayer
        
        currentPlayer!.moveButtonActive = false

        if interfaceConnected {
        
            self.communicationInterface!.sendCommand(command: .MoveUp, data: nil)
        }
    }
    
    @IBAction func unpressRightButton(sender: UIButton) {
        
        var currentPlayer = self.gameScene.selectedPlayer
        
        currentPlayer!.moveButtonActive = false
        
        if interfaceConnected {
            
            self.communicationInterface!.sendCommand(command: .MoveUp, data: nil)
        }
    }
    
    @IBAction func pressAttackButton(sender: UIButton) {
        
        var currentPlayer = self.gameScene.selectedPlayer
        
        currentPlayer!.playerAttack()
        currentPlayer!.collidedWith(self.gameScene.otherPlayer!)
        
        if interfaceConnected {
        
            self.communicationInterface!.sendCommand(command: .Attack, data: nil)
        }
    }
    
    @IBAction func pressDefenseButton(sender: UIButton) {

        var currentPlayer = self.gameScene.selectedPlayer
        
        currentPlayer!.defenseButtonActive = true
        currentPlayer!.playerDefense()

        if interfaceConnected {
            
            self.communicationInterface!.sendCommand(command: .DefenseDown, data: nil)
        }
    }
    
    @IBAction func unpressDefenseButton(sender: UIButton){
    
        var currentPlayer = self.gameScene.selectedPlayer
        
        currentPlayer!.defenseButtonActive = false

        if interfaceConnected {
            
            self.communicationInterface!.sendCommand(command: .DefenseUp, data: nil)
        }
    }
    
    @IBAction func pressJumpButton(sender: UIButton) {

        var currentPlayer = self.gameScene.selectedPlayer
        
        currentPlayer!.playerJump()

        if interfaceConnected {
            
            self.communicationInterface!.sendCommand(command: .Jump, data: nil)
        }
    }
    
}
