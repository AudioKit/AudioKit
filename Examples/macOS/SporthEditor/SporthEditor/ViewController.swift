//
//  ViewController.swift
//  SporthEditor
//
//  Created by Aurelius Prochazka on 7/10/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet private var codeEditorTextView: NSTextView!

    var display: String {
        get { return codeEditorTextView.string ?? "" }
        set { codeEditorTextView?.string = newValue }
    }

    var path: String?

    var brain = SporthEditorBrain()

    @IBAction func run(_ sender: NSButton) {
        brain.run(display)
    }

    @IBAction func stop(_ sender: NSButton) {
        brain.stop()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let appDelegate = NSApplication.shared().delegate as? AppDelegate else {
            return
        }
        appDelegate.openControlsWindow(nil)
    }

    override func viewWillDisappear() {
        brain.stop()
    }
}
