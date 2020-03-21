//
//  ExpandableViewController.swift
//  SampleSporify
//
//  Created by Emre Havan on 20.03.20.
//  Copyright © 2020 Emre Havan. All rights reserved.
//

import UIKit

protocol ViewControllerExpanding {
    func dismiss(withAnimation: Bool)
}

class ExpandableViewController: UIViewController {
    
    var heightConstraint: NSLayoutConstraint!
    var isEnlarged = false
    
    var tabController: MainTabBarController?
    
    let deviceHeight: CGFloat = UIScreen.main.bounds.height
    let collapsedHeight: CGFloat = 50.0
    let heightBeforeDismissal: CGFloat = 0.0
    
    private let childVC: UIViewController
    
    init(withChildVC childVC: UIViewController) {
        self.childVC = childVC
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(update))
        view.addGestureRecognizer(gestureRecognizer)
        view.clipsToBounds = true
        configureChildVC()
    }
    
    private func configureChildVC() {
        addChild(childVC)
        view.addSubview(childVC.view)
        childVC.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0).isActive = true
        childVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0).isActive = true
        childVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0).isActive = true
        childVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0).isActive = true
        childVC.didMove(toParent: self)
    }
    
    @objc private func update() {
        let constant = isEnlarged ? collapsedHeight : deviceHeight - (tabController?.tabBar.frame.height ?? 0.0)
        isEnlarged = !isEnlarged
        UIView.animate(withDuration: 1) {
            self.heightConstraint.constant = constant
            self.view.layoutIfNeeded()
            self.tabController?.view.layoutIfNeeded()
        }
    }
}

extension ExpandableViewController: ViewControllerExpanding {
    func dismiss(withAnimation: Bool) {
        if withAnimation {
            UIView.animate(withDuration: 1,
                           animations: {
                            self.heightConstraint.constant = self.heightBeforeDismissal
                            self.view.layoutIfNeeded()
                            self.tabController?.view.layoutIfNeeded()
            }) { (completed) in
                if completed {
                    self.tabController?.removeCollapsedView()
                }
            }
        } else {
            tabController?.removeCollapsedView()
        }
        
    }
}
