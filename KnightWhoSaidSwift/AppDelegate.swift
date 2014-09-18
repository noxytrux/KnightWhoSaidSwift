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

        //self.printFonts()
        
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

