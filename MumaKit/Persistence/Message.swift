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
    case noDownload     = 0 // 未下载
    case downloading    = 1 // 下载中
    case downloaded     = 2 // 已下载
}

enum MessageMediaType: Int, CustomStringConvertible {
    case text           = 0
    case image          = 1
    case video          = 2
    case audio          = 3
    case sticker        = 4
    case location       = 5
    case sectionDate    = 6
    case socialWork     = 7
    
    var description: String {
        switch self {
        case .text:
            return "text"
        case .image:
            return "image"
        case .video:
            return "video"
        case .audio:
            return "audio"
        case .sticker:
            return "sticker"
        case .location:
            return "location"
        case .sectionDate:
            return "sectionDate"
        case .socialWork:
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
        case .text:
            return nil
        case .image:
            return NSLocalizedString("[Image]", comment: "")
        case .video:
            return NSLocalizedString("[Video]", comment: "")
        case .audio:
            return NSLocalizedString("[Audio]", comment: "")
        case .sticker:
            return NSLocalizedString("[Sticker]", comment: "")
        case .location:
            return NSLocalizedString("[Location]", comment: "")
        case .socialWork:
            return NSLocalizedString("[Social Work]", comment: "")
        default:
            return NSLocalizedString("All message read", comment: "")
        }
    }
}

enum MessageSendState: Int, CustomStringConvertible {
    case notSend    = 0
    case failed     = 1
    case successed  = 2
    case read       = 3
    
    var description: String {
        get {
            switch self {
            case .notSend:
                return "NotSend"
            case .failed:
                return "Failed"
            case .successed:
                return "Sent"
            case .read:
                return "Read"
            }
        }
    }
}

class MediaMetaData: Object {
    dynamic var data: Data = Data()
    
    var string: String? {
        return String(data: data, encoding: .utf8)
    }
}

class Message: Object {
    dynamic var messageID: String = ""
    
    dynamic var createdUnixTime: TimeInterval = Date().timeIntervalSince1970
    dynamic var updatedUnixTime: TimeInterval = Date().timeIntervalSince1970
    dynamic var arrivalUnixTime: TimeInterval = Date().timeIntervalSince1970
    
    dynamic var mediaType: Int = MessageMediaType.text.rawValue
    
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
    dynamic var attachmentExpiresUnixTime: TimeInterval = Date().timeIntervalSince1970 + (6 * 60 * 60 * 24) // 6天，过期时间s3为7天，客户端防止误差减去1天
    
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
    
    dynamic var downloadState: Int = MessageDownloadState.noDownload.rawValue
    dynamic var sendState: Int = MessageSendState.notSend.rawValue
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
        
        if mediaType == MessageMediaType.sectionDate.rawValue {
            return false
        }
        
        return true
    }
    
    func deleteAttachmentInRealm(_ realm: Realm) {
        
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
    
    func deleteInRealm(_ realm: Realm) {
        deleteAttachmentInRealm(realm)
        realm.delete(self)
    }
    
    func updateForDeletedFromServerInRealm(_ realm: Realm) {
        
        deletedByCreator = true
        
        // 删除附件
        deleteAttachmentInRealm(realm)
        
        // 再将其变为文字消息
        sendState = MessageSendState.read.rawValue
        readed = true
        textContent = "" 
        mediaType = MessageMediaType.text.rawValue
    }
}

class Draft: Object {
    //    dynamic var messageToolbarState: Int = MessageToolbarState.Default.rawValue
    
    dynamic var text: String = ""
}
