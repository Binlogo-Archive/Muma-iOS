//
//  ShowViewController.swift
//  FellowPlusSwift
//
//  Created by FellowPlus-Binboy on 2/23/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import UIKit
import SnapKit

class ShowViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    fileprivate var isFirstAppear = true
    
    fileprivate var steps = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        if isFirstAppear {
            scrollView.alpha = 0
            pageControl.alpha = 0
            registerButton.alpha = 0
            loginButton.alpha = 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFirstAppear {
            UIView.animate(withDuration: 1, delay: 0.5, options: UIViewAnimationOptions(), animations: { [weak self] in
                self?.scrollView.alpha = 1
                self?.pageControl.alpha = 1
                self?.registerButton.alpha = 1
                self?.loginButton.alpha = 1
                }, completion: { _ in })
        }
        
        isFirstAppear = false
    }
    
    // MARK: Private
    
    fileprivate func initUI() {
        
        let stepA = stepGenius()
        let stepB = stepMatch()
        let stepC = stepMeet()
        
        steps = [stepA, stepB, stepC]
        
        pageControl.numberOfPages = steps.count
        pageControl.pageIndicatorTintColor = UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 1)
        pageControl.currentPageIndicatorTintColor = UIColor(red: 50/255.0, green: 167/255.0, blue: 255/255.0, alpha: 1.0)
        
        let viewsDictionary = [
            "view": view,
            "stepA": stepA.view,
            "stepB": stepB.view,
            "stepC": stepC.view,
        ]
        
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[stepA(==view)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary as Any as! [String : Any])
        
        NSLayoutConstraint.activate(vConstraints)
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[stepA(==view)][stepB(==view)][stepC(==view)]|", options: [.alignAllBottom, .alignAllTop], metrics: nil, views: viewsDictionary as Any as! [String : Any])
        
        NSLayoutConstraint.activate(hConstraints)
        
//        stepA.view.snp_updateConstraints { (make) -> Void in
//            make.leading.equalTo(view)
//            make.top.equalTo(view)
//            make.bottom.equalTo(view)
//        }
//
//        stepB.view.snp_updateConstraints { (make) -> Void in
//            make.leading.equalTo(stepA.view.snp_trailing)
//            make.trailing.equalTo(view)
//            make.top.equalTo(view)
//            make.bottom.equalTo(view)
//        }
        
    }
    
    fileprivate func stepGenius() -> ShowStepGeniusViewController {
        let step = storyboard!.instantiateViewController(withIdentifier: "ShowStepGeniusViewController") as! ShowStepGeniusViewController

        step.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(step.view)

        addChildViewController(step)
        step.didMove(toParentViewController: self)
        
        return step
    }
    
    fileprivate func stepMatch() -> ShowStepMatchViewController {
        let step = storyboard!.instantiateViewController(withIdentifier: "ShowStepMatchViewController") as! ShowStepMatchViewController
        
        step.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(step.view)
        
        addChildViewController(step)
        step.didMove(toParentViewController: self)
        
        return step
    }
    
    fileprivate func stepMeet() -> ShowStepMeetViewController {
        let step = storyboard!.instantiateViewController(withIdentifier: "ShowStepMeetViewController") as! ShowStepMeetViewController
        
        step.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(step.view)
        
        addChildViewController(step)
        step.didMove(toParentViewController: self)
        
        return step
    }
}

// MARK: - UIScrollViewDelegate

extension ShowViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let pageWidth = scrollView.bounds.width
        let pageFraction = scrollView.contentOffset.x / pageWidth
        
        let page = Int(round(pageFraction))
        
        pageControl.currentPage = page
    }
}
