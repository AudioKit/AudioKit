//
//  ViewController.swift
//  MidiMonitor
//
//  Created by Aurelius Prochazka on 4/29/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Cocoa
import AudioKit

class ViewController: NSViewController, AKMIDIListener {
    @IBOutlet var outputTextView: NSTextView!
    @IBOutlet var sourcePopUpButton: NSPopUpButton!
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
    
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                                       velocity: MIDIVelocity,
                                       channel: Int) {
        var newString = "Channel: \(channel+1) "
        newString.append("noteOn: \(noteNumber) velocity: \(velocity) ")
        updateText(newString)
    }
    
    func receivedMIDINoteOff(noteNumber: MIDINoteNumber,
                                        velocity: MIDIVelocity,
                                        channel: Int) {
        var newString = "Channel: \(channel+1) "
        newString.append("noteOff: \(noteNumber) velocity: \(velocity) ")
        updateText(newString)
    }
    
    func receivedMIDIController(_ controller: Int, value: Int, channel: Int) {
        var newString = "Channel: \(channel+1) "
        newString.append("controller: \(controller) value: \(value) ")
        updateText(newString)
    }
    
    func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
                                           pressure: Int,
                                           channel: Int) {
        var newString = "Channel: \(channel+1) "
        newString.append("midiAftertouchOnNote: \(noteNumber) pressure: \(pressure) ")
        updateText(newString)
    }
    
    func receivedMIDIAfterTouch(_ pressure: Int, channel: Int) {
        var newString = "Channel: \(channel+1) "
        newString.append("midiAfterTouch pressure: \(pressure) ")
        updateText(newString)
    }
    
    func receivedMIDIPitchWheel(_ pitchWheelValue: Int, channel: Int) {
        var newString = "Channel: \(channel+1) "
        newString.append("midiPitchWheel: \(pitchWheelValue) ")
        updateText(newString)
    }
    
    func receivedMIDIProgramChange(_ program: Int, channel: Int) {
        var newString = "Channel: \(channel+1) "
        newString.append("programChange: \(program) ")
        updateText(newString)
    }
    
    func receivedMIDISystemCommand(_ data: [UInt8]) {
        print("MIDI System Command: \(AKMIDISystemCommand(rawValue: data[0])!)")
        var newString = "MIDI System Command: \(AKMIDISystemCommand(rawValue: data[0])!) \n"
        for i in 0 ..< data.count {
            newString.append("\(data[i]) ")
        }
        updateText(newString)
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
