//
//  NSFileManager+Muma.swift
//  Muma
//
//  Created by Binboy on 4/15/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import UIKit

enum FileExtension: String {
    case JPEG = "jpg"
    case MP4 = "mp4"
    case M4A = "m4a"
    
    var mimeType: String {
        switch self {
        case .JPEG:
            return "image/jpeg"
        case .MP4:
            return "video/mp4"
        case .M4A:
            return "audio/m4a"
        }
    }
}

extension NSFileManager {
    
    class func mumaCachesURL() -> NSURL {
        return try! NSFileManager.defaultManager().URLForDirectory(.CachesDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
    }
    
    // MARK: Avatar
    
    class func mumaAvatarCachesURL() -> NSURL? {
        
        let fileManager = NSFileManager.defaultManager()
        
        let avatarCachesURL = mumaCachesURL().URLByAppendingPathComponent("avatar_caches", isDirectory: true)
        
        do {
            try fileManager.createDirectoryAtURL(avatarCachesURL, withIntermediateDirectories: true, attributes: nil)
            return avatarCachesURL
        } catch _ {
        }
        
        return nil
    }
    
    class func mumaAvatarURLWithName(name: String) -> NSURL? {
        
        if let avatarCachesURL = mumaAvatarCachesURL() {
            return avatarCachesURL.URLByAppendingPathComponent("\(name).\(FileExtension.JPEG.rawValue)")
        }
        
        return nil
    }
    
    class func saveAvatarImage(avatarImage: UIImage, withName name: String) -> NSURL? {
        
        if let avatarURL = mumaAvatarURLWithName(name) {
            let imageData = UIImageJPEGRepresentation(avatarImage, 0.8)
            if NSFileManager.defaultManager().createFileAtPath(avatarURL.path!, contents: imageData, attributes: nil) {
                return avatarURL
            }
        }
        
        return nil
    }
    
    class func deleteAvatarImageWithName(name: String) {
        if let avatarURL = mumaAvatarURLWithName(name) {
            do {
                try NSFileManager.defaultManager().removeItemAtURL(avatarURL)
            } catch _ {
            }
        }
    }
    
    // MARK: Message
    
    class func mumaMessageCachesURL() -> NSURL? {
        
        let fileManager = NSFileManager.defaultManager()
        
        let messageCachesURL = mumaCachesURL().URLByAppendingPathComponent("message_caches", isDirectory: true)
        
        do {
            try fileManager.createDirectoryAtURL(messageCachesURL, withIntermediateDirectories: true, attributes: nil)
            return messageCachesURL
        } catch _ {
        }
        
        return nil
    }
    
    // Image
    
    class func mumaMessageImageURLWithName(name: String) -> NSURL? {
        
        if let messageCachesURL = mumaMessageCachesURL() {
            return messageCachesURL.URLByAppendingPathComponent("\(name).\(FileExtension.JPEG.rawValue)")
        }
        
        return nil
    }
    
    class func saveMessageImageData(messageImageData: NSData, withName name: String) -> NSURL? {
        
        if let messageImageURL = mumaMessageImageURLWithName(name) {
            if NSFileManager.defaultManager().createFileAtPath(messageImageURL.path!, contents: messageImageData, attributes: nil) {
                return messageImageURL
            }
        }
        
        return nil
    }
    
    class func removeMessageImageFileWithName(name: String) {
        
        if name.isEmpty {
            return
        }
        
        if let messageImageURL = mumaMessageImageURLWithName(name) {
            do {
                try NSFileManager.defaultManager().removeItemAtURL(messageImageURL)
            } catch _ {
            }
        }
    }
    
    // Audio
    
    class func mumaMessageAudioURLWithName(name: String) -> NSURL? {
        
        if let messageCachesURL = mumaMessageCachesURL() {
            return messageCachesURL.URLByAppendingPathComponent("\(name).\(FileExtension.M4A.rawValue)")
        }
        
        return nil
    }
    
    class func saveMessageAudioData(messageAudioData: NSData, withName name: String) -> NSURL? {
        
        if let messageAudioURL = mumaMessageAudioURLWithName(name) {
            if NSFileManager.defaultManager().createFileAtPath(messageAudioURL.path!, contents: messageAudioData, attributes: nil) {
                return messageAudioURL
            }
        }
        
        return nil
    }
    
    class func removeMessageAudioFileWithName(name: String) {
        
        if name.isEmpty {
            return
        }
        
        if let messageAudioURL = mumaMessageAudioURLWithName(name) {
            do {
                try NSFileManager.defaultManager().removeItemAtURL(messageAudioURL)
            } catch _ {
            }
        }
    }
    
    // Video
    
    class func mumaMessageVideoURLWithName(name: String) -> NSURL? {
        
        if let messageCachesURL = mumaMessageCachesURL() {
            return messageCachesURL.URLByAppendingPathComponent("\(name).\(FileExtension.MP4.rawValue)")
        }
        
        return nil
    }
    
    class func saveMessageVideoData(messageVideoData: NSData, withName name: String) -> NSURL? {
        
        if let messageVideoURL = mumaMessageVideoURLWithName(name) {
            if NSFileManager.defaultManager().createFileAtPath(messageVideoURL.path!, contents: messageVideoData, attributes: nil) {
                return messageVideoURL
            }
        }
        
        return nil
    }
    
    class func removeMessageVideoFilesWithName(name: String, thumbnailName: String) {
        
        if !name.isEmpty {
            if let messageVideoURL = mumaMessageVideoURLWithName(name) {
                do {
                    try NSFileManager.defaultManager().removeItemAtURL(messageVideoURL)
                } catch _ {
                }
            }
        }
        
        if !thumbnailName.isEmpty {
            if let messageImageURL = mumaMessageImageURLWithName(thumbnailName) {
                do {
                    try NSFileManager.defaultManager().removeItemAtURL(messageImageURL)
                } catch _ {
                }
            }
        }
    }
    
    // MARK: Clean Caches
    
    class func cleanCachesDirectoryAtURL(cachesDirectoryURL: NSURL) {
        let fileManager = NSFileManager.defaultManager()
        
        if let fileURLs = (try? fileManager.contentsOfDirectoryAtURL(cachesDirectoryURL, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions())) {
            for fileURL in fileURLs {
                do {
                    try fileManager.removeItemAtURL(fileURL)
                } catch _ {
                }
            }
        }
    }
    
    class func cleanAvatarCaches() {
        if let avatarCachesURL = mumaAvatarCachesURL() {
            cleanCachesDirectoryAtURL(avatarCachesURL)
        }
    }
    
    class func cleanMessageCaches() {
        if let messageCachesURL = mumaMessageCachesURL() {
            cleanCachesDirectoryAtURL(messageCachesURL)
        }
    }
}
