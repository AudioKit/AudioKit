//
//  ViewController.swift
//  SamplerDemo
//
//  Created by Jeff Cooper and Kanstantsin Linou on 7/2/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var arpeggioVolumeSlider: UISlider!
    @IBOutlet var padVolumeSlider: UISlider!
    @IBOutlet var bassVolumeSlider: UISlider!
    @IBOutlet var drumVolumeSlider: UISlider!
    @IBOutlet var filterVolumeSlider: UISlider!
    
    let conductor = Conductor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func useSoundForArpeggio(sender: UIButton) {
        guard let title = sender.currentTitle, sound = Sound(rawValue: title) else {
            print("Type of sound for arpeggio wasn't detected")
            return
        }
        
        conductor.useSound(sound, synthesizer: Synthesizer.Arpeggio)
    }
    
    @IBAction func useSoundForPad(sender: UIButton) {
        guard let title = sender.currentTitle, sound = Sound(rawValue: title) else {
            print("Type of sound for pad wasn't detected")
            return
        }
        
        conductor.useSound(sound, synthesizer: Synthesizer.Pad)
    }
    
    @IBAction func useSoundForBass(sender: UIButton) {
        guard let title = sender.currentTitle, sound = Sound(rawValue: title) else {
            print("Type of sound for bass wasn't detected")
            return
        }
        
        conductor.useSound(sound, synthesizer: Synthesizer.Bass)
    }
    
    @IBAction func adjustArpeggioSynthesizerVolume(sender: UISlider) {
        conductor.adjustVolume(sender.value, instrument: Instrument.Arpeggio)
    }
    
    @IBAction func adjustPadSynthesizerVolume(sender: UISlider) {
        conductor.adjustVolume(sender.value, instrument: Instrument.Pad)
    }
    
    @IBAction func adjustBassSynthesizerVolume(sender: UISlider) {
        conductor.adjustVolume(sender.value, instrument: Instrument.Bass)
    }
    
    @IBAction func adjustDrumKitVolume(sender: UISlider) {
        conductor.adjustVolume(sender.value, instrument: Instrument.Drum)
    }
    
    @IBAction func adjustFilterFrequency(sender: UISlider) {
        conductor.adjustFilterFrequency(sender.value)
    }
    
    @IBAction func setLength(sender: UIButton) {
        guard let title = sender.currentTitle, length = Double(title) else {
            print("Length wasn't detected")
            return
        }
        conductor.setLength(length)
    }
    
    @IBAction func rewindSequence(sender: UIButton) {
        conductor.rewindSequence()
    }
    
    @IBAction func stopSequence(sender: UIButton) {
        conductor.stopSequence()
    }
    
    @IBAction func playSequence(sender: UIButton) {
        conductor.playSequence()
    }
}

