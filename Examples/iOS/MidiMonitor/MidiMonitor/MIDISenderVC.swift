//
//  MIDISenderVC.swift
//  MidiMonitor
//
//  Created by Jeff Cooper on 9/11/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Foundation
import AudioKit
import UIKit

class MIDISenderVC: UIViewController {
    let midiOut = AKMIDI()
    
    @IBOutlet var noteNumField: UITextField!
    @IBOutlet var noteVelField: UITextField!
    @IBOutlet var noteChanField: UITextField!
    @IBOutlet var ccField: UITextField!
    @IBOutlet var ccValField: UITextField!
    @IBOutlet var ccChanField: UITextField!
    @IBOutlet var sysexField: UITextView!
    
    var noteToSend:Int? {
        return Int(noteNumField.text!)
    }
    var velocityToSend:Int? {
        return Int(noteVelField.text!)
    }
    var noteChanToSend:Int? {
        return Int(noteChanField.text!)
    }
    var ccToSend:Int? {
        return Int(ccField.text!)
    }
    var ccValToSend:Int? {
        return Int(ccValField.text!)
    }
    var ccChanToSend:Int? {
        return Int(ccChanField.text!)
    }
    var sysexToSend:[Int]?{
        var data = [Int]()
        if sysexField.text == nil {
            return nil
        }
        let splitField = sysexField.text!.components(separatedBy: " ")
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
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func sendNotePressed(_ sender: UIButton) {
        if noteToSend != nil && velocityToSend != nil && noteChanToSend != nil {
            print("sending note: \(noteToSend!) - \(velocityToSend!)")
            let event = AKMIDIEvent(noteOn: MIDINoteNumber(noteToSend!), velocity: MIDIVelocity(velocityToSend!), channel: MIDIChannel(noteChanToSend!))
            midiOut.sendEvent(event)
        }else{
            print("error w note fields")
        }
    }
    @IBAction func sendCCPressed(_ sender: UIButton) {
        if ccToSend != nil && ccValToSend != nil && ccChanToSend != nil {
            print("sending cc: \(ccToSend!) - \(ccValToSend!)")
            let event = AKMIDIEvent(controllerChange: MIDIByte(ccToSend!), value: MIDIByte(ccValToSend!), channel: MIDIChannel(ccChanToSend!))
            midiOut.sendEvent(event)
        }else{
            print("error w cc fields")
        }
    }
    
    @IBAction func sendSysexPressed(_ sender: UIButton) {
        if sysexToSend != nil {
            print("sending sysex \(sysexToSend!)")
            var midiBytes = [MIDIByte]()
            for byte in sysexToSend!{
                midiBytes.append(MIDIByte(byte))
            }
            let event = AKMIDIEvent(data: midiBytes)
            midiOut.sendEvent(event)
        }else{
            print("error w sysex")
        }
    }
    
    @IBAction func receiveMIDIButtonPressed(_ sender: UIButton) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        dismiss(animated: true, completion: nil)
    }
}
