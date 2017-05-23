//
//  PlainAvatar.swift
//  Muma
//
//  Created by Binboy on 4/16/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import UIKit
import Navi
import RealmSwift
import MumaKit

private let screenScale = UIScreen.main.scale

struct PlainAvatar {
    
    let avatarURLString: String
    let avatarStyle: AvatarStyle
}

extension PlainAvatar: Navi.Avatar {
    
    var url: Foundation.URL? {
        return Foundation.URL(string: avatarURLString)
    }
    
    var style: AvatarStyle {
        return avatarStyle
    }
    
    var placeholderImage: UIImage? {
        
        switch style {
            
        case miniAvatarStyle:
            return UIImage(named: "default_avatar_60")
            
        case nanoAvatarStyle:
            return UIImage(named: "default_avatar_40")
            
        case picoAvatarStyle:
            return UIImage(named: "default_avatar_30")
            
        default:
            return nil
        }
    }
    
    var localOriginalImage: UIImage? {
        
        if let realm = try? Realm(),
            let avatar = avatarWithAvatarURLString(avatarURLString, inRealm: realm),
            let avatarFileURL = FileManager.mumaAvatarURLWithName(avatar.avatarFileName) {
            return UIImage(contentsOfFile: avatarFileURL.path)
        }
        
        return nil
    }
    
    var localStyledImage: UIImage? {
        
        switch style {
            
        case miniAvatarStyle:
            if let realm = try? Realm(),
                let avatar = avatarWithAvatarURLString(avatarURLString, inRealm: realm) {
                return UIImage(data: avatar.roundMini, scale: screenScale)
            }
            
        case nanoAvatarStyle:
            if let realm = try? Realm(),
                let avatar = avatarWithAvatarURLString(avatarURLString, inRealm: realm) {
                return UIImage(data: avatar.roundNano, scale: screenScale)
            }
            
        default:
            break
        }
        
        return nil
    }
    
    func save(originalImage: UIImage, styledImage: UIImage) {
        
        guard let realm = try? Realm() else {
            return
        }
        
        var _avatar = avatarWithAvatarURLString(avatarURLString, inRealm: realm)
        
        if _avatar == nil {
            
            let newAvatar = Avatar()
            newAvatar.avatarURLString = avatarURLString
            
            let _ = try? realm.write {
                realm.add(newAvatar)
            }
            
            _avatar = newAvatar
        }
        
        guard let avatar = _avatar else {
            return
        }
        
        let avatarFileName = UUID().uuidString
        
        if avatar.avatarFileName.isEmpty, let _ = FileManager.saveAvatarImage(originalImage, withName: avatarFileName) {
            
            let _ = try? realm.write {
                avatar.avatarFileName = avatarFileName
            }
        }
        
        switch style {
            
        case .roundedRectangle(let size, _, _):
            
            switch size.width {
                
            case 60:
                if avatar.roundMini.count == 0, let data = UIImagePNGRepresentation(styledImage) {
                    let _ = try? realm.write {
                        avatar.roundMini = data
                    }
                }
                
            case 40:
                if avatar.roundNano.count == 0, let data = UIImagePNGRepresentation(styledImage) {
                    let _ = try? realm.write {
                        avatar.roundNano = data
                    }
                }
                
            default:
                break
            }
            
        default:
            break
        }
    }
}
