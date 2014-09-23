//
//  KWSSettingsViewController.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 01.09.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import UIKit

class KWSSettingsViewController: UIViewController {

    @IBOutlet weak var soundSwitch: UISwitch!
    
    private var audioManager = KWSGameAudioManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        soundSwitch.on = !audioManager.deviceMuted
    }
   
    @IBAction func soundSwitchPress(sender: AnyObject) {
    
        audioManager.deviceMuted = !soundSwitch.on
    }

    @IBAction func dismissViewController(sender: UIButton) {
        
        let gameAudio = KWSGameAudioManager.sharedInstance
            gameAudio.playClickButtonSound()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
