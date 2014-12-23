//
//  ViewController.swift
//  SwiftHarmonizer
//
//  Created by Nicholas Arner on 10/7/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let harmonizer = HarmonizerInstrument();
    let sampler = AKSampler();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        AKOrchestra.addInstrument(harmonizer)
        AKOrchestra.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startRecording(sender: AnyObject) {
        harmonizer.play()
        sampler.startRecordingToTrack("harmonizer")
    }
    
    @IBAction func stopRecording(sender: AnyObject) {
        harmonizer.stop()
        sampler.stopRecordingToTrack("harmonizer")
    }
    
    @IBAction func startPlaying(sender: AnyObject) {
        sampler.startPlayingTrack("harmonizer")
    }

    @IBAction func stopPlaying(sender: AnyObject) {
        sampler.stopPlayingTrack("harmonizer")
    }
}