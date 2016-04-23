//
//  User.swift
//  Muma
//
//  Created by Binboy on 4/13/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import Foundation
import RealmSwift
import Parse

enum UserFriendState: Int {
    case Stranger      = 0   // 陌生人
    case IssuedRequest = 1   // 已发出好友请求
    case Normal        = 2   // 正常状态的好友
    case Blocked       = 3   // 被屏蔽
    case Me            = 4   // 自己
    case Muma          = 5   // 官方账号
}

class Avatar: Object {
    dynamic var avatarURLString: String = ""
    dynamic var avatarFileName: String = ""
    
    dynamic var roundMini: NSData = NSData() // 60
    dynamic var roundNano: NSData = NSData() // 40
    
    var user: User? {
        let users = linkingObjects(User.self, forProperty: "avatar")
        return users.first
    }
}

//class Avatar: PFObject {
//    dynamic var avatarURLString: String = ""
//    dynamic var avatarFileName: String = ""
//
//    dynamic var roundMini: NSData = NSData() // 60
//    dynamic var roundNano: NSData = NSData() // 40
//    
//    override var parseClassName: String {
//        return "Avatar"
//    }
//}

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
    //    dynamic var badge: String = "" ???
    
    override class func indexedProperties() -> [String] {
        return ["userID"]
    }
    
    dynamic var createdUnixTime: NSTimeInterval = NSDate().timeIntervalSince1970
    dynamic var lastSignInUnixTime: NSTimeInterval = NSDate().timeIntervalSince1970
    
    dynamic var friendState: Int = UserFriendState.Stranger.rawValue
    dynamic var friendshipID: String = ""
    dynamic var isBestfriend: Bool = false
    dynamic var bestfriendIndex: Int = 0
    
    var canShowProfile: Bool {
        return friendState != UserFriendState.Muma.rawValue
    }
    
    dynamic var longitude: Double = 0
    dynamic var latitude: Double = 0
    
    dynamic var notificationEnabled: Bool = true
    dynamic var blocked: Bool = false
    
    var socialAccountProviders = List<UserSocialAccountProvider>()
    
    var messages: [Message] {
        return linkingObjects(Message.self, forProperty: "fromFriend")
    }
    
    var conversation: Conversation? {
        let conversations = linkingObjects(Conversation.self, forProperty: "withFriend")
        return conversations.first
    }
    
    var ownedGroups: [Group] {
        return linkingObjects(Group.self, forProperty: "owner")
    }
    
    var belongsToGroups: [Group] {
        return linkingObjects(Group.self, forProperty: "members")
    }
    
    //    var createdFeeds: [Feed] {
    //        return linkingObjects(Feed.self, forProperty: "creator")
    //    }
    
    var isMe: Bool {
        //        if let myUserID = MomaUserDefaults.userID.value {
        //            return userID == myUserID
        //        }
        
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
    
    func cascadeDeleteInRealm(realm: Realm) {
        
        socialAccountProviders.forEach({realm.delete($0)})
        
        realm.delete(self)
    }
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

extension User: Hashable {
    
    override var hashValue: Int {
        return userID.hashValue
    }
}
