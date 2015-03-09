//
//  ProcessingViewController.swift
//  AudioKitDemo
//
//  Created by Nicholas Arner on 3/1/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

class ProcessingConductor {
    
    var audioFilePlayer    = AudioFilePlayer()
    var conv               = ConvolutionInstrument(input: audioFilePlayer.auxilliaryOutput)

    init() {
        
    }
    
    
}




class ProcessingViewController: UIViewController{
    
    @IBOutlet var sourceSegmentedControl: UISegmentedControl!
    @IBOutlet var maintainPitchSwitch: UISwitch!
    @IBOutlet var pitchSlider: UISlider!
    
    let pitchToMaintain:Float

    
    let analyzer = AKAudioAnalyzer()
    let continuouslyUpdateLevelMeter = AKSequence()
    let updateLevelMeter = AKEvent()
    
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
    }
    
}



