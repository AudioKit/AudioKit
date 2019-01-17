//
//  AKPhaseLockedVocoderAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/31/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKPhaseLockedVocoderAudioUnit: AKGeneratorAudioUnitBase {

    func setParameter(_ address: AKPhaseLockedVocoderParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKPhaseLockedVocoderParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var position: Double = AKPhaseLockedVocoder.defaultPosition {
        didSet { setParameter(.position, value: position) }
    }

    var amplitude: Double = AKPhaseLockedVocoder.defaultAmplitude {
        didSet { setParameter(.amplitude, value: amplitude) }
    }

    var pitchRatio: Double = AKPhaseLockedVocoder.defaultPitchRatio {
        didSet { setParameter(.pitchRatio, value: pitchRatio) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createPhaseLockedVocoderDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let position = AUParameter(
            identifier: "position",
            name: "Position",
            address: AKPhaseLockedVocoderParameter.position.rawValue,
            range: AKPhaseLockedVocoder.positionRange,
            unit: .generic,
            flags: .default)

        let amplitude = AUParameter(
            identifier: "amplitude",
            name: "Amplitude",
            address: AKPhaseLockedVocoderParameter.amplitude.rawValue,
            range: AKPhaseLockedVocoder.amplitudeRange,
            unit: .generic,
            flags: .default)

        let pitchRatio = AUParameter(
            identifier: "pitchRatio",
            name: "Pitch Ratio",
            address: AKPhaseLockedVocoderParameter.pitchRatio.rawValue,
            range: AKPhaseLockedVocoder.pitchRatioRange,
            unit: .generic,
            flags: .default)

        setParameterTree(AUParameterTree(children: [position, amplitude, pitchRatio]))
        position.value = Float(AKPhaseLockedVocoder.defaultPosition)
        amplitude.value = Float(AKPhaseLockedVocoder.defaultAmplitude)
        pitchRatio.value = Float(AKPhaseLockedVocoder.defaultPitchRatio)
    }

    public override var canProcessInPlace: Bool { return true }

}
