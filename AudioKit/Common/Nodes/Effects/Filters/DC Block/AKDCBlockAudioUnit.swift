//
//  AKDCBlockAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKDCBlockAudioUnit: AKAudioUnitBase {

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createDCBlockDSP(Int32(count), sampleRate)
    }

    public override var canProcessInPlace: Bool { get { return true; }}

}
