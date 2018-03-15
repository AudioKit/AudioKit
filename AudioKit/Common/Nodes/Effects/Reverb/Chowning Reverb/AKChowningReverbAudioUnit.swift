//
//  AKChowningReverbAudioUnit.swift
//  AudioKit
//
//  Created by Andrew Voelkel on 9/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AVFoundation

public class AKChowningReverbAudioUnit: AKAudioUnitBase {

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createChowningReverbDSP(Int32(count), sampleRate)
    }

    public override var canProcessInPlace: Bool { get { return true; }}

}
