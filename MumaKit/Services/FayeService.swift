//
//  FayeService.swift
//  Muma
//
//  Created by Binboy on 4/13/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

//import Foundation
//
//let fayeQueue = DispatchQueue(label: "top.Binboy.fayeQueue", attributes: [])
//
//class FayeService: NSObject, MZFayeClientDelegate {
//    
//    static let sharedManager = FayeService()
//    
//    let client: MZFayeClient = {
//        let client = MZFayeClient(url:fayeBaseURL)
//        return client
//    }()
//    
//    override init() {
//        super.init()
//        
//        client.delegate = self
//    }
//    
//    func startConnect() {
//        
//        fayeQueue.async { [weak self] in
//            self?.client.subscribe(toChannel: "/server") { data in
//                print("subscribeToChannel:\(data)")
//            }
//            self?.client.connect()
//        }
//        
//    }
//    
//    // MARK: MZFayeClientDelegate
//    
//    func fayeClient(_ client: MZFayeClient!, didConnectTo url: URL!) {
//        print("fayeClient didConnectToURL \(url)")
//    }
//    
//    func fayeClient(_ client: MZFayeClient!, didDisconnectWithError error: NSError?) {
//        
//        if let error = error {
//            print("fayeClient didDisconnectWithError \(error.description)")
//        }
//    }
//    
//    func fayeClient(_ client: MZFayeClient!, didFailDeserializeMessage message: [AnyHashable: Any]!, withError error: NSError!) {
//        print("fayeClient didFailDeserializeMessage \(error.description)")
//    }
//    
//    func fayeClient(_ client: MZFayeClient!, didFailWithError error: NSError!) {
//        print("fayeClient didFailWithError \(error.description)")
//    }
//    
//    func fayeClient(_ client: MZFayeClient!, didReceiveMessage messageData: [AnyHashable: Any]!, fromChannel channel: String!) {
//        print("fayeClient didReceiveMessage \(messageData)")
//    }
//    
//    func fayeClient(_ client: MZFayeClient!, didSubscribeToChannel channel: String!) {
//        print("fayeClient didSubscribeToChannel \(channel)")
//        
//    }
//    
//    func fayeClient(_ client: MZFayeClient!, didUnsubscribeFromChannel channel: String!) {
//        print("fayeClient didUnsubscribeFromChannel \(channel)")
//    }
//}
