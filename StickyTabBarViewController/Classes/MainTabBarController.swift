//
//  MainTabBarController.swift
//  SampleSporify
//
//  Created by Emre Havan on 20.03.20.
//  Copyright © 2020 Emre Havan. All rights reserved.
//
import UIKit

public protocol StickyViewControllerSupporting: UITabBarController {
    var collapsedHeight: CGFloat { get set }
    var animationDuration: TimeInterval { get set }
    func configureCollapsableChild(_ childViewController: Expandable)
    func removeCollapsableChild(animated: Bool)
    func collapseChild()
}

open class StickyViewControllerSupportingTabBarController: UITabBarController, StickyViewControllerSupporting {
    
    // MARK: - Public properties
    public var collapsedHeight: CGFloat = 50.0
    public var animationDuration: TimeInterval = 0.5
    
    // MARK: - Private properties
    private var collapsableVCFlow: ExpandableViewController?
    
    // MARK: - Public API
    
    /// Prepares View Controller to be embedded as a child (wrapped in another internal View Controller)
    /// - Parameter childViewController: A View Controller conforming to `Expandable` protocol
    final public func configureCollapsableChild(_ childViewController: Expandable) {
        guard collapsableVCFlow == nil else {
            return
        }
        childViewController.loadView()
        childViewController.container = self
        collapsableVCFlow = ExpandableViewController(withChildVC: childViewController,
                                                     collapsedHeight: collapsedHeight,
                                                     animationDuration: animationDuration)
        
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
    
    /// Removes child View Controller from view hierarchy and parent
    /// - Parameter animated: Whether or not the removal should be animated
    final public func removeCollapsableChild(animated: Bool) {
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
    
    /// Collapse already presented child
    final public func collapseChild() {
        guard let collapsableVCFlow = collapsableVCFlow else {
            return
        }
        collapsableVCFlow.collapse()
    }
}
