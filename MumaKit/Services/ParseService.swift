//
//  ParseService.swift
//  Muma
//
//  Created by Binboy on 4/22/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import Foundation
import Parse

class ParseServer {
    
    static let sharedManager = ParseServer()
    
    let configuration = ParseClientConfiguration {
        $0.applicationId = "muma-parse-server"
        $0.server = "http://127.0.0.1:1337/parse/"
        $0.isLocalDatastoreEnabled = true
    }
    
    func startConnect() {
        Parse.initialize(with: configuration)
        
        registerModels()
//        let testObject = PFObject(className: "TestObject")
//        testObject["foo"] = "bar"
//        testObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
//            if success {
//                print("Object has been saved.")
//            }
//        }
    }
    
    fileprivate func registerModels() {
//        Avatar.registerSubclass()
    }
}
