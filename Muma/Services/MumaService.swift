//
//  ZPAPIServiceClient.swift
//  ZealPlus
//
//  Created by FellowPlus-Binboy on 1/12/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import Foundation
import Alamofire

let mumaBaseURL = NSURL(string: "http://binboy.top/api")!
let fayeBaseURL = NSURL(string: "ws://133.130.118.63:8000/faye")!

// Models
struct LoginUser: CustomStringConvertible {
    let accessToken: String
    let userID: String
    let username: String?
    let nickname: String
    let avatarURLString: String?
    let pusherID: String
    
    var description: String {
        return "LoginUser(accessToken: \(accessToken), userID: \(userID), nickname: \(nickname), avatarURLString: \(avatarURLString), \(pusherID))"
    }
}

func saveTokenAndUserInfoOfLoginUser(loginUser: LoginUser) {
    MumaUserDefaults.userID.value = loginUser.userID
    MumaUserDefaults.nickname.value = loginUser.nickname
    MumaUserDefaults.avatarURLString.value = loginUser.avatarURLString
    MumaUserDefaults.pusherID.value = loginUser.pusherID
    
    // NOTICE: 因为一些操作依赖于 accessToken 做检测，又可能依赖上面其他值，所以要放在最后赋值
    MumaUserDefaults.v1AccessToken.value = loginUser.accessToken
}

// MARK: - Register

func validateMobile(mobile: String, withAreaCode areaCode: String, failureHandler: FailureHandler?, completion: ((Bool, String)) -> Void) {
    let requestParameters = [
        "mobile": mobile,
        "phone_code": areaCode,
        ]
    
    let parse: JSONDictionary -> (Bool, String)? = { data in
        print("data: \(data)")
        if let available = data["available"] as? Bool {
            if available {
                return (available, "")
            } else {
                if let message = data["message"] as? String {
                    return (available, message)
                }
            }
        }
        
        return (false, "")
    }
    
    let resource = jsonResource(path: "/v1/users/mobile_validate", method: .GET, requestParameters: requestParameters, parse: parse)
    
    apiRequest({_ in}, baseURL: mumaBaseURL, resource: resource, failure: failureHandler, completion: completion)
}

func registerMobile(mobile: String, withAreaCode areaCode: String, nickname: String, failureHandler: FailureHandler?, completion: Bool -> Void) {
    let requestParameters: JSONDictionary = [
        "mobile": mobile,
        "phone_code": areaCode,
        "nickname": nickname,
        "longitude": 0, // TODO: 注册时不好提示用户访问位置，或许设置技能或用户利用位置查找好友时再提示并更新位置信息
        "latitude": 0
    ]
    
    let parse: JSONDictionary -> Bool? = { data in
        if let state = data["state"] as? String {
            if state == "blocked" {
                return true
            }
        }
        
        return false
    }
    
    let resource = jsonResource(path: "/v1/registration/create", method: .POST, requestParameters: requestParameters, parse: parse)
    
    apiRequest({_ in}, baseURL: mumaBaseURL, resource: resource, failure: failureHandler, completion: completion)
}

func verifyMobile(mobile: String, withAreaCode areaCode: String, verifyCode: String, failureHandler: FailureHandler?, completion: LoginUser -> Void) {
    let requestParameters: JSONDictionary = [
        "mobile": mobile,
        "phone_code": areaCode,
        "token": verifyCode,
        "client": MumaConfig.clientType(),
        "expiring": 0, // 永不过期
    ]
    
    let parse: JSONDictionary -> LoginUser? = { data in
        
        if let accessToken = data["access_token"] as? String {
            if let user = data["user"] as? [String: AnyObject] {
                if
                    let userID = user["id"] as? String,
                    let nickname = user["nickname"] as? String,
                    let pusherID = user["pusher_id"] as? String {
                    let username = user["username"] as? String
                    let avatarURLString = user["avatar_url"] as? String
                    return LoginUser(accessToken: accessToken, userID: userID, username: username, nickname: nickname, avatarURLString: avatarURLString, pusherID: pusherID)
                }
            }
        }
        
        return nil
    }
    
    let resource = jsonResource(path: "/v1/registration/update", method: .PUT, requestParameters: requestParameters, parse: parse)
    
    apiRequest({_ in}, baseURL: mumaBaseURL, resource: resource, failure: failureHandler, completion: completion)
}

// MARK: - User

func userInfoOfUserWithUserID(userID: String, failureHandler: FailureHandler?, completion: JSONDictionary -> Void) {
    let parse: JSONDictionary -> JSONDictionary? = { data in
        return data
    }
    
    let resource = authJsonResource(path: "/v1/users/\(userID)", method: .GET, requestParameters: [:], parse: parse)
    
    apiRequest({_ in}, baseURL: mumaBaseURL, resource: resource, failure: failureHandler, completion: completion)
}

// 自己的信息
func userInfo(failureHandler failureHandler: FailureHandler?, completion: JSONDictionary -> Void) {
    let parse: JSONDictionary -> JSONDictionary? = { data in
        return data
    }
    
    let resource = authJsonResource(path: "/v1/user", method: .GET, requestParameters: [:], parse: parse)
    
    apiRequest({_ in}, baseURL: mumaBaseURL, resource: resource, failure: failureHandler, completion: completion)
}

func updateMyselfWithInfo(info: JSONDictionary, failureHandler: FailureHandler?, completion: Bool -> Void) {
    
    // nickname
    // avatar_url
    // username
    // latitude
    // longitude
    
    let parse: JSONDictionary -> Bool? = { data in
        //println("updateMyself \(data)")
        return true
    }
    
    let resource = authJsonResource(path: "/v1/user", method: .PATCH, requestParameters: info, parse: parse)
    
    apiRequest({_ in}, baseURL: mumaBaseURL, resource: resource, failure: failureHandler, completion: completion)
}

func updateAvatarWithImageData(imageData: NSData, failureHandler: FailureHandler?, completion: String -> Void) {
    
    guard let token = MumaUserDefaults.v1AccessToken.value else {
        print("updateAvatarWithImageData no token")
        return
    }
    
    let parameters: [String: String] = [
        "Authorization": "Token token=\"\(token)\"",
        ]
    
    let filename = "avatar.jpg"
    
    Alamofire.upload(.PATCH, mumaBaseURL.absoluteString + "/v1/user/set_avatar", headers: parameters, multipartFormData: { multipartFormData in
        
        multipartFormData.appendBodyPart(data: imageData, name: "avatar", fileName: filename, mimeType: "image/jpeg")
        
        }, encodingCompletion: { encodingResult in
            //println("encodingResult: \(encodingResult)")
            
            switch encodingResult {
                
            case .Success(let upload, _, _):
                
                upload.responseJSON(completionHandler: { response in
                    
                    guard let
                        data = response.data,
                        json = decodeJSON(data),
                        avatarInfo = json["avatar"] as? JSONDictionary,
                        avatarURLString = avatarInfo["url"] as? String
                        else {
                            failureHandler?(reason: .CouldNotParseJSON, errorMessage: "failed parse JSON in updateAvatarWithImageData")
                            return
                    }
                    
                    completion(avatarURLString)
                })
                
            case .Failure(let encodingError):
                
                failureHandler?(reason: .Other(nil), errorMessage: "\(encodingError)")
            }
    })
}

enum VerifyCodeMethod: String {
    case SMS = "sms"
    case Call = "call"
}

func sendVerifyCodeOfMobile(mobile: String, withAreaCode areaCode: String, useMethod method: VerifyCodeMethod, failureHandler: FailureHandler?, completion: Bool -> Void) {
    
    let requestParameters = [
        "mobile": mobile,
        "phone_code": areaCode,
        "method": method.rawValue
    ]
    
    let parse: JSONDictionary -> Bool? = { data in
        return true
    }
    
    let resource = jsonResource(path: "/v1/sms_verification_codes", method: .POST, requestParameters: requestParameters, parse: parse)
    
    apiRequest({_ in}, baseURL: mumaBaseURL, resource: resource, failure: failureHandler, completion: completion)
}

func loginByMobile(mobile: String, withAreaCode areaCode: String, verifyCode: String, failureHandler: FailureHandler?, completion: LoginUser -> Void) {
    
    print("User login type is \(MumaConfig.clientType())")
    
    let requestParameters: JSONDictionary = [
        "mobile": mobile,
        "phone_code": areaCode,
        "verify_code": verifyCode,
        "client": MumaConfig.clientType(),
        "expiring": 0, // 永不过期
    ]
    
    let parse: JSONDictionary -> LoginUser? = { data in
        
        //println("loginByMobile: \(data)")
        
        if let accessToken = data["access_token"] as? String {
            if let user = data["user"] as? [String: AnyObject] {
                if
                    let userID = user["id"] as? String,
                    let nickname = user["nickname"] as? String,
                    let pusherID = user["pusher_id"] as? String {
                    let username = user["username"] as? String
                    let avatarURLString = user["avatar_url"] as? String
                    return LoginUser(accessToken: accessToken, userID: userID, username: username, nickname: nickname, avatarURLString: avatarURLString, pusherID: pusherID)
                }
            }
        }
        
        return nil
    }
    
    let resource = jsonResource(path: "/v1/auth/token_by_mobile", method: .POST, requestParameters: requestParameters, parse: parse)
    
    apiRequest({_ in}, baseURL: mumaBaseURL, resource: resource, failure: failureHandler, completion: completion)
}

func logout(failureHandler failureHandler: FailureHandler?, completion: () -> Void) {
    
    let parse: JSONDictionary -> Void? = { data in
        return
    }
    
    let resource = authJsonResource(path: "/v1/auth/logout", method: .DELETE, requestParameters: [:], parse: parse)
    
    apiRequest({_ in}, baseURL: mumaBaseURL, resource: resource, failure: failureHandler, completion: completion)
}

