//
//  MumaUserDefaults.swift
//  Muma
//
//  Created by Binboy on 4/13/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import UIKit
import CoreSpotlight
import RealmSwift

//MARK: - Key Definition

private let v1AccessTokenKey = "v1AccessToken"
private let userIDKey = "userID"
private let nicknameKey = "nickname"
private let avatarURLStringKey = "avatarURLString"
private let pusherIDKey = "pusherID"

//MARK: -

public struct Listener<T>: Hashable {
    
    let name: String
    
    public typealias Action = (T) -> Void
    let action: Action
    
    public var hashValue: Int {
        return name.hashValue
    }
}

public func ==<T>(lhs: Listener<T>, rhs: Listener<T>) -> Bool {
    return lhs.name == rhs.name
}

final public class Listenable<T> {
    
    public var value: T {
        didSet {
            setterAction(value)
            
            for listener in listenerSet {
                listener.action(value)
            }
        }
    }
    
    public typealias SetterAction = (T) -> Void
    var setterAction: SetterAction
    
    var listenerSet = Set<Listener<T>>()
    
    public func bindListener(_ name: String, action: @escaping Listener<T>.Action) {
        
        let listener = Listener(name: name, action: action)
        
        listenerSet.update(with: listener)
    }
    
    public func bindAndFireListener(_ name: String, action: @escaping Listener<T>.Action) {
        bindListener(name, action: action)
        
        action(value)
    }
    
    public func removeListener(named name: String) {
        for listener in listenerSet {
            if listener.name == name {
                listenerSet.remove(listener)
                break
            }
        }
    }
    
    public func removeAllListeners() {
        listenerSet.removeAll(keepingCapacity: false)
    }
    
    public init(_ v: T, setterAction action: @escaping SetterAction) {
        value = v
        setterAction = action
    }
}

//MARK: - UserDefault

public class MumaUserDefaults {
    
    public static let defaults = UserDefaults(suiteName: Config.appGroupID)!
    
    public static var isLogined: Bool {
        
        if let _ = MumaUserDefaults.v1AccessToken.value {
            return true
        } else {
            return false
        }
    }
    
    public static var v1AccessToken: Listenable<String?> = {
        let v1AccessToken = defaults.string(forKey: v1AccessTokenKey)
        
        return Listenable<String?>(v1AccessToken) { v1AccessToken in
            defaults.set(v1AccessToken, forKey: v1AccessTokenKey)
            
            Config.updatedAccessTokenAction?()
        }
    }()
    
    public static var userID: Listenable<String?> = {
        let userID = defaults.string(forKey: userIDKey)
        
        return Listenable<String?>(userID) { userID in
            defaults.set(userID, forKey: userIDKey)
        }
    }()
    
    public static var nickname: Listenable<String?> = {
        let nickname = defaults.string(forKey: nicknameKey)
        
        return Listenable<String?>(nickname) { nickname in
            defaults.set(nickname, forKey: nicknameKey)
            
            guard let realm = try? Realm() else {
                return
            }
            
            if let nickname = nickname,
                let myUserID = MumaUserDefaults.userID.value,
                let me = userWithUserID(myUserID, inRealm: realm) {
                let _ = try? realm.write {
                    me.nickname = nickname
                }
            }
        }
    }()

    public static var avatarURLString: Listenable<String?> = {
        let avatarURLString = defaults.string(forKey: avatarURLStringKey)
        
        return Listenable<String?>(avatarURLString) { avatarURLString in
            defaults.set(avatarURLString, forKey: avatarURLStringKey)
            
            guard let realm = try? Realm() else {
                return
            }
            
            if let avatarURLString = avatarURLString,
                let myUserID = MumaUserDefaults.userID.value,
                let me = userWithUserID(myUserID, inRealm: realm) {
                let _ = try? realm.write {
                    me.avatarURLString = avatarURLString
                }
            }
        }
    }()
    
    public static var pusherID: Listenable<String?> = {
        let pusherID = defaults.string(forKey: pusherIDKey)
        
        return Listenable<String?>(pusherID) { pusherID in
            defaults.set(pusherID, forKey: pusherIDKey)
            
            // 注册推送的好时机
            if let pusherID = pusherID {
                Config.updatedPusherIDAction?(pusherID)
            }
        }
    }()
    
    // MARK: ReLogin
    
    class func cleanAllUserDefaults() {
        
        v1AccessToken.removeAllListeners()
        userID.removeAllListeners()
        nickname.removeAllListeners()
        avatarURLString.removeAllListeners()
        
        // reset suite
        
        let dict = defaults.dictionaryRepresentation()
        dict.keys.forEach({
            defaults.removeObject(forKey: $0)
        })
        defaults.synchronize()
        
        // reset standardUserDefaults
        
        let standardUserDefaults = UserDefaults.standard
        standardUserDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        standardUserDefaults.synchronize()
    }
}
