//
//  ControlsViewContoller.swift
//  SporthEditor
//
//  Created by Kanstantsin Linou on 7/14/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Cocoa

class ControlsViewContoller: NSViewController {
    let vc = NSApplication.shared().windows.first!.contentViewController as! ViewController

    @IBOutlet private var slider1: NSSlider!
    @IBOutlet private var slider2: NSSlider!
    @IBOutlet private var slider3: NSSlider!
    @IBOutlet private var slider4: NSSlider!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    @IBAction func trigger1(_ sender: NSButton) {
        print("triggering 1")
        vc.brain.generator?.trigger(0)
    }

    @IBAction func trigger2(_ sender: NSButton) {
        print("triggering 2")
        vc.brain.generator?.trigger(1)
    }

    @IBAction func trigger3(_ sender: NSButton) {
        print("triggering 3")
        vc.brain.generator?.trigger(2)
    }

    @IBAction func trigger4(_ sender: NSButton) {
        print("triggering 4")
        vc.brain.generator?.trigger(3)
    }

    @IBAction func toggleGate(_ sender: NSButton) {
        guard let identifier = sender.identifier, let index = Int(identifier) else {
            NSLog(Constants.Error.Identifier)
            return
        }
        if vc.brain.generator?.parameters[index] != 1 {
            vc.brain.generator?.parameters[index] = 1
        } else if vc.brain.generator?.parameters[index] != 0 {
            vc.brain.generator?.parameters[index] = 0
        }
    }

    @IBAction func updateParameter1(_ sender: NSSlider) {
        print("value 1 = \(sender.doubleValue)")
        vc.brain.generator?.parameters[0] = Double(sender.doubleValue)
    }
    @IBAction func updateParameter2(_ sender: NSSlider) {
        print("value 2 = \(sender.doubleValue)")
        vc.brain.generator?.parameters[1] = Double(sender.doubleValue)
    }
    @IBAction func updateParameter3(_ sender: NSSlider) {
        print("value 3 = \(sender.doubleValue)")
        vc.brain.generator?.parameters[2] = Double(sender.doubleValue)
    }
    @IBAction func updateParameter4(_ sender: NSSlider) {
        print("value 4 = \(sender.doubleValue)")
        vc.brain.generator?.parameters[3] = Double(sender.doubleValue)
    }
}
