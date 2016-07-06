//
//  BDInstrument.swift
//  SequencerDemo
//
//  Created by Kanstantsin Linou on 6/30/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit

class BDInstrument: AKPolyphonicInstrument {
    init(voiceCount: Int) {
        super.init(voice: BDVoice(), voiceCount: voiceCount)
    }
    override func play(voice voice: AKVoice, noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {
        voice.start()
    }
    override func stop(voice voice: AKVoice, noteNumber: MIDINoteNumber) {
        
    }
}
