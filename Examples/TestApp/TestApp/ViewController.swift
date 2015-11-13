//
//  ViewController.swift
//  TestApp
//
//  Created by Aurelius Prochazka on 9/29/15.
//
//

import UIKit
import AudioKit

class ViewController: UIViewController {
    
    let audiokit = AKManager.sharedInstance
    let input = AKMicrophone()
    var delay:  AKAUDelay?
    var moog:   AKMoogLadder?
    var bandPassFilter: AKBandPassButterworthFilter?
    var allpass: AKFlatFrequencyResponseReverb?
    var reverb: AKAUReverb?
    var jcReverb: AKChowningReverb?
    var verb2: AKAUReverb2?
    var limiter: AKAUPeakLimiter?
    var midi = AKMidi()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        moog    = AKMoogLadder(input)
        delay   = AKAUDelay(moog!)
//        allpass = AKFlatFrequencyResponseReverb(moog!)//, loopDuration: 0.1)
        verb2  = AKAUReverb2(delay!)
        limiter = AKAUPeakLimiter(verb2!)
        //if let reverb = reverb { reverb.loadFactoryPreset(.Cathedral) }
        audiokit.audioOutput = limiter
        //print(verb2?.internalAudioUnit.debugDescription)
        //getAUParams((limiter?.internalAU)!)
        
        */
        audiokit.start()
        midi.openMidiIn("Session 1")
        
        let defaultCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        
        defaultCenter.addObserverForName("AKMidiControl", object: nil, queue: mainQueue, usingBlock: midiNotif)
    }
    
    func midiNotif(notif:NSNotification){
        print(notif.userInfo!)
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

