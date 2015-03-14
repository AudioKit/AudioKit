//
//  ProcessingViewController.swift
//  AudioKitDemo
//
//  Created by Nicholas Arner on 3/1/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//


class ProcessingViewController: NSViewController {
    
    @IBOutlet var sourceSegmentedControl: NSSegmentedControl!
    @IBOutlet var maintainPitchSwitch: NSButton!
    @IBOutlet var pitchSlider: NSSlider!
    
    var pitchToMaintain:Float
    
    let conv: ConvolutionInstrument
    let audioFilePlayer = AudioFilePlayer()
    
    
    override init() {
        conv = ConvolutionInstrument(input: audioFilePlayer.auxilliaryOutput)
        pitchToMaintain = 1.0
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        conv = ConvolutionInstrument(input: audioFilePlayer.auxilliaryOutput)
        pitchToMaintain = 1.0
        super.init(coder: aDecoder)
    }
    
    override func viewDidAppear() {
        
        AKOrchestra.addInstrument(audioFilePlayer)
        AKOrchestra.addInstrument(conv)
        AKOrchestra.start()
    }
    
    override func viewWillDisappear() {
        AKOrchestra.reset()
        AKManager.sharedManager().stop()
    }
    
    @IBAction func start(sender:NSButton) {
        conv.play()
        audioFilePlayer.play()
    }
    
    @IBAction func stop(sender:NSButton) {
        conv.stop()
        audioFilePlayer.stop()
    }
    
    @IBAction func wetnessChanged(sender:NSSlider) {
        AKTools.setProperty(conv.dryWetBalance, withSlider: sender)
    }
    
    @IBAction func impulseResponseChanged(sender:NSSlider) {
        AKTools.setProperty(conv.dishWellBalance, withSlider: sender)
    }
    
    @IBAction func speedChanged(sender:NSSlider) {
        AKTools.setProperty(audioFilePlayer.speed, withSlider: sender)
        if (maintainPitchSwitch.state == 1 && fabs(audioFilePlayer.speed.floatValue) > 0.1) {
            audioFilePlayer.scaling.floatValue = pitchToMaintain / fabs(audioFilePlayer.speed.floatValue)
            AKTools.setSlider(pitchSlider, withProperty: audioFilePlayer.scaling)
        }
    }
    
    @IBAction func pitchChanged(sender:NSSlider) {
        AKTools.setProperty(audioFilePlayer.scaling, withSlider: sender)
    }
    
    @IBAction func togglePitchMaintenance(sender:NSButton) {
        if sender.state == 1 {
            pitchSlider.enabled = false
            pitchToMaintain = fabs(audioFilePlayer.speed.floatValue) * audioFilePlayer.scaling.floatValue
        } else {
            pitchSlider.enabled = true
        }
    }
    
    @IBAction func fileChanged(sender:NSSegmentedControl) {
        audioFilePlayer.sampleMix.floatValue = Float(sender.selectedSegment)
    }
}
