//
//  BaseViewController.swift
//  Muma
//
//  Created by Binboy on 4/13/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import UIKit

class MumaNavigationController: UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interactivePopGestureRecognizer?.delegate = self
        
        delegate = self
        
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func pushViewController(viewController: UIViewController, animated: Bool) {
        if animated {
            interactivePopGestureRecognizer?.enabled = false
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
    override func popToRootViewControllerAnimated(animated: Bool) -> [UIViewController]? {
        if animated {
            interactivePopGestureRecognizer?.enabled = false
        }
        
        return super.popToRootViewControllerAnimated(animated)
    }
    
    override func popToViewController(viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if animated {
            interactivePopGestureRecognizer?.enabled = false
        }
        
        return super.popToViewController(viewController, animated: false)
    }
    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        interactivePopGestureRecognizer?.enabled = true
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == interactivePopGestureRecognizer {
            if self.viewControllers.count < 2 || self.visibleViewController == self.viewControllers[0] {
                return false
            }
        }
        
        return true
    }
}
