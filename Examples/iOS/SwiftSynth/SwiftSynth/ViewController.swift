//
//  ViewController.swift
//  SwiftSynth
//
//  Created by Aurelius Prochazka on 1/6/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var slider1: UISlider!
    @IBOutlet var slider2: UISlider!
    @IBOutlet var slider3: UISlider!
    @IBOutlet var slider4: UISlider!
   
    @IBOutlet var waveformSegmentedControl: UISegmentedControl!
    
    @IBOutlet var slider5: UISlider!
    @IBOutlet var slider6: UISlider!
    
    let conductor = Conductor.sharedInstance

    
    @IBOutlet var bottomSlider2: UISlider!
    @IBOutlet var bottomSlider1: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        slider1.value = Float(conductor.sine1.output.volume)
        slider1.addTarget(self, action: "updateOscillatorVolume:", forControlEvents: .ValueChanged)
        slider2.value = Float(conductor.fm.output.volume)
        slider2.addTarget(self, action: "updateFMOscillatorVolume:", forControlEvents: .ValueChanged)
        slider3.value = Float(conductor.noise.output.volume)
        slider3.addTarget(self, action: "updateNoiseVolume:", forControlEvents: .ValueChanged)
        slider4.value = Float(conductor.bitCrusher!.bitDepth)
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

        
        bottomSlider2.value = Float(conductor.masterVolume.volume)
        bottomSlider2.maximumValue = 2
        bottomSlider2.addTarget(self, action: "updateMasterVolume:", forControlEvents: .ValueChanged)
        
        bottomSlider1.value = Float(conductor.reverb!.dryWetMix)
        bottomSlider1.addTarget(self, action: "updateReverb:", forControlEvents: .ValueChanged)
        
    }
    


    @IBAction func updateOscillatorVolume(sender: UISlider) {
        conductor.sine1.output.volume = Double(sender.value)
        conductor.triangle1.output.volume = Double(sender.value)
        conductor.sawtooth1.output.volume = Double(sender.value)
        conductor.square1.output.volume = Double(sender.value)
        let status = String(format: "%0.2f", conductor.sine1.output.volume)
        statusLabel.text = "Oscillator: Volume: \(status)"
    }
    
    @IBAction func updateFMOscillatorVolume(sender: UISlider) {
        // You can also access all the FM oscillator parameters
        // like fm!.carrierMultiplier, etc. but for this demo just doing volume
        conductor.fm.output.volume = Double(sender.value)
        let status = String(format: "%0.2f", conductor.fm.output.volume)
        statusLabel.text = "FM Oscillator: Volume: \(status)"
    }
    
    @IBAction func updateNoiseVolume(sender: UISlider) {
        conductor.noise.output.volume = Double(sender.value)
        let status = String(format: "%0.2f", conductor.noise.output.volume)
        statusLabel.text = "Noise: Volume: \(status)"
    }
    
    @IBAction func updateBitCrusherBitDepth(sender: UISlider) {
        // Bitcrusher also has sample rate which you can control
        // Plus there is a bitCrushMixer for dry/wet
        // And the bitCrusher can be bypassed
        conductor.bitCrusher!.bitDepth = Double(sender.value)
        let status = String(format: "%0f", conductor.bitCrusher!.bitDepth)
        statusLabel.text = "BitCrusher: Bit Depth Rate: \(status)"
    }
    
    @IBAction func updateFilterSection(sender: UISlider) {
        // just scale all parameters from this section
        // obviously you can have more knobs and more sound designing
        let filterSectionParameters = [1000, 0.9, 0.9, 1000, 1, 1]
        conductor.filterSection.parameters = filterSectionParameters.map { p -> Double in
            p * Double(sender.value)
        }

        let status = String(format: "%0f", Double(sender.value))
        statusLabel.text = "Fatten: Time: \(status)"
    }
    
    @IBAction func updateFatten(sender: UISlider) {
        conductor.fatten.time = Double(sender.value)
        let status = String(format: "%0f", Double(sender.value))
        statusLabel.text = "Fatten: Time: \(status)"
    }
    
    @IBAction func updateMasterVolume(sender: UISlider) {
        conductor.masterVolume.volume = Double(sender.value)
        let status = String(format: "%0.2f", conductor.masterVolume.volume)
        statusLabel.text = "Master: Volume: \(status)"
    }
    
    @IBAction func updateReverb(sender: UISlider) {
        // Reverb has oodles of parameters to tweak, just doing dry/wet now
        conductor.reverb!.dryWetMix = Double(sender.value)
        let status = String(format: "%0.2f", conductor.reverb!.dryWetMix)
        statusLabel.text = "Reverb: Mix: \(status)"
    }

}

