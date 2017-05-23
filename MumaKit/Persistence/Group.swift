//
//  Group.swift
//  Muma
//
//  Created by Binboy on 4/13/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import Foundation
import RealmSwift

// Group 类型，注意：上线后若要调整，只能增加新状态
enum GroupType: Int {
    case `public`     = 0
    case `private`    = 1
}

public class Group: Object {
    dynamic var groupID: String = ""
    dynamic var groupName: String = ""
    dynamic var notificationEnabled: Bool = true
    dynamic var createdUnixTime: TimeInterval = Date().timeIntervalSince1970
    
    dynamic var owner: User?
    var members = List<User>()
    
    dynamic var groupType: Int = GroupType.private.rawValue
    
    //    dynamic var withFeed: Feed?
    
    dynamic var includeMe: Bool = false
    
    let conversations = LinkingObjects(fromType: Conversation.self, property: "withGroup")
    var conversation: Conversation? {
        return conversations.first
    }
    
    // 级联删除关联的数据对象
    
    func cascadeDeleteInRealm(_ realm: Realm) {
        
        //        withFeed?.cascadeDeleteInRealm(realm)
        
        //        if let conversation = conversation {
        //            realm.delete(conversation)
        //
        //            dispatch_async(dispatch_get_main_queue()) {
        //                NSNotificationCenter.defaultCenter().postNotificationName(YepConfig.Notification.changedConversation, object: nil)
        //            }
        //        }
        
        realm.delete(self)
    }
}
