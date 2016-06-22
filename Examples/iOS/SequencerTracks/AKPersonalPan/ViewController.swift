//
//  ViewController.swift
//  AKPersonalPan
//
//  Created by Jeff Cooper on 1/10/16.
//  Copyright © 2016 Jeff Cooper. All rights reserved.
//
//  Sequencer Tracks demo
//  the demo formerly known as AKPersonalPan
//
//  This is a demo of another implementation of the sequencer, using the newer apple AVSequence.
//  When you init an AKSequence with the audio engine, it automatically sets itself up as an avsequence.
//  "But Jeffe..."
//  "Yeeeesss?"
//  "Why two different kinds of sequences homey!?"
//  The answer is just as proof-of-concept. As of this writing (20160118), the AVSequencer pales in comparison,
//  functionality-wise, to the classic C style sequencers. Also, the AVSequencer currently has a bug that makes a pure midi
//  sequence glitch out on the first beat. However, it still works pretty well for basic midi file playback pointing at an
//  AVAudioUnit (in our case, just the AKSampler), and we hope will continue to improve as far as features go.
//  Until then - enjoy the confusion!


import UIKit
import AudioKit

class ViewController: UIViewController {
    var seq: AKSequencer?
    var mixer = AKMixer()
    var syn1 = AKSampler()
    var syn2 = AKSampler()
    var syn3 = AKSampler()
    var drmKit = AKSampler()
    var vol1: AKBooster?
    var vol2: AKBooster?
    var vol3: AKBooster?
    var vol4: AKBooster?
    var filter:AKMoogLadder?
    
    @IBOutlet var rateSlider: UISlider!
    @IBOutlet var syn1VolSlider: UISlider!
    @IBOutlet var syn2VolSlider: UISlider!
    @IBOutlet var syn3VolSlider: UISlider!
    @IBOutlet var drmVolSlider: UISlider!
    @IBOutlet var filterSlider: UISlider!
    
    @IBOutlet var trk1snd1: UIButton!
    @IBOutlet var trk1snd2: UIButton!
    @IBOutlet var trk1snd3: UIButton!
    @IBOutlet var trk1snd4: UIButton!
    
    @IBOutlet var trk2snd1: UIButton!
    @IBOutlet var trk2snd2: UIButton!
    @IBOutlet var trk2snd3: UIButton!
    @IBOutlet var trk2snd4: UIButton!
    
    @IBOutlet var trk3snd1: UIButton!
    @IBOutlet var trk3snd2: UIButton!
    @IBOutlet var trk3snd3: UIButton!
    @IBOutlet var trk3snd4: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vol1 = AKBooster(syn1)
        vol2 = AKBooster(syn2)
        vol3 = AKBooster(syn3)
        vol4 = AKBooster(drmKit)
        vol1?.gain = 1
        vol2?.gain = 1
        vol3?.gain = 1
        vol4?.gain = 1
        mixer.connect(vol1!)
        mixer.connect(vol2!)
        mixer.connect(vol3!)
        mixer.connect(vol4!)
        
        filter = AKMoogLadder(mixer)
        filter?.cutoffFrequency = 20000
        AudioKit.output = filter
        
        syn2.loadEXS24("Sounds/Sampler Instruments/sawPiano1")
        syn1.loadEXS24("Sounds/Sampler Instruments/sqrTone1")
        syn3.loadEXS24("Sounds/Sampler Instruments/sawPad1")
        drmKit.loadEXS24("Sounds/Sampler Instruments/drumSimp")
        AudioKit.start()
        seq = AKSequencer(filename: "seqDemo", engine: AudioKit.engine)
        seq?.enableLooping()
        seq!.avTracks[1].destinationAudioUnit = syn1.samplerUnit
        seq!.avTracks[2].destinationAudioUnit = syn2.samplerUnit
        seq!.avTracks[3].destinationAudioUnit = syn3.samplerUnit
        seq!.avTracks[4].destinationAudioUnit = drmKit.samplerUnit

        seq!.setLength(Beat(4))
    }
    
    @IBAction func adjustTempo() {
        seq?.setTempo(Double(rateSlider.value))
    }
    
    @IBAction func adjustsyn1Vol() {
        vol1?.gain = Double(syn1VolSlider.value)
    }
    @IBAction func adjustsyn2Vol() {
        vol2?.gain = Double(syn2VolSlider.value)
    }
    @IBAction func adjustsyn3Vol() {
        vol3?.gain = Double(syn3VolSlider.value)
    }
    @IBAction func adjustDrmVol() {
        vol4?.gain = Double(drmVolSlider.value)
    }
    @IBAction func adjustFilt() {
        var val = Double(filterSlider.value)
        val.denormalize(minimum: Double(30.0), maximum: Double(20000.00), taper: 3.03)
        filter?.cutoffFrequency = val
    }
    @IBAction func playSeq() {
        seq!.play()
    }
    @IBAction func stopSeq() {
        seq!.stop()
    }
    @IBAction func rewindSeq() {
        seq!.rewind()
    }
    @IBAction func toggleLoop() {
        seq!.toggleLoop()
        print("loop enabled: \(seq!.loopEnabled)")
    }
    @IBAction func setLength1() {
        seq!.setLength(Beat(1))
        seq!.rewind()
    }
    @IBAction func setLength2() {
        seq!.setLength(Beat(2))
        seq!.rewind()
    }
    @IBAction func setLength4() {
        seq!.setLength(Beat(4))
        seq!.rewind()
    }
    @IBAction func setLength8() {
        seq!.setLength(Beat(8))
        seq!.rewind()
    }
    @IBAction func setLength16() {
        seq!.setLength(Beat(16))
        seq!.rewind()
    }
    @IBAction func useSound1(sender: UIButton) {
        let snd = "Sounds/Sampler Instruments/sqrTone1"
        if(sender == trk1snd1){ syn1.loadEXS24(snd) }
        else if(sender == trk2snd1){ syn2.loadEXS24(snd) }
        else if(sender == trk3snd1){ syn3.loadEXS24(snd) }
    }
    
    @IBAction func useSound2(sender: UIButton) {
        let snd = "Sounds/Sampler Instruments/sawPiano1"
        if(sender == trk1snd2){syn1.loadEXS24(snd) }
        else if(sender == trk2snd2){ syn2.loadEXS24(snd)}
        else if(sender == trk3snd2){ syn3.loadEXS24(snd)}
    }
    @IBAction func useSound3(sender: UIButton) {
        let snd = "Sounds/Sampler Instruments/sawPad1"
        if(sender == trk1snd3){ syn1.loadEXS24(snd) }
        else if(sender == trk2snd3){ syn2.loadEXS24(snd) }
        else if(sender == trk3snd3){ syn3.loadEXS24(snd) }
    }
    @IBAction func useSound4(sender: UIButton) {
        let snd = "Sounds/Sampler Instruments/noisyRez"
        if(sender == trk1snd4){ syn1.loadEXS24(snd) }
        else if(sender == trk2snd4){ syn2.loadEXS24(snd) }
        else if(sender == trk3snd4){ syn3.loadEXS24(snd) }
    }
   }