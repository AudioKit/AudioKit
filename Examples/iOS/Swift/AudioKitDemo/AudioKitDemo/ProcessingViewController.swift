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
    
    var pitchToMaintain:Float
    
    let conv: ConvolutionInstrument
    let audioFilePlayer = AudioFilePlayer()
    
    let analyzer = AKAudioAnalyzer()
    let continuouslyUpdateLevelMeter = AKSequence()
    let updateLevelMeter = AKEvent()
    
    override init() {
        conv = ConvolutionInstrument(input: audioFilePlayer.auxilliaryOutput)
        analyzer = AKAudioAnalyzer(audioSource: audioFilePlayer.auxilliaryOutput)
        continuouslyUpdateLevelMeter = AKSequence()
        updateLevelMeter = AKEvent()
        pitchToMaintain = 1.0
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        conv = ConvolutionInstrument(input: audioFilePlayer.auxilliaryOutput)
        analyzer = AKAudioAnalyzer(audioSource: audioFilePlayer.auxilliaryOutput)
        continuouslyUpdateLevelMeter = AKSequence()
        updateLevelMeter = AKEvent()
        pitchToMaintain = 1.0
        super.init(coder: aDecoder)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        AKOrchestra.addInstrument(conv)
        AKOrchestra.addInstrument(audioFilePlayer)
        AKOrchestra.addInstrument(analyzer)
        AKOrchestra.start()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        AKOrchestra.reset()
        AKManager.sharedManager().stop()
    }
    
    @IBAction func start(sender:UIButton) {
        conv.play()
        audioFilePlayer.play()
    }
    
    @IBAction func stop(sender:UIButton) {
        conv.stop()
        audioFilePlayer.stop()
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
