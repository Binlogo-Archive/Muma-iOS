//
//  MumaNetworking.swift
//  Muma
//
//  Created by Binboy on 4/13/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import UIKit

public enum Method: String, CustomStringConvertible {
    case OPTIONS = "OPTIONS"
    case GET = "GET"
    case HEAD = "HEAD"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
    case TRACE = "TRACE"
    case CONNECT = "CONNECT"
    
    public var description: String {
        return self.rawValue
    }
}

public struct Resource<A>: CustomStringConvertible {
    let path: String
    let method: Method
    let requestBody: NSData?
    let headers: [String:String]
    let parse: NSData -> A?
    
    public var description: String {
        let decodeRequestBody: [String: AnyObject]
        if let requestBody = requestBody {
            decodeRequestBody = decodeJSON(requestBody)!
        } else {
            decodeRequestBody = [:]
        }
        
        return "Resource(Method: \(method), path: \(path), headers: \(headers), requestBody: \(decodeRequestBody))"
    }
}

public enum Reason: CustomStringConvertible {
    case CouldNotParseJSON
    case NoData
    case NoSuccessStatusCode(statusCode: Int)
    case Other(NSError?)
    
    public var description: String {
        switch self {
        case .CouldNotParseJSON:
            return "CouldNotParseJSON"
        case .NoData:
            return "NoData"
        case .NoSuccessStatusCode(let statusCode):
            return "NoSuccessStatusCode: \(statusCode)"
        case .Other(let error):
            return "Other, Error: \(error?.description)"
        }
    }
}

public typealias JSONDictionary = [String: AnyObject]

public typealias FailureHandler = (reason: Reason, errorMessage: String?) -> Void

let defaultFailureHandler: FailureHandler = { reason, errorMessage in
    print("\n***************************** MumaNetworking Failure *****************************")
    print("Reason: \(reason)")
    if let errorMessage = errorMessage {
        print("errorMessage: >>>\(errorMessage)<<<\n")
    }
}

func decodeJSON(data: NSData) -> JSONDictionary? {
    
    if data.length > 0 {
        guard let result = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) else {
            return JSONDictionary()
        }
        
        if let dictionary = result as? JSONDictionary {
            return dictionary
        } else if let array = result as? [JSONDictionary] {
            return ["data": array]
        } else {
            return JSONDictionary()
        }
        
    } else {
        return JSONDictionary()
    }
}

func encodeJSON(dict: JSONDictionary) -> NSData? {
    return dict.count > 0 ? (try? NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions())) : nil
}

public func jsonResource<A>(path path: String, method: Method, requestParameters: JSONDictionary, parse: JSONDictionary -> A?) -> Resource<A> {
    return jsonResource(token: nil, path: path, method: method, requestParameters: requestParameters, parse: parse)
}

//public func authJsonResource<A>(path path: String, method: Method, requestParameters: JSONDictionary, parse: JSONDictionary -> A?) -> Resource<A>? {
//    guard let token = YepUserDefaults.v1AccessToken.value else {
//        print("No token for auth")
//        return nil
//    }
//    return jsonResource(token: token, path: path, method: method, requestParameters: requestParameters, parse: parse)
//}

public func jsonResource<A>(token token: String?, path: String, method: Method, requestParameters: JSONDictionary, parse: JSONDictionary -> A?) -> Resource<A> {
    
    let jsonParse: NSData -> A? = { data in
        if let json = decodeJSON(data) {
            return parse(json)
        }
        return nil
    }
    
    let jsonBody = encodeJSON(requestParameters)
    var headers = [
        "Content-Type": "application/json",
        ]
    if let token = token {
        headers["Authorization"] = "Token token=\"\(token)\""
    }
    
    let locale = NSLocale.autoupdatingCurrentLocale()
    if let
        languageCode = locale.objectForKey(NSLocaleLanguageCode) as? String,
        countryCode = locale.objectForKey(NSLocaleCountryCode) as? String {
        headers["Accept-Language"] = languageCode + "-" + countryCode
    }
    
    return Resource(path: path, method: method, requestBody: jsonBody, headers: headers, parse: jsonParse)
}

public func authJsonResource<A>(path path: String, method: Method, requestParameters: JSONDictionary, parse: JSONDictionary -> A?) -> Resource<A>? {
    guard let token = MumaUserDefaults.v1AccessToken.value else {
        print("No token for auth")
        return nil
    }
    return jsonResource(token: token, path: path, method: method, requestParameters: requestParameters, parse: parse)
}

public func apiRequest<A>(modifyRequest: NSMutableURLRequest -> (), baseURL: NSURL, resource: Resource<A>?, failure: FailureHandler?, completion: A -> Void) {
    
    // TODO: 请求API

}
