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
    internal var repeat : Bool
    
    override init() {
        
        self.trackClosed = false
        self.repeat = false
        
        super.init()
    }
    
    func loadFromFile(filename : String!, repeat: Bool ) {
        
        if filename == nil {
            return
        }
    
        var path = NSBundle.mainBundle().pathForResource(filename, ofType: "mp3")
        
        if let path = path {
            
            self.filePath = path
            self.repeat = repeat

            //convert self to proper void pointer
            let anUnmanaged = Unmanaged<KWSBackgroundStreamPlayer>.passUnretained(self)
            let opaque : COpaquePointer = anUnmanaged.toOpaque()
            let voidSelf = UnsafeMutablePointer<Void>(opaque)

            InitializeAudioSource( voidSelf )
            
            self.trackClosed = false;
        }
        else {
            
            println("Error while loading music named: \(filename)")
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
