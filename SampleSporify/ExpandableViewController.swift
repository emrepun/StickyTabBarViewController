//
//  ExpandableViewController.swift
//  SampleSporify
//
//  Created by Emre Havan on 20.03.20.
//  Copyright © 2020 Emre Havan. All rights reserved.
//

import UIKit

public protocol Expandable: UIViewController {
    var minimisedView: UIView { get }
    var expander: StickyViewControllerSupporting? { get set }
}

public extension Expandable {
    var expander: StickyViewControllerSupporting? {
        get {
            if let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? StickyViewControllerSupporting {
                return tabBarController
            } else {
                return nil
            }
        } set {
            
        }
    }
}

internal class ExpandableViewController: UIViewController {
    
    var heightConstraint: NSLayoutConstraint!
    var isEnlarged = false
    
    weak var tabController: StickyViewControllerSupporting?
    
    let deviceHeight: CGFloat = UIScreen.main.bounds.height
    var collapsedHeight: CGFloat
    var animationDuration: TimeInterval
    
    var minimisedView: UIView
    
    // MARK: - Animation properties
    
    lazy var isBeginningUpwards = !isEnlarged
    
    var runningAnimation: UIViewPropertyAnimator?
    var animationProgressWhenInterrupted: CGFloat = 0
    
    private let childVC: Expandable
    
    init(withChildVC childVC: Expandable,
         collapsedHeight: CGFloat,
         animationDuration: TimeInterval,
         minimisedView: UIView) {
        self.childVC = childVC
        self.collapsedHeight = collapsedHeight
        self.animationDuration = animationDuration
        self.minimisedView = minimisedView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(enlargeWithTap))
        minimisedView.addGestureRecognizer(gestureRecognizer)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        view.addGestureRecognizer(panGestureRecognizer)
        view.clipsToBounds = true
        configureChildVC()
    }
    
    func collapse() {
        animateTransitionIfNeeded(isEnlarging: !isEnlarged, duration: animationDuration)
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
        if runningAnimation == nil {
            runningAnimation = UIViewPropertyAnimator(duration: duration,
                                                       dampingRatio: 1) {
                                                        if isEnlarging {
                                                            self.heightConstraint.constant = self.deviceHeight - (self.tabController?.tabBar.frame.height ?? 0.0)
                                                            self.minimisedView.alpha = 0.0
                                                        } else {
                                                            self.heightConstraint.constant = self.collapsedHeight
                                                            self.minimisedView.alpha = 1.0
                                                        }
                                                        self.view.setNeedsLayout()
                                                        self.tabController?.view.setNeedsLayout()
                                                        self.view.layoutIfNeeded()
                                                        self.tabController?.view.layoutIfNeeded()
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
    }
    
    private func startInteractiveTransition(isEnlarging: Bool, duration: TimeInterval) {
        if runningAnimation == nil {
            animateTransitionIfNeeded(isEnlarging: isEnlarging, duration: duration)
        }
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
