//
//  ViewController.swift
//  MidiMonitor
//
//  Created by Aurelius Prochazka on 1/29/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController {
    @IBOutlet var outputTextView: UITextView!
    var midi = AKMIDI()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        midi.openMIDIIn("Session 1")
        
        let defaultCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        
        defaultCenter.addObserverForName(AKMIDIStatus.NoteOn.name(), object:  nil, queue: mainQueue, usingBlock: handleMIDINotification)
        defaultCenter.addObserverForName(AKMIDIStatus.NoteOff.name(), object: nil, queue: mainQueue, usingBlock: handleMIDINotification)
        defaultCenter.addObserverForName(AKMIDIStatus.ControllerChange.name(), object: nil, queue: mainQueue, usingBlock: handleMIDINotification)
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
        outputTextView.text = "\(newString)\n\(outputTextView.text)"
    }

}

