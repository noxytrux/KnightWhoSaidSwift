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
    
    private weak var audioManager = KWSGameAudioManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let audioManager = self.audioManager {
            
            soundSwitch.on = !audioManager.deviceMuted
        }
     }
   
    @IBAction func soundSwitchPress(sender: AnyObject) {
    
        if let audioManager = self.audioManager {
            
            audioManager.deviceMuted = !soundSwitch.on
        }
    }

    @IBAction func dismissViewController(sender: UIButton) {
        
        if let audioManager = self.audioManager {
            
            audioManager.playClickButtonSound()
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
