//
//  Manager.swift
//  Muma
//
//  Created by Binboy_王兴彬 on 22/05/2017.
//  Copyright © 2017 Binboy. All rights reserved.
//

import Foundation

open class Manager {
    
    open static var accessToken: (() -> String?)?
    
    open static var authFailedAction: ((_ statusCode: Int, _ host: String) -> Void)?
    
    open static var networkActivityCountChangedAction: ((_ count: Int) -> Void)?
}
