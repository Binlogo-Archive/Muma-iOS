//
//  ShowStepViewController.swift
//  FellowPlusSwift
//
//  Created by FellowPlus-Binboy on 2/23/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import UIKit

class ShowStepViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var titleLabelBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet fileprivate weak var subTitleLabelBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions(), animations: { [weak self] in
                self?.view.alpha = 1
            }) { _ in }
    }
    
    func repeatAnimate(_ view: UIView, alongWithPath path: UIBezierPath, duration: CFTimeInterval, autoreverses: Bool = false) {
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        
        animation.calculationMode = kCAAnimationPaced
        animation.fillMode = kCAFillModeForwards
        animation.duration = duration
        animation.repeatCount = Float.infinity
        animation.autoreverses = autoreverses
        
        if autoreverses {
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        } else {
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        }
        
        animation.path = path.cgPath
        
        view.layer.add(animation, forKey: "Animation")
    }
    
    func animate(_ view: UIView, offset: UInt32, duration: CFTimeInterval) {
        
        let path = UIBezierPath()
        
        func flip() -> CGFloat {
            return arc4random() % 2 == 0 ? -1 : 1;
        }
        
        let beginPointX = view.center.x + CGFloat(arc4random() % offset) * flip()
        let beginPointY = view.center.y + CGFloat(arc4random() % offset) * 0.5 * flip()
        let beginPoint = CGPoint(x: beginPointX, y: beginPointY)
        
        let endPointX = view.center.x + CGFloat(arc4random() % offset) * flip()
        let endPointY = view.center.y + CGFloat(arc4random() % offset) * 0.5 * flip()
        let endPoint = CGPoint(x: endPointX, y: endPointY)
        
        path.move(to: beginPoint)
        path.addLine(to: endPoint)
        
        repeatAnimate(view, alongWithPath: path, duration: duration, autoreverses: true)
        repeatRotate(view, fromValue: -0.1 as AnyObject, toValue: 0.1 as AnyObject, duration: duration)
    }
    
    fileprivate func repeatRotate(_ view: UIView, fromValue: AnyObject, toValue: AnyObject, duration: CFTimeInterval) {
        
        let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
        
        rotate.fromValue = fromValue
        rotate.toValue = toValue
        rotate.duration = duration
        rotate.repeatCount = Float.infinity
        rotate.autoreverses = true
        rotate.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        view.layer.allowsEdgeAntialiasing = true
        
        view.layer.add(rotate, forKey: "Rotate")
    }
}
