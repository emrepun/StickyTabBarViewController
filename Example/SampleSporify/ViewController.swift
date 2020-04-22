//
//  ViewController.swift
//  SampleSporify
//
//  Created by Emre Havan on 20.03.20.
//  Copyright © 2020 Emre Havan. All rights reserved.
//

import UIKit
import StickyTabBarViewController

class ViewController: UIViewController {
    
    var tabController: StickyViewControllerSupportingTabBarController? {
        if let tabBarController = tabBarController as? StickyViewControllerSupportingTabBarController {
            return tabBarController
        }
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func tapped(_ sender: Any) {
        let viewControllerToStick = SampleChildViewController()
        tabController?.configureCollapsableChild(viewControllerToStick,
                                                 isFullScreenOnFirstAppearance: false)
    }
    
    @IBAction func removerTapped(_ sender: Any) {
        tabController?.removeCollapsableChild(animated: true)
    }
}

