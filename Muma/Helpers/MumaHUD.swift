//
//  MumaHUD.swift
//  Muma
//
//  Created by Binboy on 4/15/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import UIKit

class MumaHUD: NSObject {
    static let sharedInstance = MumaHUD()
    
    var isShowing = false
    var dismissTimer: Timer?
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        return view
    }()
    
    class func showActivityIndicator() {
        showActivityIndicatorWhileBlockingUI(true)
    }
    
    class func showActivityIndicatorWhileBlockingUI(_ blockingUI: Bool) {
        
        if self.sharedInstance.isShowing {
            return // TODO: 或者用新的取代旧的
        }
        
        DispatchQueue.main.async {
            if
                let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let window = appDelegate.window {
                
                self.sharedInstance.isShowing = true
                
                self.sharedInstance.containerView.isUserInteractionEnabled = blockingUI
                
                self.sharedInstance.containerView.alpha = 0
                window.addSubview(self.sharedInstance.containerView)
                self.sharedInstance.containerView.frame = window.bounds
                
                UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                    self.sharedInstance.containerView.alpha = 1
                    
                    }, completion: { (finished) -> Void in
                        self.sharedInstance.containerView.addSubview(self.sharedInstance.activityIndicator)
                        self.sharedInstance.activityIndicator.center = self.sharedInstance.containerView.center
                        self.sharedInstance.activityIndicator.startAnimating()
                        
                        self.sharedInstance.activityIndicator.alpha = 0
                        self.sharedInstance.activityIndicator.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
                        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                            self.sharedInstance.activityIndicator.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                            self.sharedInstance.activityIndicator.alpha = 1
                            
                            }, completion: { (finished) -> Void in
                                self.sharedInstance.activityIndicator.transform = CGAffineTransform.identity
                                
                                if let dismissTimer = self.sharedInstance.dismissTimer {
                                    dismissTimer.invalidate()
                                }
                                
                                self.sharedInstance.dismissTimer = Timer.scheduledTimer(timeInterval: MumaConfig.forcedHideActivityIndicatorTimeInterval, target: self, selector: #selector(MumaHUD.forcedHideActivityIndicator), userInfo: nil, repeats: false)
                        })
                })
            }
        }
    }
    
    class func forcedHideActivityIndicator() {
        hideActivityIndicator() {
            if
                let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let viewController = appDelegate.window?.rootViewController {
                MumaAlert.alertSorry(message: NSLocalizedString("Wait too long, the operation may not be completed.", comment: ""), inViewController: viewController)
            }
        }
    }
    
    class func hideActivityIndicator() {
        hideActivityIndicator() {
        }
    }
    
    class func hideActivityIndicator(_ completion: @escaping () -> Void) {
        
        DispatchQueue.main.async {
            
            if self.sharedInstance.isShowing {
                
                self.sharedInstance.activityIndicator.transform = CGAffineTransform.identity
                
                UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                    self.sharedInstance.activityIndicator.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
                    self.sharedInstance.activityIndicator.alpha = 0
                    
                    }, completion: { (finished) -> Void in
                        self.sharedInstance.activityIndicator.removeFromSuperview()
                        
                        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                            self.sharedInstance.containerView.alpha = 0
                            
                            }, completion: { (finished) -> Void in
                                self.sharedInstance.containerView.removeFromSuperview()
                                
                                completion()
                        })
                })
            }
            
            self.sharedInstance.isShowing = false
        }
    }

}
