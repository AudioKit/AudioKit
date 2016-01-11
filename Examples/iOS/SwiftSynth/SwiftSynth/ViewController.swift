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
    
    var sine1     = AKOscillatorInstrument(waveform: AKTable(.Sine), voiceCount: 12)
    var triangle1 = AKTriangleInstrument(voiceCount: 12)
    var sawtooth1 = AKSawtoothInstrument(voiceCount: 12)
    var square1   = AKSquareInstrument(voiceCount: 12)
    
    var sine2     = AKOscillatorInstrument(waveform: AKTable(.Sine), voiceCount: 12)
    var triangle2 = AKTriangleInstrument(voiceCount: 12)
    var sawtooth2 = AKSawtoothInstrument(voiceCount: 12)
    var square2   = AKSquareInstrument(voiceCount: 12)
    
    var noise = AKNoiseInstrument(whitePinkMix: 0.5, voiceCount: 12)
    
    var sourceMixer = AKMixer()
    
    var bitCrusher: AKBitCrusher?
    var bitCrushMixer: AKDryWetMixer?
    var fatten: AKOperationEffect?
    var filterSection: AKOperationEffect?
    var filterSectionParameters: [Double] = []
    
    var masterVolume = AKMixer()
    var reverb: AKReverb2?

    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var slider1: UISlider!
    @IBOutlet var slider2: UISlider!
    @IBOutlet var slider3: UISlider!
    @IBOutlet var slider4: UISlider!
   
    @IBOutlet var waveformSegmentedControl: UISegmentedControl!
    
    @IBOutlet var slider5: UISlider!
    @IBOutlet var slider6: UISlider!
    
    

    
    @IBOutlet var bottomSlider2: UISlider!
    @IBOutlet var bottomSlider1: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fm.output.volume = 0.4
        noise.output.volume = 0.2
        
        midi.openMidiIn("Session 1")
        
        sourceMixer = AKMixer(sine1, triangle1, sawtooth1, square1, fm, noise)
        
        bitCrusher = AKBitCrusher(sourceMixer)
        bitCrushMixer = AKDryWetMixer(sourceMixer, bitCrusher!, t: 0.5)
        
        let cutoffFrequencyParameter = AKOperation.parameters(0)
        let resonanceParameter       = AKOperation.parameters(1)
        let filterMixParameter       = AKOperation.parameters(2)
        let lfoAmplitudeParameter    = AKOperation.parameters(3)
        let lfoRateParameter         = AKOperation.parameters(4)
        let lfoMixParameter          = AKOperation.parameters(5)
        
        let lfo = AKOperation.sawtooth(frequency: lfoRateParameter, amplitude: lfoAmplitudeParameter * lfoMixParameter)
        let moog = AKOperation.input.moogLadderFilter(cutoffFrequency: lfo + cutoffFrequencyParameter, resonance: resonanceParameter)
        let mixed = mix(AKOperation.input, moog, t: filterMixParameter)
        filterSection = AKOperationEffect(bitCrushMixer!, operation: mixed)

        filterSectionParameters = [1000, 0.9, 0.9, 1000, 1, 1]
        filterSection?.parameters = filterSectionParameters
        
            //[cutoffFrequency, resonance, filterMix, lfoAmplitude, lfoRate, lfoMix]
        
        
        
        
        let input = AKStereoOperation.input
        let fattenTimeParameter = AKOperation.parameters(0)
        let fattenMixParameter = AKOperation.parameters(1)
        
        let fattenOperation = AKStereoOperation(
            "\(input) dup \(1 - fattenMixParameter) * swap 0 \(fattenTimeParameter) 1.0 vdelay \(fattenMixParameter) * +")
        fatten = AKOperationEffect(filterSection!, stereoOperation: fattenOperation)
        
        
        
        func multitapDelay(input: AKNode, times: [Double], gains: [Double]) -> AKMixer {
            let mix = AKMixer(input)
            zip(times, gains).forEach { (time, gain) -> () in
                let delay = AKDelay(input, time: time, feedback: 0.0, dryWetMix: 100)
                mix.connect(AKBooster(delay, gain: gain))
            }
            return mix
        }
        
        // Delay Properties
        let delayTime = 1.0 // Seconds
        let delayMix  = 0.4 // 0 (dry) - 1 (wet)
        let gains = [0.5, 0.25, 0.15].map { g -> Double in g * delayMix }
        
        // Delay Definition
        let leftDelay = multitapDelay(fatten!,
            times: [1.5, 2.5, 3.5].map { t -> Double in t * delayTime },
            gains: gains)
        let rightDelay = multitapDelay(fatten!,
            times: [1, 2, 3].map { t -> Double in t * delayTime },
            gains: gains)
        let delayPannedLeft = AKPanner(leftDelay, pan: -1)
        let delayPannedRight = AKPanner(rightDelay, pan: 1)
        
        let multiDelayMix = AKMixer(delayPannedLeft, delayPannedRight)
        

        
        
        
        masterVolume = AKMixer(multiDelayMix)
        reverb = AKReverb2(masterVolume)
        reverb!.decayTimeAt0Hz = 2.0
        audiokit.audioOutput = reverb
        audiokit.start()
        
        let defaultCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        
        defaultCenter.addObserverForName(AKMidiStatus.NoteOn.name(), object: nil, queue: mainQueue, usingBlock: handleMidiNotification)
        defaultCenter.addObserverForName(AKMidiStatus.NoteOff.name(), object: nil, queue: mainQueue, usingBlock: handleMidiNotification)

        slider1.value = Float(sine1.output.volume)
        slider1.addTarget(self, action: "updateOscillatorVolume:", forControlEvents: .ValueChanged)
        slider2.value = Float(fm.output.volume)
        slider2.addTarget(self, action: "updateFMOscillatorVolume:", forControlEvents: .ValueChanged)
        slider3.value = Float(noise.output.volume)
        slider3.addTarget(self, action: "updateNoiseVolume:", forControlEvents: .ValueChanged)
        slider4.value = Float(bitCrusher!.bitDepth)
        slider4.minimumValue = 0
        slider4.maximumValue = 24
        slider4.addTarget(self, action: "updateBitCrusherBitDepth:", forControlEvents: .ValueChanged)

        slider5.value = 0
        slider5.minimumValue = 0
        slider5.maximumValue = 0.2
        slider5.addTarget(self, action: "updateFatten:", forControlEvents: .ValueChanged)

        slider6.value = 1
        slider6.minimumValue = 0
        slider6.maximumValue = 1
        slider6.addTarget(self, action: "updateFilterSection:", forControlEvents: .ValueChanged)

        
        bottomSlider2.value = Float(masterVolume.volume)
        bottomSlider2.maximumValue = 2
        bottomSlider2.addTarget(self, action: "updateMasterVolume:", forControlEvents: .ValueChanged)
        
        bottomSlider1.value = Float(reverb!.dryWetMix)
        bottomSlider1.addTarget(self, action: "updateReverb:", forControlEvents: .ValueChanged)
        
    }
    
    func handleMidiNotification(notification: NSNotification) {
        let note = Int((notification.userInfo?["note"])! as! NSNumber)
        let velocity = Int((notification.userInfo?["velocity"])! as! NSNumber)
        if notification.name == AKMidiStatus.NoteOn.name() && velocity > 0 {
            
            switch waveformSegmentedControl.selectedSegmentIndex {
            case 0:
                sine1.startNote(note, velocity: velocity)
            case 1:
                triangle1.startNote(note, velocity: velocity)
            case 2:
                sawtooth1.startNote(note, velocity: velocity)
            case 3:
                square1.startNote(note, velocity: velocity)
            default:
                break
                // do nothing
            }
            fm.startNote(note, velocity: velocity)
            noise.startNote(note, velocity: velocity)
            
        } else if (notification.name == AKMidiStatus.NoteOn.name() && velocity == 0) || notification.name == AKMidiStatus.NoteOff.name() {
            
            
            switch waveformSegmentedControl.selectedSegmentIndex {
            case 0:
                sine1.stopNote(note)
            case 1:
                triangle1.stopNote(note)
            case 2:
                sawtooth1.stopNote(note)
            case 3:
                square1.stopNote(note)
            default:
                break
                // do nothing
            }
            fm.stopNote(note)
            noise.stopNote(note)
            
            
            
        }
        
        
        


    }

    @IBAction func updateOscillatorVolume(sender: UISlider) {
        sine1.output.volume = Double(sender.value)
        triangle1.output.volume = Double(sender.value)
        sawtooth1.output.volume = Double(sender.value)
        square1.output.volume = Double(sender.value)
        let status = String(format: "%0.2f", sine1.output.volume)
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
    
    @IBAction func updateFilterSection(sender: UISlider) {
        // just scale all parameters from this section
        // obviously you can have more knobs and more sound designing
        filterSection?.parameters = filterSectionParameters.map { p -> Double in
            p * Double(sender.value)
        }

        let status = String(format: "%0f", Double(sender.value))
        statusLabel.text = "Fatten: Time: \(status)"
    }
    
    @IBAction func updateFatten(sender: UISlider) {
        fatten?.parameters = [Double(sender.value), 0.5]
        let status = String(format: "%0f", Double(sender.value))
        statusLabel.text = "Fatten: Time: \(status)"
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

