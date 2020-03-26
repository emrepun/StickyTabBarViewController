//
//  MainTabBarController.swift
//  SampleSporify
//
//  Created by Emre Havan on 20.03.20.
//  Copyright © 2020 Emre Havan. All rights reserved.
//

public protocol StickyViewControllerSupporting: UITabBarController {
    var collapsableVCFlow: ExpandableViewController? { get set }
    var collapsedHeight: CGFloat { get }
    func configureCollapsedTrainingView(withChildViewController childViewController: Expandable)
    func removeCollapsibleView(withAnimation: Bool, duration: TimeInterval)
    func collapseCollapsibleVC(duration: TimeInterval)
}

extension StickyViewControllerSupporting {
    
    func configureCollapsedTrainingView(withChildViewController childViewController: Expandable) {
        guard collapsableVCFlow == nil else {
            return
        }
        childViewController.loadView()
        childViewController.expander = self
        collapsableVCFlow = ExpandableViewController(withChildVC: childViewController,
                                                     collapsedHeight: collapsedHeight,
                                                     minimisedView: childViewController.minimisedView)
        collapsableVCFlow!.tabController = self
        view.addSubview(collapsableVCFlow!.view)
        addChild(collapsableVCFlow!)
        collapsableVCFlow!.view.translatesAutoresizingMaskIntoConstraints = false
        collapsableVCFlow!.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collapsableVCFlow!.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        collapsableVCFlow!.view.bottomAnchor.constraint(equalTo: tabBar.topAnchor).isActive = true
        let heightConstraint = collapsableVCFlow!.view.heightAnchor.constraint(equalToConstant: collapsedHeight)
        heightConstraint.isActive = true
        collapsableVCFlow!.heightConstraint = heightConstraint

        collapsableVCFlow!.didMove(toParent: self)
    }
    
    func removeCollapsibleView(withAnimation: Bool, duration: TimeInterval = 1.0) {
        guard let collapsableVCFlow = collapsableVCFlow else {
            return
        }
        if withAnimation {
            UIView.animate(withDuration: duration,
                           animations: {
                            collapsableVCFlow.heightConstraint.constant = 0.0
                            collapsableVCFlow.view.layoutIfNeeded()
                            self.view.layoutIfNeeded()
            }) { (completed) in
                if completed {
                    collapsableVCFlow.view.removeFromSuperview()
                    collapsableVCFlow.removeFromParent()
                    self.collapsableVCFlow = nil
                }
            }
        } else {
            collapsableVCFlow.view.removeFromSuperview()
            collapsableVCFlow.removeFromParent()
            self.collapsableVCFlow = nil
        }
    }
    
    func collapseCollapsibleVC(duration: TimeInterval = 1.0) {
        guard let collapsableVCFlow = collapsableVCFlow else {
            return
        }
        UIView.animate(withDuration: duration) {
            collapsableVCFlow.heightConstraint.constant = self.collapsedHeight
            collapsableVCFlow.view.layoutIfNeeded()
            self.view.layoutIfNeeded()
        }
    }
}

import UIKit

class MainTabBarController: UITabBarController, StickyViewControllerSupporting {
    var collapsedHeight: CGFloat = 60.0
    
    var collapsableVCFlow: ExpandableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
