//
//  ViewController.swift
//  TestApp
//
//  Created by Aurelius Prochazka on 9/29/15.
//
//

import UIKit
import Foundation
import AudioKit

class ViewController: UIViewController {

    let audiokit = AKManager.sharedInstance
    let input = AKMicrophone()
    var delay:  AKDelay?
    var moog:   AKMoogLadder?
    var bandPassFilter: AKBandPassButterworthFilter?
    var allpass: AKFlatFrequencyResponseReverb?
    var reverb: AKReverb?
    var jcReverb: AKChowningReverb?
    var verb2: AKReverb2?
    var limiter: AKPeakLimiter?
    var midi = AKMidi()
    var fmOsc = AKFMOscillator()
    var exs = AKSampler()
    var exs2 = AKSampler()
    var seq = AKSequencer(filename:"4tracks")
    var mixer = AKMixer()

    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        moog    = AKMoogLadder(input)
        delay   = AKDelay(moog!)
//        allpass = AKFlatFrequencyResponseReverb(moog!)//, loopDuration: 0.1)
        verb2  = AKReverb2(delay!)
        limiter = AKPeakLimiter(verb2!)
        //if let reverb = reverb { reverb.loadFactoryPreset(.Cathedral) }
        audiokit.audioOutput = limiter
        //print(verb2?.internalAudioUnit.debugDescription)
        //getAUParams((limiter?.internalAU)!)

        */
//        exs.loadEXS24("Sounds/sawPiano1")
//        exs2.loadWav("Sounds/kylebell1-shrt")

        mixer.connect(exs)
        mixer.connect(exs2)
        moog    = AKMoogLadder(mixer)
        verb2  = AKReverb2(moog!)
        audiokit.audioOutput = verb2

        audiokit.start()

        midi.openMidiOut("Session 1")
        midi.openMidiIn("Session 1")
        let defaultCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        //        defaultCenter.addObserverForName(AKMidiStatus.ControllerChange.name(), object: nil, queue: mainQueue, usingBlock: midiNotif)

        //        defaultCenter.addObserverForName(AKMidiStatus.NoteOn.name(), object: nil, queue: mainQueue, usingBlock: midiNoteNotif)

        seq.setGlobalMidiOutput(midi)
        seq.setLength(4)
        CAShow(seq.sequencePointer)
        print(seq.length)

    }

    func midiNotif(notif:NSNotification){
        print(notif.userInfo!)
        exs.playNote(Int(arc4random_uniform(127)))
        exs2.playNote(Int(arc4random_uniform(127)))
    }

    func midiNoteNotif(notif:NSNotification){
        exs.playNote(Int((notif.userInfo?["note"])! as! NSNumber))
        exs2.playNote(Int((notif.userInfo?["note"])! as! NSNumber))
//        exs2.playNote(notif.userInfo?.indexForKey("note"))
    }
    @IBAction func playNote(){
//        exs.playNote(Int(arc4random_uniform(127)))
        seq.play()
    }
    @IBAction func playNote2(){
        seq.rewind()
//        exs2.playNote(Int(arc4random_uniform(127)))
    }
    @IBAction func playNoteboth(){
        seq.loopToggle()
        print(seq.loopEnabled)
//        exs.playNote(Int(arc4random_uniform(127)))
//        exs2.playNote(Int(arc4random_uniform(127)))
    }
    @IBAction func connectMidi(){
        midi.openMidiOut("Session 1")
    }
    @IBAction func sendMidi(){
        let event = AKMidiEvent.eventWithNoteOn(33, velocity: 127, channel: 0)
        midi.sendMidiEvent(event)
    }
    @IBAction func sendMidiController(sender: UISlider){
        let event = AKMidiEvent.eventWithController(33, val: UInt8(sender.value * 127), channel: 0)
        midi.sendMidiEvent(event)
    }
    @IBAction func changeReverb(sender: UISlider) {
        guard let reverb = verb2 else { return }
        reverb.dryWetMix = 100.0 * sender.value
    }
    @IBAction func changeDelayTime(sender: UISlider) {
        //if let delay = delay { delay.delayTime = NSTimeInterval(sender.value) }
    }
    @IBAction func changeCutoff(sender: UISlider) {
        guard let moog = moog else { return }
        moog.cutoffFrequency = sender.value * 10000.0
    }
    @IBAction func changeResonance(sender: UISlider) {
        guard let moog = moog else { return }
        moog.resonance = sender.value * 0.98
    }
    @IBAction func changeReverbDuration(sender: UISlider) {
//        guard let allpass = allpass else { return }
//        allpass.reverbDuration = sender.value * 5.0
        guard let verb = verb2 else {return}
        verb.decayTime = sender.value * 20.0
    }
    func getAUParams(inputAU: AudioUnit)->([AudioUnitParameterInfo]){
        //  Get number of parameters in this unit (size in bytes really):
        var size: UInt32 = 0
        var propertyBool = DarwinBoolean(true)

        AudioUnitGetPropertyInfo(inputAU, kAudioUnitProperty_ParameterList, kAudioUnitScope_Global, 0, &size, &propertyBool)
        let numParams = Int(size)/sizeof(AudioUnitParameterID)
        var parameterIDs = [AudioUnitParameterID](count: Int(numParams), repeatedValue: 0)
        AudioUnitGetProperty(inputAU, kAudioUnitProperty_ParameterList, kAudioUnitScope_Global, 0, &parameterIDs, &size)
        var paramInfo = AudioUnitParameterInfo()
        var outParams = [AudioUnitParameterInfo]()
        var parameterInfoSize:UInt32 = UInt32(sizeof(AudioUnitParameterInfo))
        for paramID in parameterIDs{
            AudioUnitGetProperty(inputAU, kAudioUnitProperty_ParameterInfo, kAudioUnitScope_Global, paramID, &paramInfo, &parameterInfoSize)
            outParams.append(paramInfo)
            print(paramID)
            print("Paramer name :\(paramInfo.cfNameString?.takeUnretainedValue()) | Min:\(paramInfo.minValue) | Max:\(paramInfo.maxValue) | Default: \(paramInfo.defaultValue)")
        }
        return outParams
    }//getAUParams
}

