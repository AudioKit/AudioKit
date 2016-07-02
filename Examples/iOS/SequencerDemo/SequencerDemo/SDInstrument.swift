//
//  SDInstrument.swift
//  SequencerDemo
//
//  Created by Kanstantsin Linou on 6/30/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit

class SDInstrument: AKPolyphonicInstrument {
    init(voiceCount: Int, dur: Double = 0.143, res: Double = 0.9) {
        super.init(voice: SDVoice(dur: dur, res:res), voiceCount: voiceCount)
    }
    override func play(voice voice: AKVoice, noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {
        let tempVoice = voice as! SDVoice
        tempVoice.cutoff = (Double(velocity)/127.0 * 1600.0) + 300.0
        voice.start()
    }
    override func stop(voice voice: AKVoice, noteNumber: MIDINoteNumber) {
        
    }
}