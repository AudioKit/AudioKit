//
//  PlayerDemoWindowController.swift
//  PlayerDemo
//
//  Created by Ryan Francesconi on 7/26/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Cocoa

class PlayerDemoWindowController: NSWindowController {
    var controller = PlayerDemoViewController()

    convenience init() {
        self.init(windowNibName: "PlayerDemoWindowController")
        window?.appearance = NSAppearance(named: .vibrantDark)
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        contentViewController = controller
    }
}
