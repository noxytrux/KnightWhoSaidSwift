//
//  KWSCreditsViewController.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 01.09.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import UIKit

class KWSCreditsViewController: UIViewController {
    
    @IBOutlet weak var creditsTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.creditsTextView.text = "Programing:\n\nMarcin Malysz\n\nGraphics:\n\nInternet"
        self.creditsTextView.textAlignment = NSTextAlignment.Center
        self.creditsTextView.font = UIFont(name: "FFFAtlantisTrial", size: 14)
    }
    
    @IBAction func dismissViewController(sender: UIButton) {
        
        let gameAudio = KWSGameAudioManager.sharedInstance
            gameAudio.playClickButtonSound()

        self.navigationController?.popViewControllerAnimated(true)
    }
}
