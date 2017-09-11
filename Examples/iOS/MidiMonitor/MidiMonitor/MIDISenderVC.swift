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
    @IBOutlet var ccField: UITextField!
    @IBOutlet var ccValField: UITextField!
    @IBOutlet var sysexField: UITextView!
    
    var noteToSend:Int? {
        return Int(noteNumField.text!)
    }
    var velocityToSend:Int? {
        return Int(noteVelField.text!)
    }
    var ccToSend:Int? {
        return Int(ccField.text!)
    }
    var ccValToSend:Int? {
        return Int(ccValField.text!)
    }
    override func viewDidLoad() {
        
        midiOut.openOutput()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func sendNotePressed(_ sender: UIButton) {
        if noteToSend != nil && velocityToSend != nil {
            print("sending note: \(noteToSend!) - \(velocityToSend!)")
            let event = AKMIDIEvent(noteOn: MIDINoteNumber(noteToSend!), velocity: MIDIVelocity(velocityToSend!), channel: 0)
            midiOut.sendEvent(event)
        }else{
            print("error w note fields")
        }
    }
    @IBAction func sendCCPressed(_ sender: UIButton) {
        if ccToSend != nil && ccValToSend != nil {
            print("sending cc: \(ccToSend!) - \(ccValToSend!)")
            let event = AKMIDIEvent(controllerChange: MIDIByte(ccToSend!), value: MIDIByte(ccValToSend!), channel: 1)
            midiOut.sendEvent(event)
        }else{
            print("error w cc fields")
        }
    }
    
    @IBAction func sendSysexPressed(_ sender: UIButton) {
        print("sending sysex")
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
