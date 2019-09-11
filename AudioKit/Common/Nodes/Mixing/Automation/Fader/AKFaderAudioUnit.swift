//
//  AKFaderAudioUnit.swift
//  AudioKit
//
//  Created by Ryan Francesconi, revision history on Github.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import AVFoundation

public class AKFaderAudioUnit: AKAudioUnitBase {
    var leftGain: Double = 1.0 {
        didSet { setParameter(.leftGain, value: leftGain) }
    }

    var rightGain: Double = 1.0 {
        didSet { setParameter(.rightGain, value: rightGain) }
    }

    public override var canProcessInPlace: Bool { return true }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createFaderDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let leftGain = AUParameter(
            identifier: "leftGain",
            name: "Left Gain",
            address: 0,
            range: 0.0 ... 2.0,
            unit: .linearGain,
            flags: .default)

        let rightGain = AUParameter(
            identifier: "rightGain",
            name: "Right Gain",
            address: 1,
            range: 0.0 ... 2.0,
            unit: .linearGain,
            flags: .default)

        setParameterTree(AUParameterTree(children: [leftGain, rightGain]))
        leftGain.value = 1.0
        rightGain.value = 1.0
    }

    func setParameter(_ address: AKFaderParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKFaderParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }
}
