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
    
    private var isFirstAppear = true
    
    private var steps = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        if isFirstAppear {
            scrollView.alpha = 0
            pageControl.alpha = 0
            registerButton.alpha = 0
            loginButton.alpha = 0
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFirstAppear {
            UIView.animateWithDuration(1, delay: 0.5, options: .CurveEaseInOut, animations: { [weak self] in
                self?.scrollView.alpha = 1
                self?.pageControl.alpha = 1
                self?.registerButton.alpha = 1
                self?.loginButton.alpha = 1
                }, completion: { _ in })
        }
        
        isFirstAppear = false
    }
    
    // MARK: Private
    
    private func initUI() {
        
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
        
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[stepA(==view)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        
        NSLayoutConstraint.activateConstraints(vConstraints)
        
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[stepA(==view)][stepB(==view)][stepC(==view)]|", options: [.AlignAllBottom, .AlignAllTop], metrics: nil, views: viewsDictionary)
        
        NSLayoutConstraint.activateConstraints(hConstraints)
        
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
    
    private func stepGenius() -> ShowStepGeniusViewController {
        let step = storyboard!.instantiateViewControllerWithIdentifier("ShowStepGeniusViewController") as! ShowStepGeniusViewController

        step.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(step.view)

        addChildViewController(step)
        step.didMoveToParentViewController(self)
        
        return step
    }
    
    private func stepMatch() -> ShowStepMatchViewController {
        let step = storyboard!.instantiateViewControllerWithIdentifier("ShowStepMatchViewController") as! ShowStepMatchViewController
        
        step.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(step.view)
        
        addChildViewController(step)
        step.didMoveToParentViewController(self)
        
        return step
    }
    
    private func stepMeet() -> ShowStepMeetViewController {
        let step = storyboard!.instantiateViewControllerWithIdentifier("ShowStepMeetViewController") as! ShowStepMeetViewController
        
        step.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(step.view)
        
        addChildViewController(step)
        step.didMoveToParentViewController(self)
        
        return step
    }
}

// MARK: - UIScrollViewDelegate

extension ShowViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {

        let pageWidth = CGRectGetWidth(scrollView.bounds)
        let pageFraction = scrollView.contentOffset.x / pageWidth
        
        let page = Int(round(pageFraction))
        
        pageControl.currentPage = page
    }
}
