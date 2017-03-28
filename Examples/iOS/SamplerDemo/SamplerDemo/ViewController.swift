//
//  ViewController.swift
//  SamplerDemo
//
//  Created by Jeff Cooper and Kanstantsin Linou on 7/2/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit
import UIKit

class ViewController: UIViewController {
    @IBOutlet private var arpeggioVolumeSlider: AKPropertySlider!
    @IBOutlet private var padVolumeSlider: AKPropertySlider!
    @IBOutlet private var bassVolumeSlider: AKPropertySlider!
    @IBOutlet private var drumVolumeSlider: AKPropertySlider!
    @IBOutlet private var filterFrequencySlider: AKPropertySlider!
    @IBOutlet private var tempoSlider: AKPropertySlider!

    let conductor = Conductor()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        arpeggioVolumeSlider.callback = adjustArpeggioVolume
        padVolumeSlider.callback = adjustPadSynthesizerVolume
        bassVolumeSlider.callback = adjustBassSynthesizerVolume
        drumVolumeSlider.callback = adjustDrumKitVolume
        filterFrequencySlider.callback = adjustFilterFrequency
        tempoSlider.callback = adjustTempo
    }

    @IBAction func useSoundForArpeggio(_ sender: UIButton) {
        guard let title = sender.currentTitle, let sound = Sound(rawValue: title) else {
            print("Type of sound for arpeggio wasn't detected")
            return
        }

        conductor.useSound(sound, synthesizer: Synthesizer.Arpeggio)
    }

    @IBAction func useSoundForPad(_ sender: UIButton) {
        guard let title = sender.currentTitle, let sound = Sound(rawValue: title) else {
            print("Type of sound for pad wasn't detected")
            return
        }

        conductor.useSound(sound, synthesizer: Synthesizer.Pad)
    }

    @IBAction func useSoundForBass(_ sender: UIButton) {
        guard let title = sender.currentTitle, let sound = Sound(rawValue: title) else {
            print("Type of sound for bass wasn't detected")
            return
        }

        conductor.useSound(sound, synthesizer: Synthesizer.Bass)
    }

    func adjustArpeggioVolume(newValue: Double) {
        conductor.adjustVolume(Float(newValue), instrument: Instrument.Arpeggio)
    }

    func adjustPadSynthesizerVolume(newValue: Double) {
        conductor.adjustVolume(Float(newValue), instrument: Instrument.Pad)
    }

    func adjustBassSynthesizerVolume(newValue: Double) {
        conductor.adjustVolume(Float(newValue), instrument: Instrument.Bass)
    }

    func adjustDrumKitVolume(newValue: Double) {
        conductor.adjustVolume(Float(newValue), instrument: Instrument.Drum)
    }

    func adjustFilterFrequency(newValue: Double) {
        conductor.adjustFilterFrequency(Float(newValue))
    }

    func adjustTempo(newValue: Double) {
        conductor.adjustTempo(Float(newValue))
    }

    @IBAction func setLength(_ sender: UIButton) {
        guard let title = sender.currentTitle, let length = Double(title) else {
            print("Length wasn't detected")
            return
        }
        conductor.setLength(length)
    }

    @IBAction func rewindSequence(_ sender: UIButton) {
        conductor.rewindSequence()
    }

    @IBAction func stopSequence(_ sender: UIButton) {
        conductor.stopSequence()
    }

    @IBAction func playSequence(_ sender: UIButton) {
        conductor.playSequence()
    }
}
