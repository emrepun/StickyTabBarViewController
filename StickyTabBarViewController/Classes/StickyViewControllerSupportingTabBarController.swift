//
//  StickyViewControllerSupportingTabBarController.swift
//  StickyTabBarViewController
//
//  Created by Emre Havan on 20.03.20.
//  Copyright © 2020 Emre Havan. All rights reserved.
//
import UIKit

public protocol StickyViewControllerSupporting: UITabBarController {
    var collapsedHeight: CGFloat { get set }
    var animationDuration: TimeInterval { get set }
    var childViewController: Expandable? { get }
    func configureCollapsableChild(_ childViewController: Expandable, isFullScreenOnFirstAppearance: Bool)
    func removeCollapsableChild(animated: Bool)
    func collapseChild()
    func expandChild()
}

open class StickyViewControllerSupportingTabBarController: UITabBarController, StickyViewControllerSupporting {
    
    // MARK: - Public properties
    public var collapsedHeight: CGFloat = 50.0
    public var animationDuration: TimeInterval = 0.5
    public var childViewController: Expandable?
    
    // MARK: - Private properties
    private var collapsableVCFlow: ExpandableViewController?
    
    // MARK: - Public API
    
    /// Prepares View Controller to be embedded as a child (wrapped in another internal View Controller)
    /// - Parameter childViewController: A View Controller conforming to `Expandable` protocol
    /// - Parameter isFullScreenOnFirstAppearance: A boolean to determine if child view controller should be presented
    /// full screen on first configuration
    final public func configureCollapsableChild(_ childViewController: Expandable,
                                                isFullScreenOnFirstAppearance: Bool) {
        guard collapsableVCFlow == nil else {
            return
        }
        childViewController.loadViewIfNeeded()
        childViewController.container = self
        self.childViewController = childViewController
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
        
        if isFullScreenOnFirstAppearance {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.collapsableVCFlow!.expand()
            }
        }
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
                    self.removeStickyViewController()
                }
            }
        } else {
            removeStickyViewController()
        }
    }
    
    /// Collapse already presented child
    final public func collapseChild() {
        guard let collapsableVCFlow = collapsableVCFlow else {
            return
        }
        collapsableVCFlow.collapse()
    }
    
    /// Expand already presented child
    final public func expandChild() {
        guard let collapsableVCFlow = collapsableVCFlow else {
            return
        }
        collapsableVCFlow.expand()
    }
    
    // MARK: - Private API
    
    private func removeStickyViewController() {
        guard let collapsableVCFlow = collapsableVCFlow else {
            return
        }
        collapsableVCFlow.view.removeFromSuperview()
        collapsableVCFlow.removeFromParent()
        self.collapsableVCFlow = nil
        self.childViewController = nil
    }
}
