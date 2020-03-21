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

protocol Expandable: UIViewController {
    var minimisedView: UIView! { get }
    var expander: ViewControllerExpanding? { get set }
}

class ExpandableViewController: UIViewController {
    
    var heightConstraint: NSLayoutConstraint!
    var isEnlarged = false
    
    var tabController: MainTabBarController?
    
    let deviceHeight: CGFloat = UIScreen.main.bounds.height
    let collapsedHeight: CGFloat = 60.0
    let heightBeforeDismissal: CGFloat = 0.0
    
    private let childVC: Expandable
    private var minimisedView: UIView
    
    // MARK: - Animation properties
    
    enum state {
        case expanded
        case collapsed
    }
    
    var nextState: state {
        return isEnlarged ? .collapsed : .expanded
    }
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0
    
    init(withChildVC childVC: Expandable,
         minimisedView: UIView) {
        self.childVC = childVC
        self.minimisedView = minimisedView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(update))
        minimisedView.addGestureRecognizer(gestureRecognizer)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        view.addGestureRecognizer(panGestureRecognizer)
        view.clipsToBounds = true
        configureChildVC()
    }
    
    private func configureChildVC() {
        childVC.expander = self
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
    
    @objc private func handlePan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startInteractiveTransition(state: nextState, duration: 1)
        case .changed:
            let translation = recognizer.translation(in: childVC.view)
            var fractionComplete = translation.y / deviceHeight
            fractionComplete = isEnlarged ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            continueInteractiveTransition()
        default:
            break
        }
    }
    
    private func animateTransitionIfNeeded(state: state, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration,
                                                       dampingRatio: 1) {
                                                        switch state {
                                                        case .expanded:
                                                            self.heightConstraint.constant = self.deviceHeight - (self.tabController?.tabBar.frame.height ?? 0.0)
                                                            self.minimisedView.alpha = 0.0
                                                        case .collapsed:
                                                            self.heightConstraint.constant = self.collapsedHeight
                                                            self.minimisedView.alpha = 1.0
                                                        }
                                                        self.view.layoutIfNeeded()
                                                        self.tabController?.view.layoutIfNeeded()
            }
            
            frameAnimator.addCompletion { (_) in
                self.isEnlarged = !self.isEnlarged
                self.runningAnimations.removeAll()
            }
            
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
        }
    }
    
    private func startInteractiveTransition(state: state, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    private func updateInteractiveTransition(fractionCompleted: CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    private func continueInteractiveTransition() {
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
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
