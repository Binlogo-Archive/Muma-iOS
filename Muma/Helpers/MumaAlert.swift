//
//  MumaAlert.swift
//  Muma
//
//  Created by Binboy on 4/15/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import UIKit
import Proposer

class MumaAlert {
    
    class func alert(title: String, message: String?, dismissTitle: String, inViewController viewController: UIViewController?, withDismissAction dismissAction: (() -> Void)?) {
        
        DispatchQueue.main.async { 
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let action: UIAlertAction = UIAlertAction(title: dismissTitle, style: .default, handler: { action -> Void in
                if let dismissAction = dismissAction {
                    dismissAction()
                }
            })
            
            alertController.addAction(action)
            
            viewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    class func alertSorry(message: String?, inViewController viewController: UIViewController?, withDismissAction dismissAction: @escaping () -> Void) {
        alert(title: NSLocalizedString("Sorry", comment: ""), message: message, dismissTitle: NSLocalizedString("OK", comment: ""), inViewController: viewController, withDismissAction: dismissAction)
    }
    
    class func alertSorry(message: String?, inViewController viewController: UIViewController?) {
        alert(title: NSLocalizedString("Sorry", comment: ""), message: message, dismissTitle: NSLocalizedString("OK", comment: ""), inViewController: viewController, withDismissAction: nil)
    }
    
    class func textInput(title: String, placeholder: String?, oldText: String?, dismissTitle: String, inViewController viewController: UIViewController?, withFinishedAction finishedAction: ((_ text: String) -> Void)?) {
        
        DispatchQueue.main.async {
            
            let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            
            alertController.addTextField { (textField) -> Void in
                textField.placeholder = placeholder
                textField.text = oldText
            }
            
            let action: UIAlertAction = UIAlertAction(title: dismissTitle, style: .default) { action -> Void in
                if let finishedAction = finishedAction {
                    if let textField = alertController.textFields?.first, let text = textField.text {
                        finishedAction(text)
                    }
                }
            }
            alertController.addAction(action)
            
            viewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    class func textInput(title: String, message: String?, placeholder: String?, oldText: String?, confirmTitle: String, cancelTitle: String, inViewController viewController: UIViewController?, withConfirmAction confirmAction: ((_ text: String) -> Void)?, cancelAction: (() -> Void)?) {
        
        DispatchQueue.main.async {
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alertController.addTextField { (textField) -> Void in
                textField.placeholder = placeholder
                textField.text = oldText
            }
            
            let _cancelAction: UIAlertAction = UIAlertAction(title: cancelTitle, style: .cancel) { action -> Void in
                cancelAction?()
            }
            alertController.addAction(_cancelAction)
            
            let _confirmAction: UIAlertAction = UIAlertAction(title: confirmTitle, style: .default) { action -> Void in
                if let textField = alertController.textFields?.first, let text = textField.text {
                    confirmAction?(text)
                }
            }
            alertController.addAction(_confirmAction)
            
            viewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    class func confirmOrCancel(title: String, message: String, confirmTitle: String, cancelTitle: String, inViewController viewController: UIViewController?, withConfirmAction confirmAction: @escaping () -> Void, cancelAction: @escaping () -> Void) {
        
        DispatchQueue.main.async {
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let cancelAction: UIAlertAction = UIAlertAction(title: cancelTitle, style: .cancel) { action -> Void in
                cancelAction()
            }
            alertController.addAction(cancelAction)
            
            let confirmAction: UIAlertAction = UIAlertAction(title: confirmTitle, style: .default) { action -> Void in
                confirmAction()
            }
            alertController.addAction(confirmAction)
            
            viewController?.present(alertController, animated: true, completion: nil)
        }
    }
}

extension UIViewController {
    
    func alertCanNotAccessCameraRoll() {
        
        DispatchQueue.main.async {
            MumaAlert.confirmOrCancel(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("Muma can not access your Camera Roll!\nBut you can change it in iOS Settings.", comment: ""), confirmTitle: NSLocalizedString("Change it now", comment: ""), cancelTitle: NSLocalizedString("Dismiss", comment: ""), inViewController: self, withConfirmAction: {
                
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                
                }, cancelAction: {
            })
        }
    }
    
    func alertCanNotOpenCamera() {
        
        DispatchQueue.main.async {
            MumaAlert.confirmOrCancel(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("Muma can not open your Camera!\nBut you can change it in iOS Settings.", comment: ""), confirmTitle: NSLocalizedString("Change it now", comment: ""), cancelTitle: NSLocalizedString("Dismiss", comment: ""), inViewController: self, withConfirmAction: {
                
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                
                }, cancelAction: {
            })
        }
    }
    
    func alertCanNotAccessMicrophone() {
        
        DispatchQueue.main.async {
            MumaAlert.confirmOrCancel(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("Muma can not access your Microphone!\nBut you can change it in iOS Settings.", comment: ""), confirmTitle: NSLocalizedString("Change it now", comment: ""), cancelTitle: NSLocalizedString("Dismiss", comment: ""), inViewController: self, withConfirmAction: {
                
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                
                }, cancelAction: {
            })
        }
    }
    
    func alertCanNotAccessContacts() {
        
        DispatchQueue.main.async {
            MumaAlert.confirmOrCancel(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("Muma can not read your Contacts!\nBut you can change it in iOS Settings.", comment: ""), confirmTitle: NSLocalizedString("Change it now", comment: ""), cancelTitle: NSLocalizedString("Dismiss", comment: ""), inViewController: self, withConfirmAction: {
                
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                
                }, cancelAction: {
            })
        }
    }
    
    func alertCanNotAccessLocation() {
        
        DispatchQueue.main.async {
            MumaAlert.confirmOrCancel(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("Muma can not get your Location!\nBut you can change it in iOS Settings.", comment: ""), confirmTitle: NSLocalizedString("Change it now", comment: ""), cancelTitle: NSLocalizedString("Dismiss", comment: ""), inViewController: self, withConfirmAction: {
                
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                
                }, cancelAction: {
            })
        }
    }

    func showProposeMessageIfNeedForContactsAndTryPropose(_ propose: @escaping Propose) {
        
        if PrivateResource.contacts.isNotDeterminedAuthorization {
            
            DispatchQueue.main.async {
                
                MumaAlert.confirmOrCancel(title: NSLocalizedString("Notice", comment: ""), message: NSLocalizedString("Muma need to read your Contacts to continue this operation.\nIs that OK?", comment: ""), confirmTitle: NSLocalizedString("OK", comment: ""), cancelTitle: NSLocalizedString("Not now", comment: ""), inViewController: self, withConfirmAction: {
                    
                    propose()
                    
                    }, cancelAction: {
                })
            }
            
        } else {
            propose()
        }
    }
}
