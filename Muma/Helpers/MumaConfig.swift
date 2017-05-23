//
//  MumaConfig.swift
//  Muma
//
//  Created by Binboy on 4/15/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import UIKit

final class MumaConfig {
    
    struct CellIdentifier {
        static let userInfoTextCell = "UserInfoTextCell"
        static let userInfoIconCell = "UserInfoIconCell"
    }
    
    static let forcedHideActivityIndicatorTimeInterval: TimeInterval = 30
    
    struct NotificationName {
        
        static let applicationDidBecomeActive = Notification.Name(rawValue: "MumaConfig.Notification.applicationDidBecomeActive")
        
    }
    
    struct UserInfo {
        static let headerViewHeight:CGFloat = 230
    }
    
    
    
}
