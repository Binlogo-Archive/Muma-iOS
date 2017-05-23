//
//  ZPAPIServiceClient.swift
//  ZealPlus
//
//  Created by Binboy_王兴彬 on 1/12/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import Foundation
import MumaNetworking
//import Alamofire

//MARK: - Custom Configs

#if STAGING
public let mumaBaseURL = URL(string: "http://staging.binboy.top/api")!
//public let fayeBaseURL = URL(string: "ws://133.130.118.63:8000/faye")!
#else
public let mumaBaseURL = URL(string: "http://api.binboy.top")!
#endif

fileprivate func println(_ item: @autoclosure () -> Any) {
    #if DEBUG
        Swift.print(item())
    #endif
}

// MARK: - Register

public struct MobilePhone {
    public let areaCode: String
    public let number: String
    
    public var fullNumber: String {
        return "+" + areaCode + " " + number
    }
}

public func validateMobilePhone(_ mobilePhone: MobilePhone, failureHandler: FailureHandler?, completion: @escaping Completion<(Bool, String?)>) {
    
    let requestParameters: JSONDictionary = [
        "phone_number": mobilePhone.number,
        "phone_code": mobilePhone.areaCode,
        ]
    
    let parse: Parse<(Bool, String?)> = { data in
        println("validateMobilePhone: \(data)")
        
        guard let available = data["available"] as? Bool else {
            return (false, "")
        }
        
        guard available else {
            if let message = data["message"] as? String {
                return (false, message)
            }
            return (false, "")
        }
        
        return (available, nil)
    }
    
    let resource = jsonResource(path: "/v1/users/mobile_validate", requestParameters: requestParameters, parse: parse)
    
    apiRequest({_ in}, baseURL: mumaBaseURL, resource: resource, failure: failureHandler, completion: completion)
}

public func registerMobilePhone(_ mobilePhone: MobilePhone, nickname: String, failureHandler: FailureHandler?, completion: @escaping Completion<Bool>) {
    
    let requestParameters: JSONDictionary = [
        "phone_number": mobilePhone.number,
        "phone_code": mobilePhone.areaCode,
        "nickname": nickname,
        // 注册时不好提示用户访问位置，或许设置技能或用户利用位置查找好友时再提示并更新位置信息
        "longitude": 0,
        "latitude": 0,
    ]
    
    let parse: Parse<Bool> = { data in
        
        if let state = data["state"] as? String {
            if state == "blocked" {
                return true
            }
        }
        
        return false
    }
    
    let resource = jsonResource(path: "/v1/registration/create", method: .post, requestParameters: requestParameters, parse: parse)
    
    apiRequest({_ in}, baseURL: mumaBaseURL, resource: resource, failure: failureHandler, completion: completion)
}

//MARK: - Login

public struct LoginUser: CustomStringConvertible {
    
    public let accessToken: String
    public let userID: String
    public let username: String?
    public let nickname: String
    public let avatarURLString: String?
    public let pusherID: String
    
    public var description: String {
        return "LoginUser(accessToken: \(accessToken), userID: \(userID), username: \(String(describing: username)), nickname: \(nickname), avatarURLString: \(String(describing: avatarURLString)), pusherID: \(pusherID))"
    }
    
    static func fromJSONDictionary(_ data: JSONDictionary) -> LoginUser? {
        
        guard let accessToken = data["access_token"] as? String else { return nil }
        
        guard let user = data["user"] as? JSONDictionary else { return nil }
        guard let userID = user["id"] as? String else { return nil }
        guard let nickname = user["nickname"] as? String else { return nil }
        guard let pusherID = user["pusher_id"] as? String else { return nil }
        
        let username = user["username"] as? String
        let avatarURLString = user["avatar_url"] as? String
        
        return LoginUser(accessToken: accessToken, userID: userID, username: username, nickname: nickname, avatarURLString: avatarURLString, pusherID: pusherID)
    }
}

public func verifyMobilePhone(_ mobilePhone: MobilePhone, verifyCode: String, failureHandler: FailureHandler?, completion: @escaping Completion<LoginUser>) {
    let requestParameters: JSONDictionary = [
        "phone_number": mobilePhone.number,
        "phone_code": mobilePhone.areaCode,
        "verify_code": verifyCode,
        "client": Config.clientType.rawValue,
        "expiring": 0, // 永不过期
    ]
    
    let parse: Parse<LoginUser> = { data in
        return LoginUser.fromJSONDictionary(data)
    }
    
    let resource = jsonResource(path: "/v1/registration/update", method: .put, requestParameters: requestParameters, parse: parse)
    
    apiRequest({_ in}, baseURL: mumaBaseURL, resource: resource, failure: failureHandler, completion: completion)
}

public func saveTokenAndUserInfo(of loginUser: LoginUser) {
    
//    MumaUserDefaults.userID.value = loginUser.userID
//    MumaUserDefaults.nickname.value = loginUser.nickname
//    MumaUserDefaults.avatarURLString.value = loginUser.avatarURLString
//    MumaUserDefaults.pusherID.value = loginUser.pusherID
    
    // NOTICE: 因为一些操作依赖于 accessToken 做检测，又可能依赖上面其他值，所以要放在最后赋值
//    MumaUserDefaults.v1AccessToken.value = loginUser.accessToken
}

// MARK: - User

public func userInfo(with userID: String, failureHandler: FailureHandler?, completion: @escaping Completion<JSONDictionary>) {
    
    let parse: Parse<JSONDictionary> = { data in
        return data
    }
    
    let resource = authJsonResource(path: "/v1/users/\(userID)", parse: parse)
    
    apiRequest({_ in}, baseURL: mumaBaseURL, resource: resource, failure: failureHandler, completion: completion)
}

// 自己的用户信息
public func userInfo(failureHandler: FailureHandler?, completion: @escaping Completion<JSONDictionary>) {
    
    let parse: Parse<JSONDictionary> = { data in
        return data
    }
    
    let resource = authJsonResource(path: "/v1/user", parse: parse)
    
    apiRequest({_ in}, baseURL: mumaBaseURL, resource: resource, failure: failureHandler, completion: completion)
}

public func updateMyself(with info: JSONDictionary, failureHandler: FailureHandler?, completion: @escaping Completion<Bool>) {
    
    // nickname
    // avatar_url
    // username
    // latitude
    // longitude
    
    let parse: Parse<Bool> = { data in
        println("updateMyself \(data)")
        return true
    }
    
    let resource = authJsonResource(path: "/v1/user", method: .patch, requestParameters: info, parse: parse)
    
    apiRequest({_ in}, baseURL: mumaBaseURL, resource: resource, failure: failureHandler, completion: completion)
}

//public func updateAvatar(with imageData: Data, failureHandler: FailureHandler?, completion: Completion<String>) {
//    
//    guard let token = MumaUserDefaults.v1AccessToken.value else {
//        println("updateAvatarWithImageData no token")
//        return
//    }
//    
//    let parameters: [String: String] = [
//        "Authorization": "Token token=\"\(token)\"",
//        ]
//    
//    let filename = "avatar.jpg"
//    
//    Alamofire.upload(multipartFormData: { multipartFormData in
//        
//        multipartFormData.append(imageData, withName: "avatar", fileName: filename, mimeType: "image/jpeg")
//        
//    }, to: url, method: .patch, headers: headers, encodingCompletion: { encodingResult in
//        
//        switch encodingResult {
//            
//        case .success(let upload, _, _):
//            
//            upload.responseJSON(completionHandler: { response in
//                
//                guard
//                    let data = response.data,
//                    let json = decodeJSON(data),
//                    let avatarInfo = json["avatar"] as? JSONDictionary,
//                    let avatarURLString = avatarInfo["url"] as? String else {
//                        failureHandler?(.couldNotParseJSON, "failed parse JSON in updateAvatarWithImageData")
//                        return
//                }
//                
//                completion(avatarURLString)
//            })
//            
//        case .failure(let encodingError):
//            
//            let failureHandler: FailureHandler = { (reason, errorMessage) in
//                defaultFailureHandler(reason, errorMessage)
//                failureHandler?(reason, errorMessage)
//            }
//            failureHandler(.other(nil), "\(encodingError)")
//        }
//    })
//}

public enum VerifyCodeMethod: String {
    case SMS = "sms"
    case Call = "call"
}

public func requestSendVerifyCode(to mobilePhone: MobilePhone, by method: VerifyCodeMethod, failureHandler: FailureHandler?, completion: @escaping Completion<Bool>) {
    
    let requestParameters = [
        "phone_number": mobilePhone.number,
        "phone_code": mobilePhone.areaCode,
        "method": method.rawValue
    ]
    
    let parse: Parse<Bool> = { data in
        return true
    }
    
    let resource = jsonResource(path: "/v1/sms_verification_codes", method: .post, requestParameters: requestParameters, parse: parse)
    
    apiRequest({_ in}, baseURL: mumaBaseURL, resource: resource, failure: failureHandler, completion: completion)
}

public func confirmNewMobilePhone(_ mobilePhone: MobilePhone, withVerifyCode verifyCode: String, failureHandler: FailureHandler?, completion: @escaping () -> Void) {
    
    let requestParameters: JSONDictionary = [
        "phone_code": mobilePhone.areaCode,
        "phone_number": mobilePhone.number,
        "token": verifyCode,
        ]
    
    let parse: (JSONDictionary) -> Void? = { data in
        return
    }
    
    let resource = authJsonResource(path: "/v1/user/update_mobile", method: .patch, requestParameters: requestParameters, parse: parse)
    
    apiRequest({_ in}, baseURL: mumaBaseURL, resource: resource, failure: failureHandler, completion: completion)
}

public func login(by mobilePhone: MobilePhone, verifyCode: String, failureHandler: FailureHandler?, completion: @escaping Completion<LoginUser>) {
    
    println("User login type is \(Config.clientType)")
    
    let requestParameters: JSONDictionary = [
        "phone_number": mobilePhone.number,
        "phone_code": mobilePhone.areaCode,
        "verify_code": verifyCode,
        "client": Config.clientType.rawValue,
        "expiring": 0, // 永不过期
    ]
    
    let parse: Parse<LoginUser> = { data in
        return LoginUser.fromJSONDictionary(data)
    }
    
    let resource = jsonResource(path: "/v1/auth/token_by_mobile", method: .post, requestParameters: requestParameters, parse: parse)
    
    apiRequest({_ in}, baseURL: mumaBaseURL, resource: resource, failure: failureHandler, completion: completion)
}

public func logout(failureHandler: FailureHandler?, completion: @escaping () -> Void) {
    
    let parse: Parse<Void> = { data in
        return
    }
    
    let resource = authJsonResource(path: "/v1/auth/logout", method: .delete, parse: parse)
    
    apiRequest({_ in}, baseURL: mumaBaseURL, resource: resource, failure: failureHandler, completion: completion)
}

