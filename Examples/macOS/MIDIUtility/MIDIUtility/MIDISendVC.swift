//
//  MIDISendVC.swift
//  MIDIUtility
//
//  Created by Jeff Cooper on 9/13/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//
import Foundation
import AudioKit
import Cocoa

class MIDISenderVC: NSViewController {
    let midiOut = AKMIDI()
    
    @IBOutlet var noteNumField: NSTextField!
    @IBOutlet var noteVelField: NSTextField!
    @IBOutlet var noteChanField: NSTextField!
    @IBOutlet var ccField: NSTextField!
    @IBOutlet var ccValField: NSTextField!
    @IBOutlet var ccChanField: NSTextField!
    @IBOutlet var sysexField: NSTextView!
    
    var noteToSend:Int? {
        return Int(noteNumField.stringValue)
    }
    var velocityToSend:Int? {
        return Int(noteVelField.stringValue)
    }
    var noteChanToSend:Int {
        if Int(noteChanField.stringValue) == nil {
            return 1
        }
        return Int(noteChanField.stringValue)! - 1
    }
    var ccToSend:Int? {
        return Int(ccField.stringValue)
    }
    var ccValToSend:Int? {
        return Int(ccValField.stringValue)
    }
    var ccChanToSend:Int {
        if Int(ccChanField.stringValue) == nil {
            return 1
        }
        return Int(ccChanField.stringValue)! - 1
    }
    var sysexToSend:[Int]?{
        var data = [Int]()
        let splitField = sysexField.string.components(separatedBy: " ")
        for entry in splitField {
            let intVal = Int(entry)
            if intVal != nil {
                data.append(intVal!)
            }
        }
        return data
    }
    override func viewDidLoad() {
        midiOut.openOutput()
    }
    
    @IBAction func sendNotePressed(_ sender: NSButton) {
        if noteToSend != nil && velocityToSend != nil {
            Swift.print("sending note: \(noteToSend!) - \(velocityToSend!)")
            let event = AKMIDIEvent(noteOn: MIDINoteNumber(noteToSend!), velocity: MIDIVelocity(velocityToSend!), channel: MIDIChannel(noteChanToSend))
            midiOut.sendEvent(event)
        }else{
            print("error w note fields")
        }
    }
    @IBAction func sendCCPressed(_ sender: NSButton) {
        if ccToSend != nil && ccValToSend != nil{
            Swift.print("sending cc: \(ccToSend!) - \(ccValToSend!)")
            let event = AKMIDIEvent(controllerChange: MIDIByte(ccToSend!), value: MIDIByte(ccValToSend!), channel: MIDIChannel(ccChanToSend))
            midiOut.sendEvent(event)
        }else{
            print("error w cc fields")
        }
    }
    
    @IBAction func sendSysexPressed(_ sender: NSButton) {
        if sysexToSend != nil {
            Swift.print("sending sysex \(sysexToSend!)")
            var midiBytes = [MIDIByte]()
            for byte in sysexToSend!{
                midiBytes.append(MIDIByte(byte))
            }
            let event = AKMIDIEvent(data: midiBytes)
            midiOut.sendEvent(event)
        }else{
            print("error w sysex field")
        }
    }
}
class MIDIChannelField : NSTextField, NSTextFieldDelegate {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
    }
    func textField(_ textField: NSTextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        var startString = ""
        startString += textField.stringValue
        startString += string
        let limitNumber = Int(startString)
        if limitNumber == nil || limitNumber! > 16 || limitNumber! == 0
        {
            return false
        } else {
            return true
        }
    }
}

class MIDINumberField : NSTextField, NSTextFieldDelegate {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
    }
    func textField(_ textField: NSTextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        var startString = ""
        startString += textField.stringValue
        startString += string
        let limitNumber = Int(startString)
        if limitNumber == nil || limitNumber! > 127
        {
            return false
        } else {
            return true
        }
    }
}
