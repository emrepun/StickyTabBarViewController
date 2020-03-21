//
//  SampleChildViewController.swift
//  SampleSporify
//
//  Created by Emre Havan on 20.03.20.
//  Copyright © 2020 Emre Havan. All rights reserved.
//

import UIKit

class SampleChildViewController: UIViewController {
    
    var expander: ViewControllerExpanding?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func shutDownTapped(_ sender: Any) {
        expander?.dismiss()
    }
}
