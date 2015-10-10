//
//  KWSBackgroundStreamPlayer.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 08.09.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import UIKit
import AudioToolbox

class KWSBackgroundStreamPlayer: NSObject {
   
    private var trackClosed : Bool
   
    internal var filePath : String!
    internal var repeatSong : Bool
    
    override init() {
        
        self.trackClosed = false
        self.repeatSong = false
        
        super.init()
    }
    
    func loadFromFile(filename : String!, repeatSong: Bool ) {
        
        if filename == nil {
            return
        }
    
        let path = NSBundle.mainBundle().pathForResource(filename, ofType: "mp3")
        
        if let path = path {
            
            self.filePath = path
            self.repeatSong = repeatSong

            //convert self to unmanaged object
            let anUnmanaged = Unmanaged<KWSBackgroundStreamPlayer>.passUnretained(self)
            //get raw data pointer
            let opaque : COpaquePointer = anUnmanaged.toOpaque()
            //convert to Mutable to match Swift safe type check
            let voidSelf = UnsafeMutablePointer<Void>(opaque)
            
            InitializeAudioSource( voidSelf )
        
            self.trackClosed = false;
        }
        else {
            
            print("Error while loading music named: \(filename)")
        }
    }
    
    func setGain(gain : Float32) {
        
        SetAudioGain(gain)
    }
    
    func play() {
    
        PlayAudio()
    }
    
    func pause() {
    
        PauseAudio()
    }
    
    func close() {
    
        if self.trackClosed == true {
        
            return
        }
        
        self.trackClosed = true
       
        CloseAudio()
    }
    
    deinit {
        
        self.close()
    }
    
}
