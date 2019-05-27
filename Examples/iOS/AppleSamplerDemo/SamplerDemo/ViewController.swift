//
//  ViewController.swift
//  SamplerDemo
//
//  Created by Jeff Cooper and Kanstantsin Linou, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import AudioKitUI
import UIKit

class ViewController: UIViewController {
    @IBOutlet private var arpeggioVolumeSlider: AKSlider!
    @IBOutlet private var padVolumeSlider: AKSlider!
    @IBOutlet private var bassVolumeSlider: AKSlider!
    @IBOutlet private var drumVolumeSlider: AKSlider!
    @IBOutlet private var filterFrequencySlider: AKSlider!
    @IBOutlet private var tempoSlider: AKSlider!

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
        tempoSlider.range = 0 ... 2
    }

    @IBAction func useSoundForArpeggio(_ sender: UIButton) {
        guard let title = sender.currentTitle, let sound = Sound(rawValue: title) else {
            AKLog("Type of sound for arpeggio wasn't detected")
            return
        }

        conductor.useSound(sound, synthesizer: .arpeggio)
    }

    @IBAction func useSoundForPad(_ sender: UIButton) {
        guard let title = sender.currentTitle, let sound = Sound(rawValue: title) else {
            AKLog("Type of sound for pad wasn't detected")
            return
        }

        conductor.useSound(sound, synthesizer: .pad)
    }

    @IBAction func useSoundForBass(_ sender: UIButton) {
        guard let title = sender.currentTitle, let sound = Sound(rawValue: title) else {
            AKLog("Type of sound for bass wasn't detected")
            return
        }

        conductor.useSound(sound, synthesizer: .bass)
    }

    func adjustArpeggioVolume(newValue: Double) {
        conductor.adjustVolume(newValue, instrument: .arpeggio)
    }

    func adjustPadSynthesizerVolume(newValue: Double) {
        conductor.adjustVolume(newValue, instrument: .pad)
    }

    func adjustBassSynthesizerVolume(newValue: Double) {
        conductor.adjustVolume(newValue, instrument: .bass)
    }

    func adjustDrumKitVolume(newValue: Double) {
        conductor.adjustVolume(newValue, instrument: .drum)
    }

    func adjustFilterFrequency(newValue: Double) {
        conductor.adjustFilterFrequency(Float(newValue))
    }

    func adjustTempo(newValue: Double) {
        conductor.adjustTempo(Float(newValue))
    }

    @IBAction func setLength(_ sender: UIButton) {
        guard let title = sender.currentTitle, let length = Double(title) else {
            AKLog("Length wasn't detected")
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
