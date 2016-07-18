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
    
    func receivedMIDINoteOn(noteNumber noteNumber: MIDINoteNumber,
                                       velocity: MIDIVelocity,
                                       channel: Int) {
        var newString = "Channel: \(channel+1) "
        newString.appendContentsOf("noteOn: \(noteNumber) velocity: \(velocity) ")
        updateText(newString)
    }
    
    func receivedMIDINoteOff(noteNumber noteNumber: MIDINoteNumber,
                                        velocity: MIDIVelocity,
                                        channel: Int) {
        var newString = "Channel: \(channel+1) "
        newString.appendContentsOf("noteOff: \(noteNumber) velocity: \(velocity) ")
        updateText(newString)
    }
    
    func receivedMIDIController(controller: Int, value: Int, channel: Int) {
        var newString = "Channel: \(channel+1) "
        newString.appendContentsOf("controller: \(controller) value: \(value) ")
        updateText(newString)
    }
    
    func receivedMIDIAftertouch(noteNumber noteNumber: MIDINoteNumber,
                                           pressure: Int,
                                           channel: Int) {
        var newString = "Channel: \(channel+1) "
        newString.appendContentsOf("midiAftertouchOnNote: \(noteNumber) pressure: \(pressure) ")
        updateText(newString)
    }

    func receivedMIDIAfterTouch(pressure: Int, channel: Int) {
        var newString = "Channel: \(channel+1) "
        newString.appendContentsOf("midiAfterTouch pressure: \(pressure) ")
        updateText(newString)
    }

    func receivedMIDIPitchWheel(pitchWheelValue: Int, channel: Int) {
        var newString = "Channel: \(channel+1) "
        newString.appendContentsOf("midiPitchWheel: \(pitchWheelValue) ")
        updateText(newString)
    }

    func receivedMIDIProgramChange(program: Int, channel: Int) {
        var newString = "Channel: \(channel+1) "
        newString.appendContentsOf("programChange: \(program) ")
        updateText(newString)
    }

    func receivedMIDISystemCommand(data: [UInt8]) {
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
