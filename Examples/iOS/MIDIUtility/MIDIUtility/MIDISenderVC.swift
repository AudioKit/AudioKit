//
//  MIDISenderVC.swift
//  MIDIUtility
//
//  Created by Jeff Cooper, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation
import AudioKit
import UIKit

class MIDISenderVC: UIViewController {
    let midiOut = AudioKit.midi

    @IBOutlet var noteNumField: UITextField!
    @IBOutlet var noteVelField: UITextField!
    @IBOutlet var noteChanField: UITextField!
    @IBOutlet var ccField: UITextField!
    @IBOutlet var ccValField: UITextField!
    @IBOutlet var ccChanField: UITextField!
    @IBOutlet var sysexField: UITextView!

    var noteToSend: Int? {
        return Int(noteNumField.text!)
    }
    var velocityToSend: Int? {
        return Int(noteVelField.text!)
    }
    var noteChanToSend: Int {
        if noteChanField.text == nil || Int(noteChanField.text!) == nil {
            return 1
        }
        return Int(noteChanField.text!)! - 1
    }
    var ccToSend: Int? {
        return Int(ccField.text!)
    }
    var ccValToSend: Int? {
        return Int(ccValField.text!)
    }
    var ccChanToSend: Int {
        if ccChanField.text == nil || Int(ccChanField.text!) == nil {
            return 1
        }
        return Int(ccChanField.text!)! - 1
    }
    var sysexToSend: [Int]? {
        var data = [Int]()
        if sysexField.text == nil {
            return nil
        }
        let splitField = sysexField.text!.components(separatedBy: " ")
        for entry in splitField {
            let intVal = Int(entry)
            if intVal != nil && intVal! <= 247 && intVal! > -1 {
                data.append(intVal!)
            }
        }
        return data
    }
    override func viewDidLoad() {
        midiOut.openOutput()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func sendNotePressed(_ sender: UIButton) {
        if noteToSend != nil && velocityToSend != nil {
            AKLog("sending note: \(noteToSend!) - \(velocityToSend!)")
            let event = AKMIDIEvent(noteOn: MIDINoteNumber(noteToSend!), velocity: MIDIVelocity(velocityToSend!), channel: MIDIChannel(noteChanToSend))
            midiOut.sendEvent(event)
        } else {
            AKLog("error w note fields")
        }
    }
    @IBAction func sendCCPressed(_ sender: UIButton) {
        if ccToSend != nil && ccValToSend != nil {
            AKLog("sending cc: \(ccToSend!) - \(ccValToSend!)")
            let event = AKMIDIEvent(controllerChange: MIDIByte(ccToSend!), value: MIDIByte(ccValToSend!), channel: MIDIChannel(ccChanToSend))
            midiOut.sendEvent(event)
        } else {
            AKLog("error w cc fields")
        }
    }

    @IBAction func sendSysexPressed(_ sender: UIButton) {
        if sysexToSend != nil {
            var midiBytes = [MIDIByte]()
            for byte in sysexToSend! {
                midiBytes.append(MIDIByte(byte))
            }
            if midiBytes[0] != 240 || midiBytes.last != 247 || midiBytes.count < 2 {
                AKLog("bad sysex data - must start with 240 and end with 247")
                AKLog("parsed sysex: \(sysexToSend!)")
                return
            }
            AKLog("sending sysex \(sysexToSend!)")
            let event = AKMIDIEvent(data: midiBytes)
            midiOut.sendEvent(event)
        } else {
            AKLog("error w sysex field")
        }
    }

    @IBAction func receiveMIDIButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
class MIDIChannelField: UITextField, UITextFieldDelegate {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
    }
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        var startString = ""
        if (textField.text != nil) {
            startString += textField.text!
        }
        startString += string
        let limitNumber = Int(startString)
        if limitNumber == nil || limitNumber! > 16 || limitNumber! == 0 {
            return false
        } else {
            return true
        }
    }
}

class MIDINumberField: UITextField, UITextFieldDelegate {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
    }
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        var startString = ""
        if (textField.text != nil) {
            startString += textField.text!
        }
        startString += string
        let limitNumber = Int(startString)
        if limitNumber == nil || limitNumber! > 127 {
            return false
        } else {
            return true
        }
    }
}
