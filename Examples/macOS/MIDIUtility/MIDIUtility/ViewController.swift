//
//  ViewController.swift
//  MIDIUtility
//
//  Created by Aurelius Prochazka and Jeff Cooper, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import Cocoa

class ViewController: NSViewController, AKMIDIListener {
    @IBOutlet private var outputTextView: NSTextView!
    @IBOutlet private var sourcePopUpButton: NSPopUpButton!
    var midi = AudioKit.midi

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        midi.openInput(name: "Session 1")
        midi.addListener(self)

        sourcePopUpButton.removeAllItems()
        sourcePopUpButton.addItem(withTitle: "(select input)")
        sourcePopUpButton.addItems(withTitles: midi.inputNames)
    }

    @IBAction func sourceChanged(_ sender: NSPopUpButton) {
        if sender.indexOfSelectedItem > 0 {
            midi.closeAllInputs()
            midi.openInput(name: midi.inputNames[sender.indexOfSelectedItem - 1])
        }
    }

    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel,
                            portID: MIDIUniqueID? = nil, offset: MIDITimeStamp = 0) {
        updateText("Channel: \(channel + 1) noteOn: \(noteNumber) velocity: \(velocity) ")
    }

    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel,
                             portID: MIDIUniqueID? = nil, offset: MIDITimeStamp = 0) {
        updateText("Channel: \(channel + 1) noteOff: \(noteNumber) velocity: \(velocity) ")
    }

    func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel,
                                portID: MIDIUniqueID? = nil, offset: MIDITimeStamp = 0) {
        updateText("Channel: \(channel + 1) controller: \(controller) value: \(value) ")
    }

    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord, channel: MIDIChannel,
                                portID: MIDIUniqueID? = nil, offset: MIDITimeStamp = 0) {
        updateText("Pitch Wheel on Channel: \(channel + 1) value: \(pitchWheelValue) ")
    }

    func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
                                pressure: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID? = nil,
                                offset: MIDITimeStamp = 0) {
        updateText("Channel: \(channel + 1) midiAftertouchOnNote: \(noteNumber) pressure: \(pressure) ")
    }

    func receivedMIDIAftertouch(_ pressure: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID? = nil,
                                offset: MIDITimeStamp = 0) {
        updateText("Channel: \(channel + 1) midiAftertouch pressure: \(pressure) ")
    }

    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID? = nil,
                                offset: MIDITimeStamp = 0) {
        updateText("Channel: \(channel + 1)  midiPitchWheel: \(pitchWheelValue)")
    }

    func receivedMIDIProgramChange(_ program: MIDIByte,
                                   channel: MIDIChannel,
                                   portID: MIDIUniqueID? = nil,
                                   offset: MIDITimeStamp = 0) {
        updateText("Channel: \(channel + 1) programChange: \(program)")
    }

    func receivedMIDISystemCommand(_ data: [MIDIByte],
                                   portID: MIDIUniqueID? = nil,
                                   offset: MIDITimeStamp = 0) {
        if let command = AKMIDISystemCommand(rawValue: data[0]) {
            updateText("")
            var newString = "MIDI System Command: \(command) \n"
            for i in 0 ..< data.count {
                let hexValue = String(format: "%02x", data[i])
                newString.append("\(hexValue) ")
            }
            updateText(newString)
        }
        updateText("received \(data.count) bytes of data")
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

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}
