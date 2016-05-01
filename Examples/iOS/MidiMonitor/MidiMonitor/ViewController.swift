//
//  ViewController.swift
//  MidiMonitor
//
//  Created by Aurelius Prochazka on 1/29/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController, AKMIDIListener {
    @IBOutlet var outputTextView: UITextView!
    var midi = AKMIDI()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        midi.openInput("Session 1")
        midi.addListener(self)
    }
    
    func midiNoteOn(note: Int, velocity: Int, channel: Int) {
        var newString = "Channel: \(channel+1) "
        newString.appendContentsOf("noteOn: \(note) velocity: \(velocity) ")
        updateText(newString)
    }
    
    func midiNoteOff(note: Int, velocity: Int, channel: Int) {
        var newString = "Channel: \(channel+1) "
        newString.appendContentsOf("noteOff: \(note) velocity: \(velocity) ")
        updateText(newString)
    }
    
    func midiController(controller: Int, value: Int, channel: Int) {
        var newString = "Channel: \(channel+1) "
        newString.appendContentsOf("controller: \(controller) value: \(value) ")
        updateText(newString)
    }
    
    func midiAftertouchOnNote(note: Int, pressure: Int, channel: Int) {
        var newString = "Channel: \(channel+1) "
        newString.appendContentsOf("midiAftertouchOnNote: \(note) pressure: \(pressure) ")
        updateText(newString)
    }

    func midiAfterTouch(pressure: Int, channel: Int) {
        var newString = "Channel: \(channel+1) "
        newString.appendContentsOf("midiAfterTouch pressure: \(pressure) ")
        updateText(newString)
    }

    func midiPitchWheel(pitchWheelValue: Int, channel: Int) {
        var newString = "Channel: \(channel+1) "
        newString.appendContentsOf("midiPitchWheel: \(pitchWheelValue) ")
        updateText(newString)
    }

    func midiProgramChange(program: Int, channel: Int) {
        var newString = "Channel: \(channel+1) "
        newString.appendContentsOf("programChange: \(program) ")
        updateText(newString)
    }

    func midiSystemCommand(data: [UInt8]) {
        print("MIDI System Command: \(AKMIDISystemCommand(rawValue: data[0])!)")
        var newString = "MIDI System Command: \(AKMIDISystemCommand(rawValue: data[0])!) \n"
        for i in 0 ..< data.count {
            newString.appendContentsOf("\(data[i]) ")
        }
        updateText(newString)
    }
    func updateText(input: String) {
        dispatch_async(dispatch_get_main_queue(), {
           self.outputTextView.text = "\(input)\n\(self.outputTextView.text)"
        })
    }

    @IBAction func clearText(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(), {
            self.outputTextView.text = ""
        })
    }
}
