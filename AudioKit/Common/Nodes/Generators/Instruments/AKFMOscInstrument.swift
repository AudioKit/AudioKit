//
//  AKFMOscInstrument.swift
//  AudioKit For iOS
//
//  Created by Jeff Cooper on 1/6/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

public class AKFMOscIsntrument: AKMidiInstrument{
    public init(numVoicesInit: Int) {
        super.init(inst: AKFMOscillator(), numVoicesInit: numVoicesInit)
        for voice in voices{
            let fmVoice = voice as! AKFMOscillator
            fmVoice.modulatingMultiplier = 4 //just some arbitrary default values
            fmVoice.modulationIndex = 10
        }
    }
    public override func startVoice(voice: Int, note: UInt8, withVelocity velocity: UInt8, onChannel channel: UInt8) {
        let frequency = Int(note).midiNoteToFrequency()
        let amplitude = Double(velocity)/127.0
        let fmVoice = voices[voice] as! AKFMOscillator //you'll need to cast the voice to it's original form
        fmVoice.baseFrequency = frequency
        fmVoice.amplitude = amplitude
        fmVoice.start()
    }
    public override func stopVoice(voice: Int, note: UInt8, onChannel channel: UInt8) {
        let fmVoice = voices[voice] as! AKFMOscillator //you'll need to cast the voice to it's original form
        fmVoice.amplitude = 0
        fmVoice.stop()
    }
    
    public func setModAmount(amt: Double){
        for voice in voices{
            let fmVoice = voice as! AKFMOscillator
            fmVoice.modulationIndex = amt
        }
    }
}