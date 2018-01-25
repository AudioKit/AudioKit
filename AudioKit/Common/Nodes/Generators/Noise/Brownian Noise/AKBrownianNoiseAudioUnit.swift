//
//  AKBrownianNoiseAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKBrownianNoiseAudioUnit: AKGeneratorAudioUnitBase {

    func setParameter(_ address: AKBrownianNoiseParameter, value: Double) {
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKBrownianNoiseParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var amplitude: Double = 1 {
        didSet { setParameter(.amplitude, value: amplitude) }
    }

    var rampTime: Double = 0.0 {
        didSet { setParameter(.rampTime, value: rampTime) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createBrownianNoiseDSP(Int32(count), sampleRate)
    }

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let amplitude = AUParameterTree.createParameter(
            withIdentifier: "amplitude",
            name: "Amplitude",
            address: AUParameterAddress(0),
            min: 0.0,
            max: 1.0,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [amplitude]))
        amplitude.value = 1
    }

    public override var canProcessInPlace: Bool { get { return true; }}

}
