//
//  Config.swift
//  Muma
//
//  Created by Binboy_王兴彬 on 23/05/2017.
//  Copyright © 2017 Binboy. All rights reserved.
//

import Foundation

enum ClientType: Int {
    case staging = 2
    case release = 0
}

final public class Config {
    
    public static var updatedAccessTokenAction: (() -> Void)?
    public static var updatedPusherIDAction: ((_ pusherID: String) -> Void)?
    
    public static let appGroupID: String = "group.Binboy.Muma"
    
    
    
    
    
    
    
    
    
    #if DEBUG
    static let clientType: ClientType = .staging
    #else
    static let clientType: ClientType = .release
    #endif
}
