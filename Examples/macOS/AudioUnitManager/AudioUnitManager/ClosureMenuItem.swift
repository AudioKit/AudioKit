//
//  ClosureMenuItem.swift
//  AudioUnitManager
//
//  Created by Ryan Francesconi.
//  Copyright © 2018 AudioKit. All rights reserved.
//
import Cocoa

/**
 Subclassing NSMenuItem to be able to set their actions with closures.
 Has the additional upside of settings the targets correctly
 */
class ClosureMenuItem: NSMenuItem {
    var actionClosure: () -> Void = {}

    init(title: String, closure: @escaping () -> Void, keyEquivalent: String = "") {
        self.actionClosure = closure
        super.init(title: title, action: #selector(self.action(_:)), keyEquivalent: keyEquivalent)
        self.target = self
    }

    required init(coder aDecoder: NSCoder) { // for using view from interface builder / xib
        super.init(coder: aDecoder)
    }

    @objc func action(_ sender: NSMenuItem) {
        self.actionClosure()
    }
}
