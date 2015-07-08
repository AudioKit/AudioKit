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
    @IBOutlet var speedSlider: AKPropertySlider!
    @IBOutlet var pitchSlider: AKPropertySlider!
    @IBOutlet var dishWellSlider: AKPropertySlider!
    @IBOutlet var dryWetSlider: AKPropertySlider!

    var isPlaying = false

    var pitchToMaintain: Float = 1.0

    var conv: ConvolutionInstrument!
    let audioFilePlayer = AKAudioFilePlayer()

    override func viewDidLoad() {
        super.viewDidLoad()

        conv = ConvolutionInstrument(input: audioFilePlayer.output)

        AKOrchestra.addInstrument(audioFilePlayer)
        AKOrchestra.addInstrument(conv)

        speedSlider.property = audioFilePlayer.speed
        pitchSlider.property = audioFilePlayer.scaling
        dryWetSlider.property   = conv.dryWetBalance
        dishWellSlider.property = conv.dishWellBalance

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

    @IBAction func speedChanged(sender:UISlider) {
        if (maintainPitchSwitch.on && fabs(audioFilePlayer.speed.value) > 0.1) {
            audioFilePlayer.scaling.value = pitchToMaintain / fabs(audioFilePlayer.speed.value)
        }
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
