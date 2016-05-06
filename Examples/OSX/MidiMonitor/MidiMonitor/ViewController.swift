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
        sourcePopUpButton.addItemsWithTitles(midi.inputNames)
    }
    
    @IBAction func sourceChanged(sender: NSPopUpButton) {
        midi.closeAllInputs()
        midi.openInput(midi.inputNames[sender.indexOfSelectedItem])
    }
    
    func receivedMIDINoteOn(note: Int, velocity: Int, channel: Int) {
        var newString = "Channel: \(channel+1) "
        newString.appendContentsOf("noteOn: \(note) velocity: \(velocity) ")
        updateText(newString)
    }
    
    func receivedMIDINoteOff(note: Int, velocity: Int, channel: Int) {
        var newString = "Channel: \(channel+1) "
        newString.appendContentsOf("noteOff: \(note) velocity: \(velocity) ")
        updateText(newString)
    }
    
    func receivedMIDIController(controller: Int, value: Int, channel: Int) {
        var newString = "Channel: \(channel+1) "
        newString.appendContentsOf("controller: \(controller) value: \(value) ")
        updateText(newString)
    }
    
    func receivedMIDIAftertouchOnNote(note: Int, pressure: Int, channel: Int) {
        var newString = "Channel: \(channel+1) "
        newString.appendContentsOf("midiAftertouchOnNote: \(note) pressure: \(pressure) ")
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
            self.outputTextView.string = "\(input)\n\(self.outputTextView.string!)"
        })
    }
    
    @IBAction func clearText(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(), {
            self.outputTextView.string = ""
        })
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}
