//
//  ViewController.swift
//  macOSDevelopment
//
//  Created by Aurelius Prochazka on 12/5/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import AudioKit
import AudioKitUI
import Cocoa

class ViewController: NSViewController {

    // Default controls
    
    @IBOutlet weak var button1: NSButton!
    @IBOutlet weak var sliderLabel1: NSTextField!
    @IBOutlet weak var slider1: NSSlider!
    @IBOutlet weak var sliderLabel2: NSTextField!
    @IBOutlet weak var slider2: NSSlider!
    @IBOutlet private var outputTextView: NSTextView!
    
    // Define components
    var oscillator = AKOscillator()
    var booster = AKBooster()

    override func viewDidLoad() {
        super.viewDidLoad()
        sliderLabel1.stringValue = "Gain"
        sliderLabel2.stringValue = "Ramp Time"
        button1.stringValue = "Start"
    }
    
    @IBAction func start(_ sender: NSButton) {
        
        oscillator >>> booster
        booster.gain = 0
        
        AudioKit.output = booster
        AudioKit.start()
        sender.isEnabled = false
        
    }
    
    
    @IBAction func button1(_ sender: NSButton) {
        if oscillator.isPlaying {
            oscillator.stop()
            button1.stringValue = "Start"
            updateText("Stopped")
        } else {
            oscillator.start()
            button1.stringValue = "Stop"
            updateText("Playing \(Int(oscillator.frequency))Hz")
        }
    }
    @IBAction func slid1(_ sender: NSSlider) {
        booster.gain = Double(slider1.floatValue)
        updateText("booster gain = \(booster.gain)")
    }
    
    @IBAction func slid2(_ sender: NSSlider) {
        booster.rampTime = Double(slider2.floatValue)
        updateText("booster ramp time = \(booster.rampTime)")
    }
    
    func updateText(_ input: String) {
        DispatchQueue.main.async(execute: {
            self.outputTextView.string = "\(input)\n\(self.outputTextView.string)"
        })
    }
    
    @IBAction func clearText(_ sender: Any) {
        DispatchQueue.main.async(execute: {
            self.outputTextView.string = ""
        })
    }
}
