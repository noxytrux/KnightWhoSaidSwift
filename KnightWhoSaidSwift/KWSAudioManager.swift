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
    
    internal struct staticStruct {
        
        static var onceToken : dispatch_once_t = 0
        static var instance : AnyObject? = nil
    }

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
        }
    }

    internal var backgroundMusicInterrupted : Bool = false
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
        
        assert(staticStruct.instance == nil, "Singleton already initialized!")
        
        super.init()
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        self.deviceMuted = userDefaults.boolForKey(kKWSAudioDeviceMuteKey)
        self.setupAudioSession()
    }
    
    deinit {
        
        for (_, object) in enumerate(self.audioSamplesIdentifiers) {
            
            AudioServicesDisposeSystemSoundID(object)
        }
    }
    
    func setupAudioSession() {
        
        var setCategoryErr : NSError?
        var activateErr : NSError?
        var audioSession = AVAudioSession.sharedInstance()
        
        audioSession.setCategory(AVAudioSessionCategoryPlayback, withOptions: AVAudioSessionCategoryOptions.MixWithOthers, error: &setCategoryErr)
        audioSession.setActive(true, error: &activateErr)
        
        if let setCategoryErr = setCategoryErr {
        
            println("Error while setting category: \(setCategoryErr)")
        }
        
        if let activateErr = activateErr {
            
            println("Error while activating session: \(activateErr)")
        }
    }
    
    class var sharedInstance : KWSAudioManager {
        
        dispatch_once(&staticStruct.onceToken) {
            
            staticStruct.instance = KWSAudioManager()
        }
        
        return staticStruct.instance! as KWSAudioManager
    }
    
    func setMusicVolume(#volume: Float) {
        
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

    func playMusic(#musicName: String!) {
    
        self.backgroundMusicPlayer = KWSBackgroundStreamPlayer()
        
        if let backgroundMusicPlayer = self.backgroundMusicPlayer {
            
            backgroundMusicPlayer.loadFromFile(musicName, repeat: true)
            backgroundMusicPlayer.play()
        
            self.playingMusic = true
        }
    }

    func loadSound(#soundName: String!) {
    
        var soundID : SystemSoundID = 0
        
        var path = NSBundle.mainBundle().pathForResource(soundName, ofType: "aiff")
        
        if let path = path {
            
            AudioServicesCreateSystemSoundID(NSURL.fileURLWithPath(path),&soundID)
            self.audioSamplesIdentifiers.append(soundID)
        }
        else {
        
            println("Error while loading sound named: \(soundName)")
        }
    }
    
    func playSound(#soundNumber: Int) {
        
        if deviceMuted {
        
            return
        }
        
        AudioServicesPlaySystemSound(self.audioSamplesIdentifiers[soundNumber])
    }
    
    //MARK: AVAudioPlayer delegate implementation
    
    func audioPlayerBeginInterruption(player: AVAudioPlayer!) {
        
        self.backgroundMusicInterrupted = true
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer!, withOptions flags: Int) {
        
        self.backgroundMusicInterrupted = false
    }
}

