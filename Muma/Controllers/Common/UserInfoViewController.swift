//
//  UserInfoViewController.swift
//  Muma
//
//  Created by Binboy on 4/16/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import UIKit

class UserInfoViewController: UIViewController {
    
    @IBOutlet weak var myTableView: UITableView! {
        didSet {
            myTableView.backgroundColor = UIColor.lightGrayColor()
            myTableView.separatorStyle = .SingleLine
            myTableView.registerClass(UserInfoIconCell.self, forCellReuseIdentifier: MumaConfig.CellIdentifier.userInfoIconCell)
            let headerView = UserHeaderView(frame: CGRect(x: 0, y: 0, width: MumaUtilKit.getScreenRect().width, height: MumaConfig.UserInfo.headerViewHeight))
            myTableView.addParallaxWithView(headerView, andHeight: CGRectGetHeight(headerView.frame))
            
            if !isMe {

                myTableView.tableFooterView = sayHiFooterView
            }
        }
    }
    
    lazy var sayHiFooterView:UIView = {
        let button = UIButton(type: .Custom)
        button.setTitle("打招呼", forState: .Normal)
        button.frame = CGRect(x: 0, y: 0, width: MumaUtilKit.getScreenRect().width, height: 50)
        button.backgroundColor = UIColor.blueColor()
        button.clipsToBounds = true
        button.layer.cornerRadius = 5
        return button
    }()
    
    var isMe = false {
        didSet {
            if !isMe {
                // 好友主页
            } else {
                // 我的主页
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension UserInfoViewController: UITableViewDataSource {
    
    enum UserInfoSection: Int {
        case About = 0
        case Properties
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case UserInfoSection.About.rawValue:
            return 1
        case UserInfoSection.Properties.rawValue:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case UserInfoSection.About.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(MumaConfig.CellIdentifier.userInfoTextCell) as? UserInfoTextCell
            cell?.valueLabel?.text = "这个家伙很懒，还没填写个人简介，这句话应该很长长喊刚行行偶家刚到家"
            return cell!
        case UserInfoSection.Properties.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(MumaConfig.CellIdentifier.userInfoIconCell)
            if indexPath.row == 0 {
                cell?.textLabel?.text = isMe ? "我的工坊" : "他的工坊"
            } else if indexPath.row == 1 {
                cell?.textLabel?.text = isMe ? "我的话题" : "他的话题"
            }
            return cell!
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(MumaConfig.CellIdentifier.userInfoIconCell)
            cell?.textLabel?.text = "IconCell"
            return cell!
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        if !isMe && section == numberOfSectionsInTableView(myTableView) - 1 {
//            return 0.5
//        }
        return 20.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.5
    }
}

extension UserInfoViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
}
