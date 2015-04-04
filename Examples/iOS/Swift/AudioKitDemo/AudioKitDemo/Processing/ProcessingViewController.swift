//
//  ProcessingViewController.swift
//  AudioKitDemo
//
//  Created by Nicholas Arner on 3/1/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//


class ProcessingViewController: UIViewController {
    
    @IBOutlet var sourceSegmentedControl: UISegmentedControl!
    @IBOutlet var maintainPitchSwitch: UISwitch!
    @IBOutlet var pitchSlider: UISlider!
    
    var isPlaying = false
    
    var pitchToMaintain:Float
    
    let conv: ConvolutionInstrument
    let audioFilePlayer = AudioFilePlayer()
    
    override init() {
        conv = ConvolutionInstrument(input: audioFilePlayer.auxilliaryOutput)
        pitchToMaintain = 1.0
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        conv = ConvolutionInstrument(input: audioFilePlayer.auxilliaryOutput)
        pitchToMaintain = 1.0
        super.init(coder: aDecoder)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        AKOrchestra.addInstrument(audioFilePlayer)
        AKOrchestra.addInstrument(conv)
    }
    
    
    @IBAction func start(sender:UIButton) {
        if (!isPlaying) {
            conv.play()
            audioFilePlayer.play()
            isPlaying = true
        }
    }
    
    @IBAction func stop(sender:UIButton) {
        if (isPlaying) {
            conv.stop()
            audioFilePlayer.stop()
            isPlaying = false
        }
    }
    
    @IBAction func wetnessChanged(sender:UISlider) {
        AKTools.setProperty(conv.dryWetBalance, withSlider: sender)
    }
    
    @IBAction func impulseResponseChanged(sender:UISlider) {
        AKTools.setProperty(conv.dishWellBalance, withSlider: sender)
    }
    
    @IBAction func speedChanged(sender:UISlider) {
        AKTools.setProperty(audioFilePlayer.speed, withSlider: sender)
        if (maintainPitchSwitch.on && fabs(audioFilePlayer.speed.value) > 0.1) {
            audioFilePlayer.scaling.value = pitchToMaintain / fabs(audioFilePlayer.speed.value)
            AKTools.setSlider(pitchSlider, withProperty: audioFilePlayer.scaling)
        }
    }
    
    @IBAction func pitchChanged(sender:UISlider) {
        AKTools.setProperty(audioFilePlayer.scaling, withSlider: sender)
    }
    
    @IBAction func togglePitchMaintenance(sender:UISwitch) {
        if sender.on {
            pitchSlider.enabled = false
            pitchToMaintain = fabs(audioFilePlayer.speed.value) * audioFilePlayer.scaling.value
        } else {
            pitchSlider.enabled = true
        }
    }
    
    @IBAction func fileChanged(sender:UISegmentedControl) {
        audioFilePlayer.sampleMix.value = Float(sender.selectedSegmentIndex)
    }
}
