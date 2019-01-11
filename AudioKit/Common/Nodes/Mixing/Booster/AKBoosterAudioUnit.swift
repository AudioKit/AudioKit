//
//  AKBoosterAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKBoosterAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKBoosterParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKBoosterParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var leftGain: Double = 1.0 {
        didSet { setParameter(.leftGain, value: leftGain) }
    }

    var rightGain: Double = 1.0 {
        didSet { setParameter(.rightGain, value: rightGain) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    var rampType: Int = 0 {
        didSet {
            setParameter(.rampType, value: Double(rampType))
        }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createBoosterDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let leftGain = AUParameter(
            identifier: "leftGain",
            name: "Left Boosting Amount",
            address: 0,
            range: 0.0...2.0,
            unit: .linearGain,
            flags: .default)

        let rightGain = AUParameter(
            identifier: "rightGain",
            name: "Right Boosting Amount",
            address: 1,
            range: 0.0...2.0,
            unit: .linearGain,
            flags: .default)

        setParameterTree(AUParameterTree(children: [leftGain, rightGain]))
        leftGain.value = 1.0
        rightGain.value = 1.0
    }

    public override var canProcessInPlace: Bool { return true }

}
