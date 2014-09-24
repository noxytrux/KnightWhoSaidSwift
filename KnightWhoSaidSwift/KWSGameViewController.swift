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
        
        self.communicationInterface!.sendCommand(command: .Disconnect, data: nil)
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
        
        switch( command ) {
        
        case .Connect:
            
            for button in self.gameButtons {
                
                button.userInteractionEnabled = true
            }
            
            continueLoop = true
            heartBeat()
            
        case .HearBeat:
            
            if let data = data {
                
                let subData : NSData = data.subdataWithRange(NSMakeRange(0, sizeof(syncPacket)))
                let packetMemory = UnsafePointer<syncPacket>(subData.bytes)
                let packet = packetMemory.memory
                
                self.gameScene.otherPlayer!.healt = packet.healt
                self.gameScene.otherPlayer!.applyDamage(0)
                
//                var normalizedPosition : CGFloat = CGFloat(packet.posx) / 255.0
//                var decodedPos = normalizedPosition * self.gameScene.mapScreenSize
                
                var realPos = self.gameScene.otherPlayer!.position
                let position = CGPointMake(CGFloat(packet.posx), CGFloat(realPos.y)) //CGFloat(decodedPos)
                
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
        
        println("player died.")
    
        self.communicationInterface!.sendCommand(command: .GameEnd, data: nil)
     
        //reset menu etc.
        self.lockControls()
    }
    
    func heartBeat() {

        var currentPlayer = self.gameScene.selectedPlayer
        
        //normalize position to 0-1 and pack it to 255 Int8
//        var normalizedPosition = CGFloat(currentPlayer!.position.x) / self.gameScene.mapScreenSize
//        var packetPosition : Int8 = Int8(normalizedPosition * 255.0)
        
        var packet = syncPacket()
            packet.healt = currentPlayer!.healt
            packet.posx = Float32(currentPlayer!.position.x)//packetPosition
        
        var packetData = NSData(bytes: &packet, length: sizeof(syncPacket))
        
        self.communicationInterface!.sendCommand(command: .HearBeat, data: packetData)
        
        if continueLoop {
        
            let runAfter : dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(kKWSPacketRoonLoopTime * Double(NSEC_PER_SEC)))
            
            dispatch_after(runAfter, dispatch_get_main_queue()) { () -> Void in
                
                self.heartBeat()
            }
        }
    }
    
    @IBAction func restartButtonPress(sender: UIButton) {
        
        let runAfter : dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
        
        dispatch_after(runAfter, dispatch_get_main_queue()) { () -> Void in
            
            self.communicationInterface!.sendCommand(command: .Restart, data: nil)
        }
        
        self.unlockControls()
    }
    
    //MARK: player sterring
    
    @IBAction func pressLeftButton(sender: UIButton) {
        
        var currentPlayer = self.gameScene.selectedPlayer

        currentPlayer!.moveButtonActive = true
        currentPlayer!.playerMoveLeft()

        var directionData = NSData(bytes: &currentPlayer!.movingLeft, length: sizeof(Bool))
        self.communicationInterface!.sendCommand(command: .MoveDown, data: directionData)
    }
    
    @IBAction func pressRightButton(sender: UIButton) {

        var currentPlayer = self.gameScene.selectedPlayer
        
        currentPlayer!.moveButtonActive = true
        currentPlayer!.playerMoveRight()
        
        var directionData = NSData(bytes: &currentPlayer!.movingLeft, length: sizeof(Bool))
        self.communicationInterface!.sendCommand(command: .MoveDown, data: directionData)
    }
    
    @IBAction func unpressLeftButton(sender: UIButton) {
        
        var currentPlayer = self.gameScene.selectedPlayer
        
        currentPlayer!.moveButtonActive = false

        self.communicationInterface!.sendCommand(command: .MoveUp, data: nil)
    }
    
    @IBAction func unpressRightButton(sender: UIButton) {
        
        var currentPlayer = self.gameScene.selectedPlayer
        
        currentPlayer!.moveButtonActive = false
        
        self.communicationInterface!.sendCommand(command: .MoveUp, data: nil)
    }
    
    @IBAction func pressAttackButton(sender: UIButton) {
        
        var currentPlayer = self.gameScene.selectedPlayer
        
        currentPlayer!.playerAttack()
        currentPlayer!.collidedWith(self.gameScene.otherPlayer!)
        
        self.communicationInterface!.sendCommand(command: .Attack, data: nil)
    }
    
    @IBAction func pressDefenseButton(sender: UIButton) {

        var currentPlayer = self.gameScene.selectedPlayer
        
        currentPlayer!.defenseButtonActive = true
        currentPlayer!.playerDefense()

        self.communicationInterface!.sendCommand(command: .DefenseDown, data: nil)
    }
    
    @IBAction func unpressDefenseButton(sender: UIButton){
    
        var currentPlayer = self.gameScene.selectedPlayer
        
        currentPlayer!.defenseButtonActive = false

        self.communicationInterface!.sendCommand(command: .DefenseUp, data: nil)
    }
    
    @IBAction func pressJumpButton(sender: UIButton) {

        var currentPlayer = self.gameScene.selectedPlayer
        
        currentPlayer!.playerJump()

        self.communicationInterface!.sendCommand(command: .Jump, data: nil)
    }
    
}
