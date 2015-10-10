//
//  KWSAudioManager.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 08.09.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

let kKWSAudioDeviceMuteKey : String! = "kKWSAudioDeviceMuteKey"

class KWSAudioManager: NSObject, AVAudioPlayerDelegate {
    
    private var audioSamplesIdentifiers = [SystemSoundID]()
    
    private var backgroundMusicPlayer : KWSBackgroundStreamPlayer? = nil
    private var playingMusic : Bool = false

    private var _deviceMuted : Bool = false {
        
        didSet {
            
            if let backgroundMusicPlayer = self.backgroundMusicPlayer {
            
                if self.playingMusic && _deviceMuted {
                    
                    backgroundMusicPlayer.pause()
                }
                
                if self.playingMusic && !_deviceMuted {
                    
                    backgroundMusicPlayer.play()
                }
            }
            
            let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setBool(_deviceMuted, forKey: kKWSAudioDeviceMuteKey)
                defaults.synchronize()
        }
    }

    internal var deviceMuted : Bool {
        
        get {
            
            return _deviceMuted
        }
        
        set (newValue) {
        
            if (newValue != deviceMuted) {
            
                _deviceMuted = newValue
            }
        }
    } 
    
    override init() {
    
        super.init()
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        self.deviceMuted = userDefaults.boolForKey(kKWSAudioDeviceMuteKey)
        self.setupAudioSession()
    }
    
    deinit {
        
        if self.playingMusic {
        
            if let backgroundMusicPlayer = self.backgroundMusicPlayer {
                
                backgroundMusicPlayer.close()
            }
        }
        
        for (_, object) in self.audioSamplesIdentifiers.enumerate() {
            
            AudioServicesDisposeSystemSoundID(object)
        }
    }
    
    func setupAudioSession() {
        
        var setCategoryErr : NSError?
        var activateErr : NSError?
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback, withOptions: AVAudioSessionCategoryOptions.MixWithOthers)
        } catch let error as NSError {
            setCategoryErr = error
        }
        do {
            try audioSession.setActive(true)
        } catch let error as NSError {
            activateErr = error
        }
        
        if let setCategoryErr = setCategoryErr {
        
            print("Error while setting category: \(setCategoryErr)")
        }
        
        if let activateErr = activateErr {
            
            print("Error while activating session: \(activateErr)")
        }
    }

    func setMusicVolume(volume volume: Float) {
        
        if let backgroundMusicPlayer = self.backgroundMusicPlayer {
            
            backgroundMusicPlayer.setGain(volume)
        }
    }
    
    func stopMusic() {
    
        self.playingMusic = false
        
        if let backgroundMusicPlayer = self.backgroundMusicPlayer {
        
            backgroundMusicPlayer.pause()
        }
    }

    func playMusic(musicName musicName: String!) {
    
        self.backgroundMusicPlayer = KWSBackgroundStreamPlayer()
        
        if let backgroundMusicPlayer = self.backgroundMusicPlayer {
            
            backgroundMusicPlayer.loadFromFile(musicName, repeatSong: true)
            backgroundMusicPlayer.play()
            
            self.playingMusic = true
            
            if deviceMuted {
             
                backgroundMusicPlayer.pause()
            }
        }
    }

    func loadSound(soundName soundName: String!) {
    
        var soundID : SystemSoundID = 0
        
        let path = NSBundle.mainBundle().pathForResource(soundName, ofType: "aiff")
        
        if let path = path {
            
            AudioServicesCreateSystemSoundID(NSURL.fileURLWithPath(path),&soundID)
            self.audioSamplesIdentifiers.append(soundID)
        }
        else {
        
            print("Error while loading sound named: \(soundName)")
        }
    }
    
    func playSound(soundNumber soundNumber: Int) {
        
        if deviceMuted {
        
            return
        }
        
        AudioServicesPlaySystemSound(self.audioSamplesIdentifiers[soundNumber])
    }
    
}

