//
//  ViewController.swift
//  SequencerDemo
//
//  Created by Kanstantsin Linou on 6/30/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit
import UIKit

class ViewController: UIViewController {
    @IBOutlet private var melodyButton: UIButton!
    @IBOutlet private var bassButton: UIButton!
    @IBOutlet private var snareButton: UIButton!
    @IBOutlet private var tempoLabel: UILabel!
    @IBOutlet private var tempoSlider: AKPropertySlider!

    let conductor = Conductor()

    func setupUI() {
        var buttons = [UIButton]()
        buttons.append(melodyButton)
        buttons.append(bassButton)
        buttons.append(snareButton)
        for button in buttons {
            button.setTitleColor(UIColor.white, for: UIControlState())
            button.setTitleColor(UIColor.lightGray, for: UIControlState.disabled)
        }
        tempoSlider.callback = updateTempo
        tempoSlider.minimum = 40
        tempoSlider.maximum = 200
        tempoSlider.value = 110
        tempoSlider.format = "%0.1f BPM"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        conductor.setupTracks()
    }

    @IBAction func clearMelodySequence(_ sender: UIButton) {
        conductor.clear(Sequence.melody)
        melodyButton?.isEnabled = false
    }

    @IBAction func clearBassDrumSequence(_ sender: UIButton) {
        conductor.clear(Sequence.bassDrum)
        bassButton?.isEnabled = false
    }

    @IBAction func clearSnareDrumSequence(_ sender: UIButton) {
        conductor.clear(Sequence.snareDrum)
        snareButton?.isEnabled = false
    }

    @IBAction func clearSnareDrumGhostSequence(_ sender: UIButton) {
        conductor.clear(Sequence.snareGhost)
    }

    @IBAction func generateMajorSequence(_ sender: UIButton) {
        conductor.generateNewMelodicSequence(minor: false)
        melodyButton?.isEnabled = true
    }

    @IBAction func generateMinorSequence(_ sender: UIButton) {
        conductor.generateNewMelodicSequence(minor: true)
        melodyButton?.isEnabled = true
    }

    @IBAction func generateBassDrumSequence(_ sender: UIButton) {
        conductor.generateBassDrumSequence()
        bassButton?.isEnabled = true
    }

    @IBAction func generateBassDrumHalfSequence(_ sender: UIButton) {
        conductor.generateBassDrumSequence(2)
        bassButton?.isEnabled = true
    }

    @IBAction func generateBassDrumQuarterSequence(_ sender: UIButton) {
        conductor.generateBassDrumSequence(4)
        bassButton?.isEnabled = true
    }

    @IBAction func generateSnareDrumSequence(_ sender: UIButton) {
        conductor.generateSnareDrumSequence()
        snareButton?.isEnabled = true
    }

    @IBAction func generateSnareDrumHalfSequence(_ sender: UIButton) {
        conductor.generateSnareDrumSequence(2)
        snareButton?.isEnabled = true
    }

    @IBAction func generateSnareDrumGhostSequence(_ sender: UIButton) {
        conductor.generateSnareDrumGhostSequence()
        snareButton?.isEnabled = true
    }

    @IBAction func generateSequence(_ sender: UIButton) {
        conductor.generateSequence()
        melodyButton?.isEnabled = true
        bassButton?.isEnabled = true
        snareButton?.isEnabled = true
    }

    func updateTempo(value: Double) {
        conductor.currentTempo = value
    }
}
