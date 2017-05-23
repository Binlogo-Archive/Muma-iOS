//
//  User.swift
//  Muma
//
//  Created by Binboy on 4/13/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import Foundation
import RealmSwift

public enum UserFriendState: Int {
    case stranger      = 0   // 陌生人
    case issuedRequest = 1   // 已发出好友请求
    case normal        = 2   // 正常状态的好友
    case blocked       = 3   // 被屏蔽
    case me            = 4   // 自己
    case muma          = 5   // 官方账号
}

public class Avatar: Object {
    dynamic var avatarURLString: String = ""
    dynamic var avatarFileName: String = ""
    
    dynamic var roundMini: Data = Data() // 60
    dynamic var roundNano: Data = Data() // 40
    
    let users = LinkingObjects(fromType: User.self, property: "avatar")
    var user: User? {
        return users.first
    }
}

class UserSocialAccountProvider: Object {
    dynamic var name: String = ""
    dynamic var enabled: Bool = false
}

class User: Object {
    dynamic var userID: String = ""
    dynamic var username: String = ""
    dynamic var nickname: String = ""
    dynamic var introduction: String = ""
    dynamic var avatarURLString: String = ""
    dynamic var avatar: Avatar?
    dynamic var badge: String = ""
    
    override class func indexedProperties() -> [String] {
        return ["userID"]
    }
    
    dynamic var createdUnixTime: TimeInterval = Date().timeIntervalSince1970
    dynamic var lastSignInUnixTime: TimeInterval = Date().timeIntervalSince1970
    
    dynamic var friendState: Int = UserFriendState.stranger.rawValue
    dynamic var friendshipID: String = ""
    dynamic var isBestfriend: Bool = false
    dynamic var bestfriendIndex: Int = 0
    
    var canShowProfile: Bool {
        return friendState != UserFriendState.muma.rawValue
    }
    
    dynamic var longitude: Double = 0
    dynamic var latitude: Double = 0
    
    dynamic var notificationEnabled: Bool = true
    dynamic var blocked: Bool = false
    
    var socialAccountProviders = List<UserSocialAccountProvider>()
    
    let messages = LinkingObjects(fromType: Message.self, property: "fromFriend")
    
    let conversations = LinkingObjects(fromType: Conversation.self, property: "withFriend")
    var conversation: Conversation? {
        return conversations.first
    }
    
    var ownedGroups = LinkingObjects(fromType: Group.self, property: "owner")
    
    var belongsToGroups = LinkingObjects(fromType: Group.self, property: "members")

    var isMe: Bool {
        if let myUserID = MumaUserDefaults.userID.value {
            return userID == myUserID
        }
        
        return false
    }
    
    var mentionedUsername: String? {
        if username.isEmpty {
            return nil
        } else {
            return "@\(username)"
        }
    }
    
    var compositedName: String {
        if username.isEmpty {
            return nickname
        } else {
            return "\(nickname) @\(username)"
        }
    }
    
    // 级联删除关联的数据对象
    
    func cascadeDeleteInRealm(_ realm: Realm) {
        
        socialAccountProviders.forEach({realm.delete($0)})
        
        realm.delete(self)
    }
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.userID.hashValue == rhs.userID.hashValue
}
