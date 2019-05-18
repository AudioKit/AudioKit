//
//  ViewController.swift
//  AUV3Example
//
//  Created by Jeff Cooper on 5/16/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var conductor = Conductor()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        conductor.setupRoute()
        try? conductor.start()
    }


}

