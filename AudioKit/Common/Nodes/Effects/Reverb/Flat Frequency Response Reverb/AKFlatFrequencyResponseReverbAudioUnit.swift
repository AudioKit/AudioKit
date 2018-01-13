//
//  AKFlatFrequencyResponseReverbAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKFlatFrequencyResponseReverbAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKFlatFrequencyResponseReverbParameter, value: Double) {
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKFlatFrequencyResponseReverbParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var reverbDuration: Double = 0.5 {
        didSet { setParameter(.reverbDuration, value: reverbDuration) }
    }

    var rampTime: Double = 0.0 {
        didSet { setParameter(.rampTime, value: rampTime) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createFlatFrequencyResponseReverbDSP(Int32(count), sampleRate)
    }

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let reverbDuration = AUParameterTree.createParameter(
            withIdentifier: "reverbDuration",
            name: "Reverb Duration (Seconds)",
            address: AUParameterAddress(0),
            min: 0,
            max: 10,
            unit: .seconds,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        

        setParameterTree(AUParameterTree.createTree(withChildren: [reverbDuration]))
        reverbDuration.value = 0.5
    }

    public override var canProcessInPlace: Bool { get { return true; }}

}
