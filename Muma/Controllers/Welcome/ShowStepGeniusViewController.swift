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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        repeatAnimate(topRedDot, alongWithPath: UIBezierPath(ovalInRect: CGRectInset(topRedDot.frame, 1, 1)), duration: 2)
        repeatAnimate(rightBlueDot, alongWithPath: UIBezierPath(ovalInRect: CGRectInset(rightBlueDot.frame, 1, 1)), duration: 3)
        repeatAnimate(rightGreenDot, alongWithPath: UIBezierPath(ovalInRect: CGRectInset(rightGreenDot.frame, 1, 1)), duration: 3)
    }
}
