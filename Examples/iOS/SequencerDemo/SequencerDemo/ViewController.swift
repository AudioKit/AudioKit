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
    
    let conductor = Conductor()
    
    func setupUI() {
        var buttons = [UIButton]()
        buttons.append(melodyButton)
        buttons.append(bassButton)
        buttons.append(snareButton)
        for button in buttons {
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            button.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Disabled)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func clearMelodySequence(sender: UIButton) {
        conductor.clear(Sequence.Melody)
        melodyButton?.enabled = false
    }
    
    @IBAction func clearBassDrumSequence(sender: UIButton) {
        conductor.clear(Sequence.BassDrum)
        bassButton?.enabled = false
    }
    
    @IBAction func clearSnareDrumSequence(sender: UIButton) {
        conductor.clear(Sequence.SnareDrum)
        snareButton?.enabled = false
    }
    
    @IBAction func clearSnareDrumGhostSequence(sender: UIButton) {
        conductor.clear(Sequence.SnareDrumGhost)
    }
    
    @IBAction func generateMajorSequence(sender: UIButton) {
        conductor.generateNewMelodicSequence(minor: false)
        melodyButton?.enabled = true
    }
    
    @IBAction func generateMinorSequence(sender: UIButton) {
        conductor.generateNewMelodicSequence(minor: true)
        melodyButton?.enabled = true
    }
    
    @IBAction func generateBassDrumSequence(sender: UIButton) {
        conductor.generateBassDrumSequence()
        bassButton?.enabled = true
    }
    
    @IBAction func generateBassDrumHalfSequence(sender: UIButton) {
        conductor.generateBassDrumSequence(2)
        bassButton?.enabled = true
    }
    
    @IBAction func generateBassDrumQuarterSequence(sender: UIButton) {
        conductor.generateBassDrumSequence(4)
        bassButton?.enabled = true
    }
    
    
    @IBAction func generateSnareDrumSequence(sender: UIButton) {
        conductor.generateSnareDrumSequence()
        snareButton?.enabled = true
    }
    
    
    @IBAction func generateSnareDrumHalfSequence(sender: UIButton) {
        conductor.generateSnareDrumSequence(2)
        snareButton?.enabled = true
    }
    
    @IBAction func generateSnareDrumGhostSequence(sender: UIButton) {
        conductor.generateSnareDrumGhostSequence()
        snareButton?.enabled = true
    }
    
    @IBAction func decreaseTepmo(sender: UIButton) {
        conductor.decreaseTempo()
    }
    
    @IBAction func increaseTempo(sender: UIButton) {
        conductor.increaseTempo()
    }
    
    @IBAction func generateSequence(sender: UIButton) {
        conductor.generateSequence()
        melodyButton?.enabled = true
        bassButton?.enabled = true
        snareButton?.enabled = true
    }
}
