//
//  ExpandableViewController.swift
//  StickyTabBarViewController
//
//  Created by Emre Havan on 20.03.20.
//  Copyright © 2020 Emre Havan. All rights reserved.
//

import UIKit

public protocol Expandable: UIViewController {
    var minimisedView: UIView { get }
    var container: StickyViewControllerSupporting? { get set }
}

public extension Expandable {
    weak var container: StickyViewControllerSupporting? {
        get { tabBarController as? StickyViewControllerSupporting }
        
        set { /* No steps needed */ }
    }
}

class ExpandableViewController: UIViewController {
    
    // MARK: - Internal properties
    
    var heightConstraint: NSLayoutConstraint!
    var isEnlarged = false
    
    weak var tabController: StickyViewControllerSupporting?
    
    let deviceHeight: CGFloat = UIScreen.main.bounds.height
    var collapsedHeight: CGFloat
    var animationDuration: TimeInterval
    
    // MARK: - Private properties
    
    private var minimisedView: UIView
    private let childVC: Expandable
    
    // MARK: - Animation properties
    
    lazy var isBeginningUpwards = !isEnlarged
    var runningAnimation: UIViewPropertyAnimator?
    var animationProgressWhenInterrupted: CGFloat = 0
    
    // MARK: - Initialisers
    
    init(withChildVC childVC: Expandable,
         collapsedHeight: CGFloat,
         animationDuration: TimeInterval) {
        self.childVC = childVC
        self.collapsedHeight = collapsedHeight
        self.animationDuration = animationDuration
        self.minimisedView = childVC.minimisedView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(enlargeWithTap))
        minimisedView.addGestureRecognizer(gestureRecognizer)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        view.addGestureRecognizer(panGestureRecognizer)
        view.clipsToBounds = true
        configureChildVC()
    }
    
    // MARK: - Internal API
    
    func expand() {
        animateTransitionIfNeeded(isEnlarging: true, duration: animationDuration)
    }
    
    func collapse() {
        animateTransitionIfNeeded(isEnlarging: false, duration: animationDuration)
    }
    
    // MARK: - Private API
    
    private func configureChildVC() {
        addChild(childVC)
        view.addSubview(childVC.view)
        childVC.view.frame = self.view.bounds
        childVC.didMove(toParent: self)
    }
    
    @objc private func enlargeWithTap(recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            animateTransitionIfNeeded(isEnlarging: !isEnlarged, duration: animationDuration)
        default:
            break
        }
    }
    
    @objc private func handlePan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            let velocity = recognizer.velocity(in: childVC.view)
            isBeginningUpwards = isDirectionUpwards(for: velocity)
            startInteractiveTransition(isEnlarging: !isEnlarged, duration: animationDuration)
        case .changed:
            let velocity = recognizer.velocity(in: childVC.view)
            isBeginningUpwards = isDirectionUpwards(for: velocity)
            let translation = recognizer.translation(in: childVC.view)
            var fractionComplete = translation.y / deviceHeight
            fractionComplete = isEnlarged ? fractionComplete : -fractionComplete
            if runningAnimation?.isReversed ?? false {
                fractionComplete = -fractionComplete
            }
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            continueInteractiveTransition(isReversed: shouldReverseAnimation())
        default:
            break
        }
    }
    
    private func shouldReverseAnimation() -> Bool {
        if isEnlarged && !isBeginningUpwards {
            return true
        } else if !isEnlarged && isBeginningUpwards {
            return true
        }
        return false
    }
    
    private func isDirectionUpwards(for velocity: CGPoint) -> Bool {
        return velocity.y > 0
    }
    
    private func animateTransitionIfNeeded(isEnlarging: Bool, duration: TimeInterval) {
        guard
            runningAnimation == nil,
            let tabController = tabController,
            // Make sure we are not trying to animate to same state by checking if the child is already in the same
            // state of passed `isEnlarging` value.
            self.isEnlarged != isEnlarging else {
                return
        }
        
        runningAnimation = UIViewPropertyAnimator(
            duration: duration,
            dampingRatio: 1) {
                if isEnlarging {
                    self.heightConstraint.constant = self.deviceHeight - tabController.tabBar.frame.height
                    self.minimisedView.alpha = 0.0
                } else {
                    self.heightConstraint.constant = self.collapsedHeight
                    self.minimisedView.alpha = 1.0
                }
                self.view.setNeedsLayout()
                tabController.view.setNeedsLayout()
                self.view.layoutIfNeeded()
                tabController.view.layoutIfNeeded()
        }
        
        runningAnimation?.addCompletion { (position) in
            switch position {
            case .end:
                self.isEnlarged = !self.isEnlarged
            default:
                ()
            }
            self.runningAnimation = nil
        }
        
        runningAnimation?.startAnimation()
    }
    
    private func startInteractiveTransition(isEnlarging: Bool, duration: TimeInterval) {
        animateTransitionIfNeeded(isEnlarging: isEnlarging, duration: duration)
        runningAnimation?.pauseAnimation()
        animationProgressWhenInterrupted = runningAnimation?.fractionComplete ?? 0.0
    }
    
    private func updateInteractiveTransition(fractionCompleted: CGFloat) {
        runningAnimation?.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
    }
    
    private func continueInteractiveTransition(isReversed: Bool) {
        runningAnimation?.isReversed = isReversed
        runningAnimation?.continueAnimation(withTimingParameters: nil, durationFactor: 0)
    }
}
