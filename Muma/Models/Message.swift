//
//  Message.swift
//  Muma
//
//  Created by Binboy on 4/13/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import Foundation
import RealmSwift

enum MessageDownloadState: Int {
    case NoDownload     = 0 // 未下载
    case Downloading    = 1 // 下载中
    case Downloaded     = 2 // 已下载
}

enum MessageMediaType: Int, CustomStringConvertible {
    case Text           = 0
    case Image          = 1
    case Video          = 2
    case Audio          = 3
    case Sticker        = 4
    case Location       = 5
    case SectionDate    = 6
    case SocialWork     = 7
    
    var description: String {
        switch self {
        case .Text:
            return "text"
        case .Image:
            return "image"
        case .Video:
            return "video"
        case .Audio:
            return "audio"
        case .Sticker:
            return "sticker"
        case .Location:
            return "location"
        case .SectionDate:
            return "sectionDate"
        case .SocialWork:
            return "socialWork"
        }
    }
    
    //    var fileExtension: FileExtension? {
    //        switch self {
    //        case .Image:
    //            return .JPEG
    //        case .Video:
    //            return .MP4
    //        case .Audio:
    //            return .M4A
    //        default:
    //            return nil // TODO: more
    //        }
    //    }
    
    var placeholder: String? {
        switch self {
        case .Text:
            return nil
        case .Image:
            return NSLocalizedString("[Image]", comment: "")
        case .Video:
            return NSLocalizedString("[Video]", comment: "")
        case .Audio:
            return NSLocalizedString("[Audio]", comment: "")
        case .Sticker:
            return NSLocalizedString("[Sticker]", comment: "")
        case .Location:
            return NSLocalizedString("[Location]", comment: "")
        case .SocialWork:
            return NSLocalizedString("[Social Work]", comment: "")
        default:
            return NSLocalizedString("All message read", comment: "")
        }
    }
}

enum MessageSendState: Int, CustomStringConvertible {
    case NotSend    = 0
    case Failed     = 1
    case Successed  = 2
    case Read       = 3
    
    var description: String {
        get {
            switch self {
            case NotSend:
                return "NotSend"
            case Failed:
                return "Failed"
            case Successed:
                return "Sent"
            case Read:
                return "Read"
            }
        }
    }
}

class MediaMetaData: Object {
    dynamic var data: NSData = NSData()
    
    var string: String? {
        return NSString(data: data, encoding: NSUTF8StringEncoding) as? String
    }
}

class Message: Object {
    dynamic var messageID: String = ""
    
    dynamic var createdUnixTime: NSTimeInterval = NSDate().timeIntervalSince1970
    dynamic var updatedUnixTime: NSTimeInterval = NSDate().timeIntervalSince1970
    dynamic var arrivalUnixTime: NSTimeInterval = NSDate().timeIntervalSince1970
    
    dynamic var mediaType: Int = MessageMediaType.Text.rawValue
    
    dynamic var textContent: String = ""
    
    // 消息撤回
    var recalledTextContent: String {
        let nickname = fromFriend?.nickname ?? ""
        return String(format: NSLocalizedString("%@ recalled a message.", comment: ""), nickname)
    }
    
    dynamic var openGraphDetected: Bool = false
    //    dynamic var openGraphInfo: OpenGraphInfo?
    
    //    dynamic var coordinate: Coordinate?
    
    dynamic var attachmentURLString: String = ""
    dynamic var localAttachmentName: String = ""
    dynamic var thumbnailURLString: String = ""
    dynamic var localThumbnailName: String = ""
    dynamic var attachmentID: String = ""
    dynamic var attachmentExpiresUnixTime: NSTimeInterval = NSDate().timeIntervalSince1970 + (6 * 60 * 60 * 24) // 6天，过期时间s3为7天，客户端防止误差减去1天
    
    var imageKey: String {
        return "image-\(messageID)-\(localAttachmentName)-\(attachmentURLString)"
    }
    
    var nicknameWithTextContent: String {
        if let nickname = fromFriend?.nickname {
            return String(format: NSLocalizedString("%@: %@", comment: ""), nickname, textContent)
        } else {
            return textContent
        }
    }
    
    //    var thumbnailImage: UIImage? {
    //        switch mediaType {
    //        case MessageMediaType.Image.rawValue:
    //            if let imageFileURL = NSFileManager.yepMessageImageURLWithName(localAttachmentName) {
    //                return UIImage(contentsOfFile: imageFileURL.path!)
    //            }
    //        case MessageMediaType.Video.rawValue:
    //            if let imageFileURL = NSFileManager.yepMessageImageURLWithName(localThumbnailName) {
    //                return UIImage(contentsOfFile: imageFileURL.path!)
    //            }
    //        default:
    //            return nil
    //        }
    //        return nil
    //    }
    
    dynamic var mediaMetaData: MediaMetaData?
    
    //    dynamic var socialWork: MessageSocialWork?
    
    dynamic var downloadState: Int = MessageDownloadState.NoDownload.rawValue
    dynamic var sendState: Int = MessageSendState.NotSend.rawValue
    dynamic var readed: Bool = false
    dynamic var mediaPlayed: Bool = false // 音频播放过，图片查看过等
    dynamic var hidden: Bool = false // 隐藏对方消息，使之不再显示
    dynamic var deletedByCreator: Bool = false
    
    dynamic var fromFriend: User?
    dynamic var conversation: Conversation?
    
    var isReal: Bool {
        
        //        if socialWork != nil {
        //            return false
        //        }
        
        if mediaType == MessageMediaType.SectionDate.rawValue {
            return false
        }
        
        return true
    }
    
    func deleteAttachmentInRealm(realm: Realm) {
        
        if let mediaMetaData = mediaMetaData {
            realm.delete(mediaMetaData)
        }
        
        // 除非没有谁指向 openGraphInfo，不然不能删除它
        //        if let openGraphInfo = openGraphInfo {
        //            if openGraphInfo.feeds.isEmpty {
        //                if openGraphInfo.messages.count == 1, let first = openGraphInfo.messages.first where first == self {
        //                    realm.delete(openGraphInfo)
        //                }
        //            }
        //        }
        
        //        switch mediaType {
        //
        //        case MessageMediaType.Image.rawValue:
        //            NSFileManager.removeMessageImageFileWithName(localAttachmentName)
        //
        //        case MessageMediaType.Video.rawValue:
        //            NSFileManager.removeMessageVideoFilesWithName(localAttachmentName, thumbnailName: localThumbnailName)
        //
        //        case MessageMediaType.Audio.rawValue:
        //            NSFileManager.removeMessageAudioFileWithName(localAttachmentName)
        //
        //        case MessageMediaType.Location.rawValue:
        //            NSFileManager.removeMessageImageFileWithName(localAttachmentName)
        //
        //        case MessageMediaType.SocialWork.rawValue:
        //
        //            if let socialWork = socialWork {
        //
        //                if let githubRepo = socialWork.githubRepo {
        //                    realm.delete(githubRepo)
        //                }
        //
        //                if let dribbbleShot = socialWork.dribbbleShot {
        //                    realm.delete(dribbbleShot)
        //                }
        //
        //                if let instagramMedia = socialWork.instagramMedia {
        //                    realm.delete(instagramMedia)
        //                }
        //
        //                realm.delete(socialWork)
        //            }
        //
        //        default:
        //            break // TODO: if have other message media need to delete
        //        }
    }
    
    func deleteInRealm(realm: Realm) {
        deleteAttachmentInRealm(realm)
        realm.delete(self)
    }
    
    func updateForDeletedFromServerInRealm(realm: Realm) {
        
        deletedByCreator = true
        
        // 删除附件
        deleteAttachmentInRealm(realm)
        
        // 再将其变为文字消息
        sendState = MessageSendState.Read.rawValue
        readed = true
        textContent = "" 
        mediaType = MessageMediaType.Text.rawValue
    }
}

class Draft: Object {
    //    dynamic var messageToolbarState: Int = MessageToolbarState.Default.rawValue
    
    dynamic var text: String = ""
}
