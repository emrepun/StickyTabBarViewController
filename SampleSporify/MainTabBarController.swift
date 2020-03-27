//
//  MainTabBarController.swift
//  SampleSporify
//
//  Created by Emre Havan on 20.03.20.
//  Copyright © 2020 Emre Havan. All rights reserved.
//
import UIKit

public protocol StickyViewControllerSupporting: UITabBarController {
    var collapsableVCFlow: ExpandableViewController? { get set }
    var collapsedHeight: CGFloat { get }
    var animationDuration: TimeInterval { get }
    func configureCollapsedTrainingView(withChildViewController childViewController: Expandable)
    func removeCollapsibleView(animated: Bool)
    func collapseCollapsibleVC()
}

public class StickyViewControllerSupportingTabBarController: UITabBarController, StickyViewControllerSupporting {
    public var collapsableVCFlow: ExpandableViewController?
    public var collapsedHeight: CGFloat = 50.0
    public var animationDuration: TimeInterval = 0.5
    
    final public func configureCollapsedTrainingView(withChildViewController childViewController: Expandable) {
        guard collapsableVCFlow == nil else {
            return
        }
        childViewController.loadView()
        childViewController.expander = self
        collapsableVCFlow = ExpandableViewController(withChildVC: childViewController,
                                                     collapsedHeight: collapsedHeight,
                                                     animationDuration: animationDuration,
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
    
    final public func removeCollapsibleView(animated: Bool) {
        guard let collapsableVCFlow = collapsableVCFlow else {
            return
        }
        if animated {
            UIView.animate(withDuration: animationDuration,
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
    
    final public func collapseCollapsibleVC() {
        guard let collapsableVCFlow = collapsableVCFlow else {
            return
        }
        collapsableVCFlow.collapse()
    }
}

class MainTabBarController: StickyViewControllerSupportingTabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
