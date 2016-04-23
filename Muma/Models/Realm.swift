//
//  Models.swift
//  Muma
//
//  Created by Binboy on 4/13/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import UIKit
import Parse
import RealmSwift

// Realm 队列，总在这个队列操作模型
let realmQueue = dispatch_queue_create("top.Binboy.realmQueue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, 0))

// MARK: Update with info

func updateUserWithUserID(userID: String, useUserInfo userInfo: JSONDictionary, inRealm realm: Realm) {
    
    if let user = userWithUserID(userID, inRealm: realm) {
        
        // 更新用户信息
        
        if let lastSignInUnixTime = userInfo["last_sign_in_at"] as? NSTimeInterval {
            user.lastSignInUnixTime = lastSignInUnixTime
        }
        
        if let username = userInfo["username"] as? String {
            user.username = username
        }
        
        if let nickname = userInfo["nickname"] as? String {
            user.nickname = nickname
        }
        
        if let introduction = userInfo["introduction"] as? String {
            user.introduction = introduction
        }
        
        if let avatarInfo = userInfo["avatar"] as? JSONDictionary, avatarURLString = avatarInfo["url"] as? String {
            user.avatarURLString = avatarURLString
        }
        
        if let longitude = userInfo["longitude"] as? Double {
            user.longitude = longitude
        }
        
        if let latitude = userInfo["latitude"] as? Double {
            user.latitude = latitude
        }
        
//        if let badge = userInfo["badge"] as? String {
//            user.badge = badge
//        }
        
        // 更新 Social Account Provider
        
        if let providersInfo = userInfo["providers"] as? [String: Bool] {
            
            user.socialAccountProviders.removeAll()
            
            for (name, enabled) in providersInfo {
                let provider = UserSocialAccountProvider()
                provider.name = name
                provider.enabled = enabled
                
                user.socialAccountProviders.append(provider)
            }
        }
    }
}

// MARK: Helpers

func normalFriends() -> Results<User> {
    let realm = try! Realm()
    let predicate = NSPredicate(format: "friendState = %d", UserFriendState.Normal.rawValue)
    return realm.objects(User).filter(predicate).sorted("lastSignInUnixTime", ascending: false)
}

func normalUsers() -> Results<User> {
    let realm = try! Realm()
    let predicate = NSPredicate(format: "friendState != %d", UserFriendState.Blocked.rawValue)
    return realm.objects(User).filter(predicate)
}

func userWithUserID(userID: String, inRealm realm: Realm) -> User? {
    let predicate = NSPredicate(format: "userID = %@", userID)
    
    #if DEBUG
        let users = realm.objects(User).filter(predicate)
        if users.count > 1 {
            println("Warning: same userID: \(users.count), \(userID)")
        }
    #endif
    
    return realm.objects(User).filter(predicate).first
}

func userWithUsername(username: String, inRealm realm: Realm) -> User? {
    let predicate = NSPredicate(format: "username = %@", username)
    return realm.objects(User).filter(predicate).first
}

func userWithAvatarURLString(avatarURLString: String, inRealm realm: Realm) -> User? {
    let predicate = NSPredicate(format: "avatarURLString = %@", avatarURLString)
    return realm.objects(User).filter(predicate).first
}

func groupWithGroupID(groupID: String, inRealm realm: Realm) -> Group? {
    let predicate = NSPredicate(format: "groupID = %@", groupID)
    return realm.objects(Group).filter(predicate).first
}

func filterValidMessages(messages: Results<Message>) -> [Message] {
    let validMessages: [Message] = messages
        .filter({ $0.hidden == false })
        .filter({ $0.deletedByCreator == false })
        .filter({ $0.isReal == true })
        .filter({ !($0.fromFriend?.isMe ?? true)})
        .filter({ $0.conversation != nil })
    
    return validMessages
}

func filterValidMessages(messages: [Message]) -> [Message] {
    let validMessages: [Message] = messages
        .filter({ $0.hidden == false })
        .filter({ $0.deletedByCreator == false })
        .filter({ $0.isReal == true })
        .filter({ !($0.fromFriend?.isMe ?? true)})
        .filter({ $0.conversation != nil })
    
    return validMessages
}

func feedConversationsInRealm(realm: Realm) -> Results<Conversation> {
    let predicate = NSPredicate(format: "withGroup != nil AND withGroup.includeMe = true AND withGroup.groupType = %d", GroupType.Public.rawValue)
    let a = SortDescriptor(property: "mentionedMe", ascending: false)
    let b = SortDescriptor(property: "hasUnreadMessages", ascending: false)
    let c = SortDescriptor(property: "updatedUnixTime", ascending: false)
    return realm.objects(Conversation).filter(predicate).sorted([a, b, c])
}

func mentionedMeInFeedConversationsInRealm(realm: Realm) -> Bool {
    let predicate = NSPredicate(format: "withGroup != nil AND withGroup.includeMe = true AND withGroup.groupType = %d AND mentionedMe = true", GroupType.Public.rawValue)
    return realm.objects(Conversation).filter(predicate).count > 0
}

func countOfConversationsInRealm(realm: Realm) -> Int {
    return realm.objects(Conversation).count
}

func countOfConversationsInRealm(realm: Realm, withConversationType conversationType: ConversationType) -> Int {
    let predicate = NSPredicate(format: "type = %d", conversationType.rawValue)
    return realm.objects(Conversation).filter(predicate).count
}

func countOfUnreadMessagesInRealm(realm: Realm, withConversationType conversationType: ConversationType) -> Int {
    
    switch conversationType {
        
    case .OneToOne:
        let predicate = NSPredicate(format: "readed = false AND fromFriend != nil AND fromFriend.friendState != %d AND conversation != nil AND conversation.type = %d", UserFriendState.Me.rawValue, conversationType.rawValue)
        return realm.objects(Message).filter(predicate).count
        
    case .Group: // Public for now
        let predicate = NSPredicate(format: "includeMe = true AND groupType = %d", GroupType.Public.rawValue)
        let count = realm.objects(Group).filter(predicate).map({ $0.conversation }).flatMap({ $0 }).map({ $0.hasUnreadMessages ? 1 : 0 }).reduce(0, combine: +)
        
        return count
    }
}

func countOfUnreadMessagesInConversation(conversation: Conversation) -> Int {
    
    return conversation.messages.filter({ message in
        if let fromFriend = message.fromFriend {
            return (message.readed == false) && (fromFriend.friendState != UserFriendState.Me.rawValue)
        } else {
            return false
        }
    }).count
}

func latestValidMessageInRealm(realm: Realm, withConversationType conversationType: ConversationType) -> Message? {
    
    switch conversationType {
        
    case .OneToOne:
        let predicate = NSPredicate(format: "hidden = false AND deletedByCreator = false AND mediaType != %d AND fromFriend != nil AND conversation != nil AND conversation.type = %d", MessageMediaType.SocialWork.rawValue, conversationType.rawValue)
        return realm.objects(Message).filter(predicate).sorted("updatedUnixTime", ascending: false).first
        
    case .Group: // Public for now
        let predicate = NSPredicate(format: "withGroup != nil AND withGroup.includeMe = true AND withGroup.groupType = %d", GroupType.Public.rawValue)
        let messages: [Message]? = realm.objects(Conversation).filter(predicate).sorted("updatedUnixTime", ascending: false).first?.messages.sort({ $0.createdUnixTime > $1.createdUnixTime })
        
        return messages?.filter({ ($0.hidden == false) && ($0.deletedByCreator == false) && ($0.mediaType != MessageMediaType.SectionDate.rawValue)}).first
    }
}

//func latestUnreadValidMessageInRealm(realm: Realm, withConversationType conversationType: ConversationType) -> Message? {
//    
//    switch conversationType {
//        
//    case .OneToOne:
//        let predicate = NSPredicate(format: "readed = false AND hidden = false AND deletedByCreator = false AND mediaType != %d AND fromFriend != nil AND conversation != nil AND conversation.type = %d", MessageMediaType.SocialWork.rawValue, conversationType.rawValue)
//        return realm.objects(Message).filter(predicate).sorted("updatedUnixTime", ascending: false).first
//        
//    case .Group: // Public for now
//        let predicate = NSPredicate(format: "withGroup != nil AND withGroup.includeMe = true AND withGroup.groupType = %d", GroupType.Public.rawValue)
//        let messages: [Message]? = realm.objects(Conversation).filter(predicate).sorted("updatedUnixTime", ascending: false).first?.messages.filter({ $0.readed == false && $0.fromFriend?.userID != YepUserDefaults.userID.value }).sort({ $0.createdUnixTime > $1.createdUnixTime })
//        
//        return messages?.filter({ ($0.hidden == false) && ($0.deletedByCreator == false) && ($0.mediaType != MessageMediaType.SectionDate.rawValue) }).first
//    }
//}

func messageWithMessageID(messageID: String, inRealm realm: Realm) -> Message? {
    if messageID.isEmpty {
        return nil
    }
    
    let predicate = NSPredicate(format: "messageID = %@", messageID)
    
    let messages = realm.objects(Message).filter(predicate)
    
    return messages.first
}

func avatarWithAvatarURLString(avatarURLString: String, inRealm realm: Realm) -> Avatar? {
    let predicate = NSPredicate(format: "avatarURLString = %@", avatarURLString)
    return realm.objects(Avatar).filter(predicate).first
}

func tryGetOrCreateMeInRealm(realm: Realm) -> User? {
    if let userID = MumaUserDefaults.userID.value {
        
        if let me = userWithUserID(userID, inRealm: realm) {
            return me
            
        } else {
            
            let me = User()
            
            me.userID = userID
            me.friendState = UserFriendState.Me.rawValue
            
            if let nickname = MumaUserDefaults.nickname.value {
                me.nickname = nickname
            }
            
            if let avatarURLString = MumaUserDefaults.avatarURLString.value {
                me.avatarURLString = avatarURLString
            }
            
            let _ = try? realm.write {
                realm.add(me)
            }
            
            return me
        }
    }
    
    return nil
}

func mediaMetaDataFromString(metaDataString: String, inRealm realm: Realm) -> MediaMetaData? {
    
    if let data = metaDataString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
        let mediaMetaData = MediaMetaData()
        mediaMetaData.data = data
        
        realm.add(mediaMetaData)
        
        return mediaMetaData
    }
    
    return nil
}

func oneToOneConversationsInRealm(realm: Realm) -> Results<Conversation> {
    let predicate = NSPredicate(format: "type = %d", ConversationType.OneToOne.rawValue)
    return realm.objects(Conversation).filter(predicate).sorted("updatedUnixTime", ascending: false)
}

func messagesInConversationFromFriend(conversation: Conversation) -> Results<Message> {
    
    let predicate = NSPredicate(format: "conversation = %@ AND fromFriend.friendState != %d", argumentArray: [conversation, UserFriendState.Me.rawValue])
    
    if let realm = conversation.realm {
        return realm.objects(Message).filter(predicate).sorted("createdUnixTime", ascending: true)
        
    } else {
        let realm = try! Realm()
        return realm.objects(Message).filter(predicate).sorted("createdUnixTime", ascending: true)
    }
}

func messagesInConversation(conversation: Conversation) -> Results<Message> {
    
    let predicate = NSPredicate(format: "conversation = %@", argumentArray: [conversation])
    
    if let realm = conversation.realm {
        return realm.objects(Message).filter(predicate).sorted("createdUnixTime", ascending: true)
        
    } else {
        let realm = try! Realm()
        return realm.objects(Message).filter(predicate).sorted("createdUnixTime", ascending: true)
    }
}

func messagesOfConversation(conversation: Conversation, inRealm realm: Realm) -> Results<Message> {
    let predicate = NSPredicate(format: "conversation = %@ AND hidden = false", argumentArray: [conversation])
    let messages = realm.objects(Message).filter(predicate).sorted("createdUnixTime", ascending: true)
    return messages
}

func handleMessageDeletedFromServer(messageID messageID: String) {
    
    guard let
        realm = try? Realm(),
        message = messageWithMessageID(messageID, inRealm: realm)
        else {
            return
    }
    
    let _ = try? realm.write {
        message.updateForDeletedFromServerInRealm(realm)
    }
    
//    let messageIDs: [String] = [message.messageID]
    
//    dispatch_async(dispatch_get_main_queue()) {
//        NSNotificationCenter.defaultCenter().postNotificationName(YepConfig.Notification.deletedMessages, object: ["messageIDs": messageIDs])
//    }
}
func nameOfConversation(conversation: Conversation) -> String? {
    
    guard !conversation.invalidated else {
        return nil
    }
    
    if conversation.type == ConversationType.OneToOne.rawValue {
        if let withFriend = conversation.withFriend {
            return withFriend.nickname
        }
        
    } else if conversation.type == ConversationType.Group.rawValue {
        if let withGroup = conversation.withGroup {
            return withGroup.groupName
        }
    }
    
    return nil
}

func lastChatDateOfConversation(conversation: Conversation) -> NSDate? {
    
    guard !conversation.invalidated else {
        return nil
    }
    
    let messages = messagesInConversation(conversation)
    
    if let lastMessage = messages.last {
        return NSDate(timeIntervalSince1970: lastMessage.createdUnixTime)
    }
    
    return nil
}

func lastSignDateOfConversation(conversation: Conversation) -> NSDate? {
    
    guard !conversation.invalidated else {
        return nil
    }
    
    let messages = messagesInConversationFromFriend(conversation)
    
    if let
        lastMessage = messages.last,
        user = lastMessage.fromFriend {
        return NSDate(timeIntervalSince1970: user.lastSignInUnixTime)
    }
    
    return nil
}

//func blurredThumbnailImageOfMessage(message: Message) -> UIImage? {
//    
//    guard !message.invalidated else {
//        return nil
//    }
//    
//    if let mediaMetaData = message.mediaMetaData {
//        if let metaDataInfo = decodeJSON(mediaMetaData.data) {
//            if let blurredThumbnailString = metaDataInfo[YepConfig.MetaData.blurredThumbnailString] as? String {
//                if let data = NSData(base64EncodedString: blurredThumbnailString, options: NSDataBase64DecodingOptions(rawValue: 0)) {
//                    return UIImage(data: data)
//                }
//            }
//        }
//    }
//    
//    return nil
//}

//func audioMetaOfMessage(message: Message) -> (duration: Double, samples: [CGFloat])? {
//    
//    guard !message.invalidated else {
//        return nil
//    }
//    
//    if let mediaMetaData = message.mediaMetaData {
//        if let metaDataInfo = decodeJSON(mediaMetaData.data) {
//            if let
//                duration = metaDataInfo[YepConfig.MetaData.audioDuration] as? Double,
//                samples = metaDataInfo[YepConfig.MetaData.audioSamples] as? [CGFloat] {
//                return (duration, samples)
//            }
//        }
//    }
//    
//    return nil
//}

//func imageMetaOfMessage(message: Message) -> (width: CGFloat, height: CGFloat)? {
//    
//    guard !message.invalidated else {
//        return nil
//    }
//    
//    if let mediaMetaData = message.mediaMetaData {
//        if let metaDataInfo = decodeJSON(mediaMetaData.data) {
//            if let
//                width = metaDataInfo[YepConfig.MetaData.imageWidth] as? CGFloat,
//                height = metaDataInfo[YepConfig.MetaData.imageHeight] as? CGFloat {
//                return (width, height)
//            }
//        }
//    }
//    
//    return nil
//}
//
//func videoMetaOfMessage(message: Message) -> (width: CGFloat, height: CGFloat)? {
//    
//    guard !message.invalidated else {
//        return nil
//    }
//    
//    if let mediaMetaData = message.mediaMetaData {
//        if let metaDataInfo = decodeJSON(mediaMetaData.data) {
//            if let
//                width = metaDataInfo[YepConfig.MetaData.videoWidth] as? CGFloat,
//                height = metaDataInfo[YepConfig.MetaData.videoHeight] as? CGFloat {
//                return (width, height)
//            }
//        }
//    }
//    
//    return nil
//}

// MARK: Delete

private func clearMessagesOfConversation(conversation: Conversation, inRealm realm: Realm, keepHiddenMessages: Bool) {
    
    let messages: [Message]
    if keepHiddenMessages {
        messages = conversation.messages.filter({ $0.hidden == false })
    } else {
        messages = conversation.messages
    }
    
    // delete attachments of messages
    
    messages.forEach { $0.deleteAttachmentInRealm(realm) }
    
    // delete all messages in conversation
    
    realm.delete(messages)
}

func deleteConversation(conversation: Conversation, inRealm realm: Realm, needLeaveGroup: Bool = true, afterLeaveGroup: (() -> Void)? = nil) {
    
    clearMessagesOfConversation(conversation, inRealm: realm, keepHiddenMessages: false)
    
    // delete conversation, finally
    
    if let group = conversation.withGroup {
        
//        if let feed = conversation.withGroup?.withFeed {
//            
//            feed.cascadeDeleteInRealm(realm)
//        }
        
//        let groupID = group.groupID
        
//        FayeService.sharedManager.unsubscribeGroup(groupID: groupID)
        
//        if needLeaveGroup {
//            leaveGroup(groupID: groupID, failureHandler: nil, completion: {
//                println("leaved group: \(groupID)")
//                
//                afterLeaveGroup?()
//            })
//        } else {
//            print("deleteConversation, not need leave group: \(groupID)")
//        }
        
        realm.delete(group)
    }
    
    realm.delete(conversation)
}

func tryDeleteOrClearHistoryOfConversation(conversation: Conversation, inViewController vc: UIViewController, whenAfterClearedHistory afterClearedHistory: () -> Void, afterDeleted: () -> Void, orCanceled cancelled: () -> Void) {
    
    guard let realm = conversation.realm else {
        cancelled()
        return
    }
    
    let clearMessages: () -> Void = {
        realm.beginWrite()
        clearMessagesOfConversation(conversation, inRealm: realm, keepHiddenMessages: true)
        let _ = try? realm.commitWrite()
    }
    
    let delete: () -> Void = {
        realm.beginWrite()
        deleteConversation(conversation, inRealm: realm)
        let _ = try? realm.commitWrite()
    }
    
    // show ActionSheet before delete
    
    let deleteAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    
    let clearHistoryAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Clear history", comment: ""), style: .Default) { _ in
        
        clearMessages()
        
        afterClearedHistory()
    }
    deleteAlertController.addAction(clearHistoryAction)
    
    let deleteAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .Destructive) { _ in
        
        delete()
        
        afterDeleted()
    }
    deleteAlertController.addAction(deleteAction)
    
    let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel) { _ in
        
        cancelled()
    }
    deleteAlertController.addAction(cancelAction)
    
    vc.presentViewController(deleteAlertController, animated: true, completion: nil)
}

func clearUselessRealmObjects() {
    
    dispatch_async(realmQueue) {
        
        guard let realm = try? Realm() else {
            return
        }
        
        print("do clearUselessRealmObjects")
        
        realm.beginWrite()
        
        // Message
        
        do {
            // 7天前
            let oldThresholdUnixTime = NSDate(timeIntervalSinceNow: -(60 * 60 * 24 * 7)).timeIntervalSince1970
            //let oldThresholdUnixTime = NSDate(timeIntervalSinceNow: 0).timeIntervalSince1970 // for test
            
            let predicate = NSPredicate(format: "createdUnixTime < %f", oldThresholdUnixTime)
            let oldMessages = realm.objects(Message).filter(predicate)
            
            print("oldMessages.count: \(oldMessages.count)")
            
            oldMessages.forEach({
                $0.deleteAttachmentInRealm(realm)
                realm.delete($0)
            })
        }
        
        // Feed
        
//        do {
//            let predicate = NSPredicate(format: "group == nil")
//            let noGroupFeeds = realm.objects(Feed).filter(predicate)
//            
//            println("noGroupFeeds.count: \(noGroupFeeds.count)")
//            
//            noGroupFeeds.forEach({
//                if let group = $0.group {
//                    group.cascadeDeleteInRealm(realm)
//                } else {
//                    $0.cascadeDeleteInRealm(realm)
//                }
//            })
//        }
        
//        do {
//            // 2天前
//            let oldThresholdUnixTime = NSDate(timeIntervalSinceNow: -(60 * 60 * 24 * 2)).timeIntervalSince1970
//            let oldThresholdUnixTime = NSDate(timeIntervalSinceNow: 0).timeIntervalSince1970 // for test
//            
//            let predicate = NSPredicate(format: "group != nil AND group.includeMe = false AND createdUnixTime < %f", oldThresholdUnixTime)
//            let notJoinedFeeds = realm.objects(Feed).filter(predicate)
//            
//            println("notJoinedFeeds.count: \(notJoinedFeeds.count)")
//            
//            notJoinedFeeds.forEach({
//                if let group = $0.group {
//                    group.cascadeDeleteInRealm(realm)
//                } else {
//                    $0.cascadeDeleteInRealm(realm)
//                }
//            })
//        }
        
        // User
        
        do {
            // 7天前
            let oldThresholdUnixTime = NSDate(timeIntervalSinceNow: -(60 * 60 * 24 * 7)).timeIntervalSince1970
            //let oldThresholdUnixTime = NSDate(timeIntervalSinceNow: 0).timeIntervalSince1970 // for test
            let predicate = NSPredicate(format: "friendState == %d AND createdUnixTime < %f", UserFriendState.Stranger.rawValue, oldThresholdUnixTime)
            //let predicate = NSPredicate(format: "friendState == %d ", UserFriendState.Stranger.rawValue)
            
            let strangers = realm.objects(User).filter(predicate)
            
            // 再仔细过滤，避免把需要的去除了（参与对话的，有Group的，Feed创建着，关联有消息的）
            let realStrangers = strangers.filter({
                if $0.conversation == nil && $0.belongsToGroups.isEmpty && $0.ownedGroups.isEmpty && $0.messages.isEmpty {
                    return true
                }
                
                return false
            })
            
            print("realStrangers.count: \(realStrangers.count)")
            
            realStrangers.forEach({
                $0.cascadeDeleteInRealm(realm)
            })
        }
        
        // Group
        
        let _ = try? realm.commitWrite()
    }
}