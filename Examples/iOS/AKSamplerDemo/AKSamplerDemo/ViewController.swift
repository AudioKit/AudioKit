//
//  ViewController.swift
//  AKSamplerDemo
//
//  Created by Shane Dunne, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController {

    let conductor = Conductor.shared
    var isPlaying = false

    override func viewDidLoad() {
        super.viewDidLoad()

        conductor.midi.addListener(self)
    }

    @IBAction func toggleSound(_ sender: UIButton) {
        if isPlaying {
            conductor.stopNote(note: 72, channel: 0)
            isPlaying = false
            sender.setTitle("Play", for: .normal)
        } else {
            conductor.playNote(note: 72, velocity: 100, channel: 0)
            isPlaying = true
            sender.setTitle("Stop", for: .normal)
        }
    }
    @IBAction func preset1(_ sender: Any) {
        conductor.loadSamples(byIndex: 0)
    }
    @IBAction func preset2(_ sender: Any) {
        conductor.loadSamples(byIndex: 1)
    }
    @IBAction func preset3(_ sender: Any) {
        conductor.loadSamples(byIndex: 2)
    }
    @IBAction func preset4(_ sender: Any) {
        conductor.loadSamples(byIndex: 3)
    }
}

extension ViewController: AKMIDIListener {

    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        DispatchQueue.main.async {
            self.conductor.playNote(note: noteNumber, velocity: velocity, channel: channel)
        }
    }

    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        DispatchQueue.main.async {
            self.conductor.stopNote(note: noteNumber, channel: channel)
        }
    }

    // MIDI Controller input
    func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel) {
        //print("Channel: \(channel+1) controller: \(controller) value: \(value)")
        conductor.controller(controller, value: value)
    }

    // MIDI Pitch Wheel
    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord, channel: MIDIChannel) {
        conductor.pitchBend(pitchWheelValue)
    }

    // After touch
    func receivedMIDIAfterTouch(_ pressure: MIDIByte, channel: MIDIChannel) {
        conductor.afterTouch(pressure)
    }

    func receivedMIDISystemCommand(_ data: [MIDIByte]) {
        // do nothing: silence superclass's log chatter
    }

    // MIDI Setup Change
    func receivedMIDISetupChange() {
        print("midi setup change, midi.inputNames: \(conductor.midi.inputNames)")
        let inputNames = conductor.midi.inputNames
        inputNames.forEach { inputName in
            conductor.midi.openInput(inputName)
        }
    }

}
