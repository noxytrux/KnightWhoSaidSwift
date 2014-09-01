//
//  KWSSettingsViewController.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 01.09.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import UIKit

class KWSSettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func dismissViewController(sender: UIButton) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
