//
//  Manager.swift
//  Muma
//
//  Created by Binboy_王兴彬 on 22/05/2017.
//  Copyright © 2017 Binboy. All rights reserved.
//


import Foundation

// ref https://github.com/dduan/cURLLook

extension URLRequest {
    /**
     Convenience property, the value of calling `cURLRepresentation()` with no arguments.
     */
    var cURLString: String {
        get {
            return cURLRepresentation()
        }
    }
    
    /**
     cURL (http://http://curl.haxx.se) is a commandline tool that makes network requests. This method serializes a `NSURLRequest` to a cURL
     command that performs the same HTTP request.
     - Parameter session:    *optional* the `NSURLSession` this NSURLRequest is being used with. Extra information from the session such as
     cookies and credentials may be included in the result.
     - Parameter credential: *optional* the credential to include in the result. The value of `session?.configuration.URLCredentialStorage`,
     when present, would override this argument.
     - Returns:              a string whose value is a cURL command that would perform the same HTTP request this object represents.
     */
    func cURLRepresentation(with session: URLSession? = nil, credential: URLCredential? = nil) -> String {
        var components = ["curl -i"]
        
        if let httpMethod = self.httpMethod, httpMethod != "GET" {
            components.append("-X \(httpMethod)")
        }
        
        if let credentialStorage = session?.configuration.urlCredentialStorage {
            
            if let host = url?.host, let scheme = url?.scheme {
                let port = (url as NSURL?)?.port?.intValue ?? 0
                
                let protectionSpace = URLProtectionSpace(
                    host: host,
                    port: port,
                    protocol: scheme,
                    realm: host,
                    authenticationMethod: NSURLAuthenticationMethodHTTPBasic
                )
                
                if let credentials = credentialStorage.credentials(for: protectionSpace)?.values {
                    for credential in credentials {
                        if let user = credential.user, let password = credential.password {
                            components.append("-u \(user):\(password)")
                        }
                    }
                } else {
                    if let user = credential?.user, let password = credential?.password {
                        components.append("-u \(user):\(password)")
                    }
                }
            }
            
        }
        
        if let session = session, let URL = url {
            if session.configuration.httpShouldSetCookies {
                if let
                    cookieStorage = session.configuration.httpCookieStorage,
                    let cookies = cookieStorage.cookies(for: URL), !cookies.isEmpty {
                    let string = cookies.reduce("") { $0 + "\($1.name)=\($1.value);" }
                    components.append("-b \"\(string.substring(to: string.characters.index(before: string.endIndex)))\"")
                }
            }
        }
        
        if let headerFields = allHTTPHeaderFields {
            
            for (field, value) in headerFields {
                switch field {
                case "Cookie":
                    continue
                default:
                    let escapedValue = value.replacingOccurrences(of: "\"", with: "\\\"")
                    components.append("-H \"\(field): \(escapedValue)\"")
                }
            }
        }
        
        if let additionalHeaders = session?.configuration.httpAdditionalHeaders as? [String: String] {
            
            for (field, value) in additionalHeaders {
                switch field {
                case "Cookie":
                    continue
                default:
                    let escapedValue = value.replacingOccurrences(of: "\"", with: "\\\"")
                    components.append("-H \"\(field): \(escapedValue)\"")
                }
            }
        }
        
        if let HTTPBody = httpBody, let HTTPBodyString = String(data: HTTPBody, encoding: .utf8) {
            let escapedString = HTTPBodyString.replacingOccurrences(of: "\"", with: "\\\"")
            components.append("-d \"\(escapedString)\"")
        }
        
        return components.joined(separator: " ") + "\n"
    }
}
