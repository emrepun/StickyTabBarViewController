//
//  ExpandableViewController.swift
//  SampleSporify
//
//  Created by Emre Havan on 20.03.20.
//  Copyright © 2020 Emre Havan. All rights reserved.
//

import UIKit

protocol ExpandableViewControllerDelegate {
    func dismiss()
}

class ExpandableViewController: UIViewController {
    
    var heightConstraint: NSLayoutConstraint!
    var isEnlarged = false
    
    var tabController: MainTabBarController?
    
    let deviceHeight: CGFloat = UIScreen.main.bounds.height
    let collapsedHeight: CGFloat = 50.0

    override func viewDidLoad() {
        super.viewDidLoad()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(update))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func update() {
        //heightConstraint.isActive = false
        let constant = isEnlarged ? collapsedHeight : deviceHeight - (tabController?.tabBar.frame.height ?? 0.0)
        isEnlarged = !isEnlarged
        UIView.animate(withDuration: 1) {
            self.heightConstraint.constant = constant
            self.view.layoutIfNeeded()
            self.tabController?.view.layoutIfNeeded()
        }
    }
    
    func dismiss() {
        tabController?.removeCollapsedView()
    }
    
}
