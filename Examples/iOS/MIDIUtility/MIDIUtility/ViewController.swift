//
//  ViewController.swift
//  MIDIUtility
//
//  Created by Aurelius Prochazka, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import UIKit

class ViewController: UIViewController, AKMIDIListener {
    @IBOutlet private var outputTextView: UITextView!
    var midi = AudioKit.midi
    var senderVC: MIDISenderVC?

    override func viewDidLoad() {
        super.viewDidLoad()
        midi.openInput()
        midi.addListener(self)
        senderVC = self.storyboard?.instantiateViewController(withIdentifier: "MIDISenderVC") as? MIDISenderVC
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

    func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
                                pressure: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID? = nil,
                                offset: MIDITimeStamp = 0) {
        updateText("Channel: \(channel + 1) AftertouchOnNote: \(noteNumber) pressure: \(pressure) ")
    }

    func receivedMIDIAftertouch(_ pressure: MIDIByte, channel: MIDIChannel,
                                portID: MIDIUniqueID? = nil, offset: MIDITimeStamp = 0) {
        updateText("Channel: \(channel + 1) Aftertouch pressure: \(pressure) ")
    }

    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord, channel: MIDIChannel,
                                portID: MIDIUniqueID? = nil, offset: MIDITimeStamp = 0) {
        updateText("Channel: \(channel + 1)  PitchWheel: \(pitchWheelValue)")
    }

    func receivedMIDIProgramChange(_ program: MIDIByte, channel: MIDIChannel,
                                   portID: MIDIUniqueID? = nil, offset: MIDITimeStamp = 0) {
        updateText("Channel: \(channel + 1) programChange: \(program)")
    }

    func receivedMIDISystemCommand(_ data: [MIDIByte], portID: MIDIUniqueID? = nil, offset: MIDITimeStamp = 0) {
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
    @IBAction func sendMIDIButtonPressed(_ sender: UIButton) {
        present(senderVC!, animated: true, completion: nil)
    }
}
