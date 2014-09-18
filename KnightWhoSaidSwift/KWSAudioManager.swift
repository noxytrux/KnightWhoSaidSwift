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
    
    //for now lets use AVAudioPlayer as long as CoreAudio is not functional...
    private var audioSession : AVAudioSession!
    private var backgroundMusicPlayer : AVAudioPlayer? = nil
    private var playingMusic : Bool = false

    private var _deviceMuted : Bool = false {
        
        didSet {
            
            if let backgroundMusicPlayer = self.backgroundMusicPlayer {
            
                if _deviceMuted && backgroundMusicPlayer.playing {
                    
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
    
    class var sharedInstance : KWSAudioManager {
        
        dispatch_once(&staticStruct.onceToken) {
            
            staticStruct.instance = KWSAudioManager()
        }
        
        return staticStruct.instance! as KWSAudioManager
    }
    
    func setupAudioSession() {
    
        self.audioSession = AVAudioSession.sharedInstance()
        var setCategoryError : NSError? = nil
        
        if self.audioSession.otherAudioPlaying {
            
            self.audioSession.setCategory(AVAudioSessionCategorySoloAmbient, error: &setCategoryError)
            
        } else {
            
            self.audioSession.setCategory(AVAudioSessionCategoryAmbient, error: &setCategoryError)
        }
        
        if let setCategoryError = setCategoryError {
            
            println("Error setting category: \(setCategoryError.localizedDescription) code: \(setCategoryError.code)");
        }
    }
    
    func setMusicVolume(#volume: Float) {
        
        self.backgroundMusicPlayer?.volume = volume
    }
    
    func stopMusic() {
    
        self.playingMusic = false
        
        if let backgroundMusicPlayer = self.backgroundMusicPlayer {
            
            if backgroundMusicPlayer.playing {
                
                backgroundMusicPlayer.stop()
            }
        }
    }

    func playMusic(#musicName: String!) {
    
        if let backgroundMusicPlayer = self.backgroundMusicPlayer {
            
            if backgroundMusicPlayer.playing {
                
                backgroundMusicPlayer.stop()
            }
        }
        
        var path = NSBundle.mainBundle().pathForResource(musicName, ofType: "mp3")
    
        if let path = path {
        
            var error : NSError? = nil
            
            self.backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: NSURL.fileURLWithPath(path), error: &error)
           
            if let backgroundMusicPlayer = self.backgroundMusicPlayer {
                
                backgroundMusicPlayer.delegate = self
                
                backgroundMusicPlayer.numberOfLoops = -1
                backgroundMusicPlayer.prepareToPlay()
                backgroundMusicPlayer.play()
            }
            
            self.playingMusic = true
            
            if let error = error {
            
                println("Error while opening music file: \(musicName)")
            }
        }
        else {
            
            println("Error while loading music named: \(musicName)")
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

