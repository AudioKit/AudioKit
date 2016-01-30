//
//  ViewController.swift
//  MidiMonitor
//
//  Created by Aurelius Prochazka on 1/29/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController, AKMIDIListener {
    @IBOutlet var outputTextView: UITextView!
    var midi = AKMIDI()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        midi.openMIDIIn("Session 1")
        midi.addListener(self)
    }
    func midiController(controller: Int, value: Int, channel: Int) {
        var newString = "Channel: \(channel+1) "
        newString.appendContentsOf("controller: \(controller) value: \(value) ")
        updateText(newString)
    }
    
    func updateText(input:String){
        dispatch_async(dispatch_get_main_queue(), {
           self.outputTextView.text = "\(input)\n\(self.outputTextView.text)"
        })
    }
    func handleMIDINotification(notification: NSNotification) {
        let channel = Int((notification.userInfo?["channel"])! as! NSNumber) + 1
        var newString = "Channel: \(channel) "

        if notification.name == AKMIDIStatus.NoteOn.name() {
            let note = Int((notification.userInfo?["note"])! as! NSNumber)
            let velocity = Int((notification.userInfo?["velocity"])! as! NSNumber)
            newString.appendContentsOf("Note On: \(note) Velocity: \(velocity) ")
        } else if notification.name == AKMIDIStatus.NoteOff.name() {
            let note = Int((notification.userInfo?["note"])! as! NSNumber)
            let velocity = Int((notification.userInfo?["velocity"])! as! NSNumber)
            newString.appendContentsOf("Note Off: \(note) Velocity: \(velocity) ")
        } else if notification.name == AKMIDIStatus.ControllerChange.name() {
            let controller = Int((notification.userInfo?["control"])! as! NSNumber)
            let value = Int((notification.userInfo?["value"])! as! NSNumber)
            newString.appendContentsOf("Controller: \(controller) Value: \(value)")
        }
//        outputTextView.text = "\(newString)\n\(outputTextView.text)"
    }

}

