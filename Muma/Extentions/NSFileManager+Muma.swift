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

extension FileManager {
    
    class func mumaCachesURL() -> URL {
        return try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }
    
    // MARK: Avatar
    
    class func mumaAvatarCachesURL() -> URL? {
        
        let fileManager = FileManager.default
        
        let avatarCachesURL = mumaCachesURL().appendingPathComponent("avatar_caches", isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: avatarCachesURL, withIntermediateDirectories: true, attributes: nil)
            return avatarCachesURL
        } catch _ {
        }
        
        return nil
    }
    
    class func mumaAvatarURLWithName(_ name: String) -> URL? {
        
        if let avatarCachesURL = mumaAvatarCachesURL() {
            return avatarCachesURL.appendingPathComponent("\(name).\(FileExtension.JPEG.rawValue)")
        }
        
        return nil
    }
    
    class func saveAvatarImage(_ avatarImage: UIImage, withName name: String) -> URL? {
        
        if let avatarURL = mumaAvatarURLWithName(name) {
            let imageData = UIImageJPEGRepresentation(avatarImage, 0.8)
            if FileManager.default.createFile(atPath: avatarURL.path, contents: imageData, attributes: nil) {
                return avatarURL
            }
        }
        
        return nil
    }
    
    class func deleteAvatarImageWithName(_ name: String) {
        if let avatarURL = mumaAvatarURLWithName(name) {
            do {
                try FileManager.default.removeItem(at: avatarURL)
            } catch _ {
            }
        }
    }
    
    // MARK: Message
    
    class func mumaMessageCachesURL() -> URL? {
        
        let fileManager = FileManager.default
        
        let messageCachesURL = mumaCachesURL().appendingPathComponent("message_caches", isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: messageCachesURL, withIntermediateDirectories: true, attributes: nil)
            return messageCachesURL
        } catch _ {
        }
        
        return nil
    }
    
    // MARK: Image
    
    class func mumaMessageImageURLWithName(_ name: String) -> URL? {
        
        if let messageCachesURL = mumaMessageCachesURL() {
            return messageCachesURL.appendingPathComponent("\(name).\(FileExtension.JPEG.rawValue)")
        }
        
        return nil
    }
    
    class func saveMessageImageData(_ messageImageData: Data, withName name: String) -> URL? {
        
        if let messageImageURL = mumaMessageImageURLWithName(name) {
            if FileManager.default.createFile(atPath: messageImageURL.path, contents: messageImageData, attributes: nil) {
                return messageImageURL
            }
        }
        
        return nil
    }
    
    class func removeMessageImageFileWithName(_ name: String) {
        
        if name.isEmpty {
            return
        }
        
        if let messageImageURL = mumaMessageImageURLWithName(name) {
            do {
                try FileManager.default.removeItem(at: messageImageURL)
            } catch _ {
            }
        }
    }
    
    // MARK: Audio
    
    class func mumaMessageAudioURLWithName(_ name: String) -> URL? {
        
        if let messageCachesURL = mumaMessageCachesURL() {
            return messageCachesURL.appendingPathComponent("\(name).\(FileExtension.M4A.rawValue)")
        }
        
        return nil
    }
    
    class func saveMessageAudioData(_ messageAudioData: Data, withName name: String) -> URL? {
        
        if let messageAudioURL = mumaMessageAudioURLWithName(name) {
            if FileManager.default.createFile(atPath: messageAudioURL.path, contents: messageAudioData, attributes: nil) {
                return messageAudioURL
            }
        }
        
        return nil
    }
    
    class func removeMessageAudioFileWithName(_ name: String) {
        
        if name.isEmpty {
            return
        }
        
        if let messageAudioURL = mumaMessageAudioURLWithName(name) {
            do {
                try FileManager.default.removeItem(at: messageAudioURL)
            } catch _ {
            }
        }
    }
    
    // MARK: Video
    
    class func mumaMessageVideoURLWithName(_ name: String) -> URL? {
        
        if let messageCachesURL = mumaMessageCachesURL() {
            return messageCachesURL.appendingPathComponent("\(name).\(FileExtension.MP4.rawValue)")
        }
        
        return nil
    }
    
    class func saveMessageVideoData(_ messageVideoData: Data, withName name: String) -> URL? {
        
        if let messageVideoURL = mumaMessageVideoURLWithName(name) {
            if FileManager.default.createFile(atPath: messageVideoURL.path, contents: messageVideoData, attributes: nil) {
                return messageVideoURL
            }
        }
        
        return nil
    }
    
    class func removeMessageVideoFilesWithName(_ name: String, thumbnailName: String) {
        
        if !name.isEmpty {
            if let messageVideoURL = mumaMessageVideoURLWithName(name) {
                do {
                    try FileManager.default.removeItem(at: messageVideoURL)
                } catch _ {
                }
            }
        }
        
        if !thumbnailName.isEmpty {
            if let messageImageURL = mumaMessageImageURLWithName(thumbnailName) {
                do {
                    try FileManager.default.removeItem(at: messageImageURL)
                } catch _ {
                }
            }
        }
    }
    
    // MARK: Clean Caches
    
    class func cleanCachesDirectoryAtURL(_ cachesDirectoryURL: URL) {
        let fileManager = FileManager.default
        
        if let fileURLs = (try? fileManager.contentsOfDirectory(at: cachesDirectoryURL, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions())) {
            for fileURL in fileURLs {
                do {
                    try fileManager.removeItem(at: fileURL)
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
