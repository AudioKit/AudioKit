//
//  ViewController.swift
//  MidiMonitor
//
//  Created by Aurelius Prochazka on 4/29/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit
import Cocoa

class ViewController: NSViewController, AKMIDIListener {
    @IBOutlet private var outputTextView: NSTextView!
    @IBOutlet private var sourcePopUpButton: NSPopUpButton!
    var midi = AKMIDI()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        midi.openInput("Session 1")
        midi.addListener(self)

        sourcePopUpButton.removeAllItems()
        sourcePopUpButton.addItems(withTitles: midi.inputNames)
    }

    @IBAction func sourceChanged(_ sender: NSPopUpButton) {
        midi.closeAllInputs()
        midi.openInput(midi.inputNames[sender.indexOfSelectedItem])
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

    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIByte, channel: MIDIChannel) {
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
            self.outputTextView.string = "\(input)\n\(self.outputTextView.string!)"
        })
    }

    @IBAction func clearText(_ sender: Any) {
        DispatchQueue.main.async(execute: {
            self.outputTextView.string = ""
        })
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}
