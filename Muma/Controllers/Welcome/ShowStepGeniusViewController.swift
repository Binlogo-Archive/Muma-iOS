//
//  ShowStepGeniusViewController.swift
//  FellowPlusSwift
//
//  Created by FellowPlus-Binboy on 2/23/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import UIKit

class ShowStepGeniusViewController: ShowStepViewController {

    @IBOutlet weak var rightPurpleDot: UIImageView!
    @IBOutlet weak var rightGreenDot: UIImageView!
    @IBOutlet weak var rightBlueDot: UIImageView!
    @IBOutlet weak var topRedDot: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        repeatAnimate(topRedDot, alongWithPath: UIBezierPath(ovalIn: topRedDot.frame.insetBy(dx: 1, dy: 1)), duration: 2)
        repeatAnimate(rightBlueDot, alongWithPath: UIBezierPath(ovalIn: rightBlueDot.frame.insetBy(dx: 1, dy: 1)), duration: 3)
        repeatAnimate(rightGreenDot, alongWithPath: UIBezierPath(ovalIn: rightGreenDot.frame.insetBy(dx: 1, dy: 1)), duration: 3)
    }
}
