//
//  BaseViewController.swift
//  Muma
//
//  Created by Binboy on 4/13/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
//        self.client.sendMessage(["api_version":"v1", "message_type": "message", "message":"哈哈！让我们来聊天吧"], toChannel: "/server")
    @IBAction func sendMessage(sender: AnyObject) {
        FayeService.sharedManager.client.sendMessage(["api_version":"v1", "message_type": "message", "message":"哈哈！让我们来聊天吧"], toChannel: "/server")
    }
}
