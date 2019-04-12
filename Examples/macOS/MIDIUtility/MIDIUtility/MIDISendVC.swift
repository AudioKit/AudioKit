//
//  MIDISendVC.swift
//  MIDIUtility
//
//  Created by Jeff Cooper, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//
import Foundation
import AudioKit
import Cocoa

class MIDISenderVC: NSViewController {
    let midiOut = AudioKit.midi

    @IBOutlet var noteNumField: NSTextField!
    @IBOutlet var noteVelField: NSTextField!
    @IBOutlet var noteChanField: NSTextField!
    @IBOutlet var ccField: NSTextField!
    @IBOutlet var ccValField: NSTextField!
    @IBOutlet var ccChanField: NSTextField!
    @IBOutlet var sysexField: NSTextView!

    var noteToSend: Int? {
        return Int(noteNumField.stringValue)
    }
    var velocityToSend: Int? {
        return Int(noteVelField.stringValue)
    }
    var noteChanToSend: Int {
        if Int(noteChanField.stringValue) == nil {
            return 1
        }
        return Int(noteChanField.stringValue)! - 1
    }
    var ccToSend: Int? {
        return Int(ccField.stringValue)
    }
    var ccValToSend: Int? {
        return Int(ccValField.stringValue)
    }
    var ccChanToSend: Int {
        if Int(ccChanField.stringValue) == nil {
            return 1
        }
        return Int(ccChanField.stringValue)! - 1
    }
    var sysexToSend: [Int]? {
        var data = [Int]()
        let splitField = sysexField.string.components(separatedBy: " ")
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
    }

    @IBAction func sendNotePressed(_ sender: NSButton) {
        if noteToSend != nil && velocityToSend != nil {
            AKLog("sending note: \(noteToSend!) - \(velocityToSend!)")
            let event = AKMIDIEvent(noteOn: MIDINoteNumber(noteToSend!), velocity: MIDIVelocity(velocityToSend!), channel: MIDIChannel(noteChanToSend))
            midiOut.sendEvent(event)
        } else {
            AKLog("error w note fields")
        }
    }
    @IBAction func sendCCPressed(_ sender: NSButton) {
        if ccToSend != nil && ccValToSend != nil {
            AKLog("sending cc: \(ccToSend!) - \(ccValToSend!)")
            let event = AKMIDIEvent(controllerChange: MIDIByte(ccToSend!), value: MIDIByte(ccValToSend!), channel: MIDIChannel(ccChanToSend))
            midiOut.sendEvent(event)
        } else {
            AKLog("error w cc fields")
        }
    }

    @IBAction func sendSysexPressed(_ sender: NSButton) {
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
            AKLog("sending \(midiBytes.count) bytes of sysex \(sysexToSend!)")
            let event = AKMIDIEvent(data: midiBytes)
            midiOut.sendEvent(event)
        } else {
            AKLog("error w sysex field")
        }
    }
}
class MIDIChannelFormatter: NumberFormatter {
    override func isPartialStringValid(_ partialStringPtr: AutoreleasingUnsafeMutablePointer<NSString>, proposedSelectedRange proposedSelRangePtr: NSRangePointer?, originalString origString: String, originalSelectedRange origSelRange: NSRange, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        let partialStr = partialStringPtr.pointee
        let charset = CharacterSet(charactersIn: "0123456789").inverted
        let result = partialStr.rangeOfCharacter(from: charset)
        if result.length > 0 || partialStr.intValue > 16 || partialStr == "0" || partialStr.length > 2 {
            return false
        }
        return true
    }
}

class MIDINumberFormatter: NumberFormatter {
    override func isPartialStringValid(_ partialStringPtr: AutoreleasingUnsafeMutablePointer<NSString>, proposedSelectedRange proposedSelRangePtr: NSRangePointer?, originalString origString: String, originalSelectedRange origSelRange: NSRange, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        let partialStr = partialStringPtr.pointee
        let charset = CharacterSet(charactersIn: "0123456789").inverted
        let result = partialStr.rangeOfCharacter(from: charset)
        if result.length > 0 || partialStr.intValue > 127 || partialStr == "0000" || partialStr.length > 3 {
            return false
        }
        return true
    }
}
