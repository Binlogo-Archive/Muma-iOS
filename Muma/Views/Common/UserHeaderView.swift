//
//  EaseUserHeaderView.swift
//  Muma
//
//  Created by Binboy on 4/16/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import UIKit
import Navi

class UserHeaderView: UIView {

    lazy var bgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Welcome")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var avatarButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "placeholder_monkey_round_50"), for: UIControlState())
        return button
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.text = "Binboy @Muma"
        return label;
    }()
    
    lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.text = "北京"
        return label;
    }()
    
    func configView(withUser user:User) {
        
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        makeUI()
    }
    
    // MARK: Private
    fileprivate func makeUI() {
        addSubview(bgImageView)
        addSubview(avatarButton)
        addSubview(nameLabel)
        addSubview(locationLabel)

        bgImageView.snp_makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(0)
        }
        
        locationLabel.snp_makeConstraints { (make) in
            make.bottom.equalTo(self).offset(-15)
            make.centerX.equalTo(self)
        }
        
        nameLabel.snp_makeConstraints { (make) in
            make.bottom.equalTo(locationLabel.snp_top).offset(-15)
            make.centerX.equalTo(self)
        }

        avatarButton.snp_makeConstraints { (make) in
            make.bottom.equalTo(nameLabel.snp_top).offset(-15);
            make.centerX.equalTo(self);
        }
    }
}
