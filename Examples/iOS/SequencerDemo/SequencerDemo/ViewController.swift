//
//  ViewController.swift
//  SequencerDemo
//
//  Created by Kanstantsin Linou on 6/30/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController {
    @IBOutlet var melodyButton: UIButton!
    @IBOutlet var bassButton: UIButton!
    @IBOutlet var snareButton: UIButton!
    @IBOutlet var tempoLabel: UILabel!
    
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
        updateTempoLabel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view, typically from a nib.
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
        conductor.clear(Sequence.snareDrumGhost)
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
    
    @IBAction func decreaseTepmo(_ sender: UIButton) {
        conductor.decreaseTempo()
        updateTempoLabel()
    }
    
    @IBAction func increaseTempo(_ sender: UIButton) {
        conductor.increaseTempo()
        updateTempoLabel()
    }
    
    @IBAction func generateSequence(_ sender: UIButton) {
        conductor.generateSequence()
        melodyButton?.isEnabled = true
        bassButton?.isEnabled = true
        snareButton?.isEnabled = true
    }
    
    func updateTempoLabel() {
        let tempoText = "Tempo"
        tempoLabel.text = (tempoText) + "\r\n" + "\(conductor.currentTempo)"
    }
}
