//
//  SegueViewController.swift
//  Muma
//
//  Created by Binboy_王兴彬 on 23/05/2017.
//  Copyright © 2017 Binboy. All rights reserved.
//

import UIKit

class SegueViewController: UIViewController {
    
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        
        if let navigationController = navigationController {
            guard navigationController.topViewController == self else {
                return
            }
        }
        
        super.performSegue(withIdentifier: identifier, sender: sender)
    }
}
