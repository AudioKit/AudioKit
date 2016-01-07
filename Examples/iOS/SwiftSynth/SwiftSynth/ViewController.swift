//
//  ViewController.swift
//  SwiftSynth
//
//  Created by Aurelius Prochazka on 1/6/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController {

    let audiokit = AKManager.sharedInstance
    var midi = AKMidi()
   
    var midiInst:AKOscillatorInstrument?
    var mixer = AKMixer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        midiInst = AKFMOscillatorInstrument(numVoicesInit: 12)
        midiInst = AKOscillatorInstrument(table: AKTable(.Sine), numVoicesInit: 12)
        //AKMidiInstrument(inst: AKOscillator(), numVoicesInit: 12)
        
        midi.openMidiIn("Session 1")
        midiInst!.enableMidi(midi.midiClient, name: "PolyOsc")
        audiokit.audioOutput = midiInst
        audiokit.start()
        
        let defaultCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        
        defaultCenter.addObserverForName(AKMidiStatus.NoteOn.name(), object: nil, queue: mainQueue, usingBlock: midiNoteNotif)
        defaultCenter.addObserverForName(AKMidiStatus.NoteOff.name(), object: nil, queue: mainQueue, usingBlock: midiNoteNotif)

        
    }
    
    func midiNoteNotif(notif:NSNotification){
        dump(notif)
        midiInst?.handleMidiNotif(notif)
    }


}

