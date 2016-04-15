//
//  MumaUserDefaults.swift
//  Muma
//
//  Created by Binboy on 4/13/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import UIKit
import RealmSwift
import CoreSpotlight

private let v1AccessTokenKey = "v1AccessToken"
private let userIDKey = "userID"
private let nicknameKey = "nickname"
private let avatarURLStringKey = "avatarURLString"
private let pusherIDKey = "pusherID"

struct Listener<T>: Hashable {
    let name: String
    
    typealias Action = T -> Void
    let action: Action
    
    var hashValue: Int {
        return name.hashValue
    }
}

func ==<T>(lhs: Listener<T>, rhs: Listener<T>) -> Bool {
    return lhs.name == rhs.name
}

class Listenable<T> {
    var value: T {
        didSet {
            setterAction(value)
            
            for listener in listenerSet {
                listener.action(value)
            }
        }
    }
    
    typealias SetterAction = T -> Void
    var setterAction: SetterAction
    
    var listenerSet = Set<Listener<T>>()
    
    func bindListener(name: String, action: Listener<T>.Action) {
        let listener = Listener(name: name, action: action)
        
        listenerSet.insert(listener)
    }
    
    func bindAndFireListener(name: String, action: Listener<T>.Action) {
        bindListener(name, action: action)
        
        action(value)
    }
    
    func removeListenerWithName(name: String) {
        for listener in listenerSet {
            if listener.name == name {
                listenerSet.remove(listener)
                break
            }
        }
    }
    
    func removeAllListeners() {
        listenerSet.removeAll(keepCapacity: false)
    }
    
    init(_ v: T, setterAction action: SetterAction) {
        value = v
        setterAction = action
    }
}

class MumaUserDefaults {
    
    static let defaults = NSUserDefaults(suiteName: "top.Binboy.Muma")!
    
    static var isLogined: Bool {
        
        if let _ = MumaUserDefaults.v1AccessToken.value {
            return true
        } else {
            return false
        }
    }
    
    static var v1AccessToken: Listenable<String?> = {
        let v1AccessToken = defaults.stringForKey(v1AccessTokenKey)
        
        return Listenable<String?>(v1AccessToken) { v1AccessToken in
            defaults.setObject(v1AccessToken, forKey: v1AccessTokenKey)
            
            if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                // 注册或初次登录时同步数据的好时机
//                appDelegate.sync()
                
                // 也是注册或初次登录时启动 Faye 的好时机
//                appDelegate.startFaye()
            }
        }
    }()
    
    static var userID: Listenable<String?> = {
        let userID = defaults.stringForKey(userIDKey)
        
        return Listenable<String?>(userID) { userID in
            defaults.setObject(userID, forKey: userIDKey)
        }
    }()
    
    static var nickname: Listenable<String?> = {
        let nickname = defaults.stringForKey(nicknameKey)
        
        return Listenable<String?>(nickname) { nickname in
            defaults.setObject(nickname, forKey: nicknameKey)
            
            guard let realm = try? Realm() else {
                return
            }
            
            if let
                nickname = nickname,
                myUserID = MumaUserDefaults.userID.value,
                me = userWithUserID(myUserID, inRealm: realm) {
                let _ = try? realm.write {
                    me.nickname = nickname
                }
            }
        }
    }()

    static var avatarURLString: Listenable<String?> = {
        let avatarURLString = defaults.stringForKey(avatarURLStringKey)
        
        return Listenable<String?>(avatarURLString) { avatarURLString in
            defaults.setObject(avatarURLString, forKey: avatarURLStringKey)
            
            guard let realm = try? Realm() else {
                return
            }
            
            if let
                avatarURLString = avatarURLString,
                myUserID = MumaUserDefaults.userID.value,
                me = userWithUserID(myUserID, inRealm: realm) {
                let _ = try? realm.write {
                    me.avatarURLString = avatarURLString
                }
            }
        }
    }()
    
    static var pusherID: Listenable<String?> = {
        let pusherID = defaults.stringForKey(pusherIDKey)
        
        return Listenable<String?>(pusherID) { pusherID in
            defaults.setObject(pusherID, forKey: pusherIDKey)
            
            // 注册推送的好时机
            if let
                pusherID = pusherID,
                appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
//                if appDelegate.notRegisteredPush {
//                    appDelegate.notRegisteredPush = false
//                    
//                    if let deviceToken = appDelegate.deviceToken {
//                        appDelegate.registerThirdPartyPushWithDeciveToken(deviceToken, pusherID: pusherID)
//                    }
//                }
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
            defaults.removeObjectForKey($0)
        })
        defaults.synchronize()
        
        // reset standardUserDefaults
        
        let standardUserDefaults = NSUserDefaults.standardUserDefaults()
        standardUserDefaults.removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!)
        standardUserDefaults.synchronize()
    }
}
