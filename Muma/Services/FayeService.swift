//
//  FayeService.swift
//  Muma
//
//  Created by Binboy on 4/13/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import Foundation
import RealmSwift

let fayeQueue = dispatch_queue_create("top.Binboy.fayeQueue", DISPATCH_QUEUE_SERIAL)

class FayeService: NSObject, MZFayeClientDelegate {
    
    static let sharedManager = FayeService()
    
    let client: MZFayeClient = {
        let client = MZFayeClient(URL:fayeBaseURL)
        return client
    }()
    
    override init() {
        super.init()
        
        client.delegate = self
    }
    
    func startConnect() {
        
        dispatch_async(fayeQueue) { [weak self] in
            self?.client.subscribeToChannel("/server") { data in
                print("subscribeToChannel:\(data)")
            }
            self?.client.connect()
        }
        
    }
    
    // MARK: MZFayeClientDelegate
    
    func fayeClient(client: MZFayeClient!, didConnectToURL url: NSURL!) {
        print("fayeClient didConnectToURL \(url)")
    }
    
    func fayeClient(client: MZFayeClient!, didDisconnectWithError error: NSError?) {
        
        if let error = error {
            print("fayeClient didDisconnectWithError \(error.description)")
        }
    }
    
    func fayeClient(client: MZFayeClient!, didFailDeserializeMessage message: [NSObject : AnyObject]!, withError error: NSError!) {
        print("fayeClient didFailDeserializeMessage \(error.description)")
    }
    
    func fayeClient(client: MZFayeClient!, didFailWithError error: NSError!) {
        print("fayeClient didFailWithError \(error.description)")
    }
    
    func fayeClient(client: MZFayeClient!, didReceiveMessage messageData: [NSObject : AnyObject]!, fromChannel channel: String!) {
        print("fayeClient didReceiveMessage \(messageData)")
    }
    
    func fayeClient(client: MZFayeClient!, didSubscribeToChannel channel: String!) {
        print("fayeClient didSubscribeToChannel \(channel)")
        
    }
    
    func fayeClient(client: MZFayeClient!, didUnsubscribeFromChannel channel: String!) {
        print("fayeClient didUnsubscribeFromChannel \(channel)")
    }
}
