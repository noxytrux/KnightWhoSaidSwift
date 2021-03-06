//
//  KWSGameAudioManager.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 10.09.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class KWSGameAudioManager: KWSAudioManager {
    
    //http://iphonedevwiki.net/index.php/AudioServices
    let kKWSKeyPressedID : SystemSoundID = 1306
    
    static let sharedInstance = KWSGameAudioManager()
    
    override init() {
    
        super.init()
        self.loadResources()
    }
   
    func loadResources() {
        
        self.loadSound(soundName: "Attack")
        self.loadSound(soundName: "Jump")
        self.loadSound(soundName: "Walk")
        self.loadSound(soundName: "Die")
        self.loadSound(soundName: "Defense")
        self.loadSound(soundName: "Ouch")
    }
    
    func playClickButtonSound() {
        
        if deviceMuted == true {
            
            return
        }
        
        AudioServicesPlaySystemSound(self.kKWSKeyPressedID)
    }
}
