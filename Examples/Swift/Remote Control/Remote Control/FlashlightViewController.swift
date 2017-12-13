//
//  FlashlightViewController.swift
//  Remote Control
//
//  Created by Calvin on 7/11/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

import UIKit

class FlashlightViewController: UIViewController {
    
    @IBOutlet weak var flashlightButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func turnOnFlashlight(_ sender: Any) {
        self.flashlightButton.isEnabled = false
        
        self.perform(#selector(enableFlashlightButton),
                     with: nil,
                     afterDelay: 15)
        
        if (self.tabBarController != nil) {
            let tabBarController = self.tabBarController as! AdminViewTabBarController
            tabBarController.send(object: nil, sender: self)
        }
    }
    
    @objc func enableFlashlightButton() {
        self.flashlightButton.isEnabled = true
    }

}
