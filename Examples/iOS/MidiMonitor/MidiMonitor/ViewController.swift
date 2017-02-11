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

        midi.openInput()
        midi.addListener(self)
    }

    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        var newString = "Channel: \(channel+1) "
        newString.append("noteOn: \(noteNumber) velocity: \(velocity) ")
        updateText(newString)
    }

    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        var newString = "Channel: \(channel+1) "
        newString.append("noteOff: \(noteNumber) velocity: \(velocity) ")
        updateText(newString)
    }

    func receivedMIDIController(_ controller: Int, value: Int, channel: MIDIChannel) {
        var newString = "Channel: \(channel+1) "
        newString.append("controller: \(controller) value: \(value) ")
        updateText(newString)
    }

    func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
                                pressure: Int,
                                channel: MIDIChannel) {
        var newString = "Channel: \(channel+1) "
        newString.append("midiAftertouchOnNote: \(noteNumber) pressure: \(pressure) ")
        updateText(newString)
    }

    func receivedMIDIAfterTouch(_ pressure: Int, channel: MIDIChannel) {
        var newString = "Channel: \(channel+1) "
        newString.append("midiAfterTouch pressure: \(pressure) ")
        updateText(newString)
    }

    func receivedMIDIPitchWheel(_ pitchWheelValue: Int, channel: MIDIChannel) {
        var newString = "Channel: \(channel+1) "
        newString.append("midiPitchWheel: \(pitchWheelValue) ")
        updateText(newString)
    }

    func receivedMIDIProgramChange(_ program: Int, channel: MIDIChannel) {
        var newString = "Channel: \(channel+1) "
        newString.append("programChange: \(program) ")
        updateText(newString)
    }

    func receivedMIDISystemCommand(_ data: [MIDIByte]) {
        print("MIDI System Command: \(AKMIDISystemCommand(rawValue: data[0])!)")
        var newString = "MIDI System Command: \(AKMIDISystemCommand(rawValue: data[0])!) \n"
        for i in 0 ..< data.count {
            newString.append("\(data[i]) ")
        }
        updateText(newString)
    }

    func updateText(_ input: String) {
        DispatchQueue.main.async(execute: {
            self.outputTextView.text = "\(input)\n\(self.outputTextView.text!)"
        })
    }

    @IBAction func clearText(_ sender: AnyObject) {
        DispatchQueue.main.async(execute: {
            self.outputTextView.text = ""
        })
    }
}
