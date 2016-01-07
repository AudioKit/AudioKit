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
   
    var fm: AKFMOscillatorInstrument?
    var osc: AKOscillatorInstrument?
    var noise: AKNoiseInstrument?

    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var slider1: UISlider!
    @IBOutlet var slider2: UISlider!
    @IBOutlet var slider3: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fm = AKFMOscillatorInstrument(voiceCount: 12)
        osc = AKOscillatorInstrument(table: AKTable(.Sine), voiceCount: 12)
        noise = AKNoiseInstrument(whitePinkMix: 0.5, voiceCount: 12)
        
        midi.openMidiIn("Session 1")
        fm!.enableMidi(midi.midiClient, name: "fm")
        osc!.enableMidi(midi.midiClient, name: "osc")
        noise!.enableMidi(midi.midiClient, name: "osc")
        
        
        audiokit.audioOutput = AKMixer(osc!, fm!, noise!)
        audiokit.start()
        
        let defaultCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        
        defaultCenter.addObserverForName(AKMidiStatus.NoteOn.name(), object: nil, queue: mainQueue, usingBlock: midiNoteNotif)
        defaultCenter.addObserverForName(AKMidiStatus.NoteOff.name(), object: nil, queue: mainQueue, usingBlock: midiNoteNotif)

        slider1.value = Float(osc!.output.volume)
        slider1.addTarget(self, action: "updateOscillatorVolume:", forControlEvents: .ValueChanged)
        slider2.value = Float(fm!.output.volume)
        slider2.addTarget(self, action: "updateFMOscillatorVolume:", forControlEvents: .ValueChanged)
        slider3.value = Float(noise!.output.volume)
        slider3.addTarget(self, action: "updateNoiseVolume:", forControlEvents: .ValueChanged)
        
    }
    
    func midiNoteNotif(notif: NSNotification) {
        dump(notif)
        fm?.handleMidiNotif(notif)
        osc?.handleMidiNotif(notif)
        noise?.handleMidiNotif(notif)
    }

    @IBAction func updateOscillatorVolume(sender: UISlider) {
        osc!.output.volume = Double(sender.value)
        let status = String(format: "%0.2f", osc!.output.volume)
        statusLabel.text = "Oscillator: Volume: \(status)"
    }
    
    @IBAction func updateFMOscillatorVolume(sender: UISlider) {
        fm!.output.volume = Double(sender.value)
        let status = String(format: "%0.2f", fm!.output.volume)
        statusLabel.text = "FM Oscillator: Volume: \(status)"
    }
    
    @IBAction func updateNoiseVolume(sender: UISlider) {
        noise!.output.volume = Double(sender.value)
        let status = String(format: "%0.2f", noise!.output.volume)
        statusLabel.text = "Noise: Volume: \(status)"
    }

}

