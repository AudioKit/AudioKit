//
//  ViewController.swift
//  MidiMonitor
//
//  Created by Aurelius Prochazka on 1/29/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit
import UIKit

class ViewController: UIViewController, AKMIDIListener {
    @IBOutlet private var outputTextView: UITextView!
    var midi = AKMIDI()

    override func viewDidLoad() {
        super.viewDidLoad()
        midi.openInput()
        midi.addListener(self)
    }

    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        updateText("Channel: \(channel + 1) noteOn: \(noteNumber) velocity: \(velocity) ")
    }

    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        updateText("Channel: \(channel + 1) noteOff: \(noteNumber) velocity: \(velocity) ")
    }

    func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel) {
        updateText("Channel: \(channel + 1) controller: \(controller) value: \(value) ")
    }

    func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
                                pressure: MIDIByte,
                                channel: MIDIChannel) {
        updateText("Channel: \(channel + 1) midiAftertouchOnNote: \(noteNumber) pressure: \(pressure) ")
    }

    func receivedMIDIAfterTouch(_ pressure: MIDIByte, channel: MIDIChannel) {
        updateText("Channel: \(channel + 1) midiAfterTouch pressure: \(pressure) ")
    }

    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord, channel: MIDIChannel) {
        updateText("Channel: \(channel + 1)  midiPitchWheel: \(pitchWheelValue)")
    }

    func receivedMIDIProgramChange(_ program: MIDIByte, channel: MIDIChannel) {
        updateText("Channel: \(channel + 1) programChange: \(program)")
    }

    func receivedMIDISystemCommand(_ data: [MIDIByte]) {
        if let command = AKMIDISystemCommand(rawValue: data[0]) {
            var newString = "MIDI System Command: \(command) \n"
            for i in 0 ..< data.count {
                newString.append("\(data[i]) ")
            }
            updateText(newString)
        }
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
