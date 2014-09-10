//
//  AppDelegate.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 27.08.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?


    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {

        self.printFonts()
        
        
        let runAfter : dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
    
        dispatch_after(runAfter, dispatch_get_main_queue()) { () -> Void in
            
            let gameAudio = KWSGameAudioManager.sharedInstance
                gameAudio.playMusic(musicName: "Menu")
                gameAudio.setMusicVolume(volume: 0.3)
        }
        
        return true
    }
    
    func printFonts() {
        
        let familyNames : [String] = UIFont.familyNames() as [String]
        
        for name : String in familyNames {
            
            println("Family: \(name)")
            
            let fontNames = UIFont.fontNamesForFamilyName(name)
            
            for fontName in fontNames {
                
                println("\tname: \(fontName)")
            }
        }
    }
    
}

