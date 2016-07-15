//
//  ViewController.swift
//  SporthEditor
//
//  Created by Aurelius Prochazka on 7/10/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet var codeEditorTextView: NSTextView!
    
    var display: String {
        get { return (codeEditorTextView?.string)!  }
        set { codeEditorTextView?.string = newValue }
    }
    
    var path: String?
    
    var brain = SporthEditorBrain()
    
    @IBAction func run(sender: NSButton) {
        brain.run(display)
    }
    
    @IBAction func stop(sender: NSButton) {
        brain.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
