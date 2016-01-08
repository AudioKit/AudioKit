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
   
    var fm = AKFMOscillatorInstrument(voiceCount: 12)
    var sine = AKOscillatorInstrument(table: AKTable(.Sine), voiceCount: 12)
    var triangle = AKTriangleInstrument(voiceCount: 12)
    var noise = AKNoiseInstrument(whitePinkMix: 0.5, voiceCount: 12)
    var sourceMixer = AKMixer()
    var bitCrusher: AKBitCrusher?
    var bitCrushMixer: AKDryWetMixer?
    var masterVolume = AKMixer()
    var reverb: AKReverb2?

    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var slider1: UISlider!
    @IBOutlet var slider2: UISlider!
    @IBOutlet var slider3: UISlider!
    @IBOutlet var slider4: UISlider!
    
    @IBOutlet var waveformSegmentedControl: UISegmentedControl!
    
    @IBOutlet var bottomSlider2: UISlider!
    @IBOutlet var bottomSlider1: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fm.output.volume = 0.4
        
        noise.output.volume = 0.2
        
        midi.openMidiIn("Session 1")
        fm.enableMidi(midi.midiClient, name: "fm")
        sine.enableMidi(midi.midiClient, name: "sine")
        triangle.enableMidi(midi.midiClient, name: "triangle")
        noise.enableMidi(midi.midiClient, name: "noise")
        
        sourceMixer = AKMixer(sine, triangle, fm, noise)
        
        bitCrusher = AKBitCrusher(sourceMixer)
        bitCrushMixer = AKDryWetMixer(sourceMixer, bitCrusher!, t: 0.5)
        
        masterVolume = AKMixer(bitCrusher!)
        reverb = AKReverb2(masterVolume)
        reverb!.decayTimeAt0Hz = 2.0
        audiokit.audioOutput = reverb
        audiokit.start()
        
        let defaultCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        
        defaultCenter.addObserverForName(AKMidiStatus.NoteOn.name(), object: nil, queue: mainQueue, usingBlock: midiNoteNotif)
        defaultCenter.addObserverForName(AKMidiStatus.NoteOff.name(), object: nil, queue: mainQueue, usingBlock: midiNoteNotif)

        slider1.value = Float(sine.output.volume)
        slider1.addTarget(self, action: "updateOscillatorVolume:", forControlEvents: .ValueChanged)
        slider2.value = Float(fm.output.volume)
        slider2.addTarget(self, action: "updateFMOscillatorVolume:", forControlEvents: .ValueChanged)
        slider3.value = Float(noise.output.volume)
        slider3.addTarget(self, action: "updateNoiseVolume:", forControlEvents: .ValueChanged)
        slider4.value = Float(bitCrusher!.bitDepth)
        slider4.minimumValue = 0
        slider4.maximumValue = 24
        slider4.addTarget(self, action: "updateBitCrusherBitDepth:", forControlEvents: .ValueChanged)
        
        bottomSlider2.value = Float(masterVolume.volume)
        bottomSlider2.maximumValue = 2
        bottomSlider2.addTarget(self, action: "updateMasterVolume:", forControlEvents: .ValueChanged)
        
        bottomSlider1.value = Float(reverb!.dryWetMix)
        bottomSlider1.addTarget(self, action: "updateReverb:", forControlEvents: .ValueChanged)
        
    }
    
    func midiNoteNotif(notif: NSNotification) {
        dump(notif)
        switch waveformSegmentedControl.selectedSegmentIndex {
        case 0:
            sine.handleMidiNotif(notif)
        case 0:
            triangle.handleMidiNotif(notif)
        default:
            break
            // do nothing
        }
        triangle.handleMidiNotif(notif)
        fm.handleMidiNotif(notif)
        noise.handleMidiNotif(notif)
    }

    @IBAction func updateOscillatorVolume(sender: UISlider) {
        sine.output.volume = Double(sender.value)
        triangle.output.volume = Double(sender.value)
        let status = String(format: "%0.2f", sine.output.volume)
        statusLabel.text = "Oscillator: Volume: \(status)"
    }
    
    @IBAction func updateFMOscillatorVolume(sender: UISlider) {
        // You can also access all the FM oscillator parameters
        // like fm!.carrierMultiplier, etc. but for this demo just doing volume
        fm.output.volume = Double(sender.value)
        let status = String(format: "%0.2f", fm.output.volume)
        statusLabel.text = "FM Oscillator: Volume: \(status)"
    }
    
    @IBAction func updateNoiseVolume(sender: UISlider) {
        noise.output.volume = Double(sender.value)
        let status = String(format: "%0.2f", noise.output.volume)
        statusLabel.text = "Noise: Volume: \(status)"
    }
    
    @IBAction func updateBitCrusherBitDepth(sender: UISlider) {
        // Bitcrusher also has sample rate which you can control
        // Plus there is a bitCrushMixer for dry/wet
        // And the bitCrusher can be bypassed
        bitCrusher!.bitDepth = Double(sender.value)
        let status = String(format: "%0f", bitCrusher!.bitDepth)
        statusLabel.text = "BitCrusher: Bit Depth Rate: \(status)"
    }
    
    @IBAction func updateMasterVolume(sender: UISlider) {
        masterVolume.volume = Double(sender.value)
        let status = String(format: "%0.2f", masterVolume.volume)
        statusLabel.text = "Master: Volume: \(status)"
    }
    
    @IBAction func updateReverb(sender: UISlider) {
        // Reverb has oodles of parameters to tweak, just doing dry/wet now
        reverb!.dryWetMix = Double(sender.value)
        let status = String(format: "%0.2f", reverb!.dryWetMix)
        statusLabel.text = "Reverb: Mix: \(status)"
    }

}

