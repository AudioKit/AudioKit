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

        let position = AUParameterTree.createParameter(
            withIdentifier: "position",
            name: "Position",
            address: AKPhaseLockedVocoderParameter.position.rawValue,
            min: Float(AKPhaseLockedVocoder.positionRange.lowerBound),
            max: Float(AKPhaseLockedVocoder.positionRange.upperBound),
            unit: .generic,
            flags: .default)

        let amplitude = AUParameterTree.createParameter(
            withIdentifier: "amplitude",
            name: "Amplitude",
            address: AKPhaseLockedVocoderParameter.amplitude.rawValue,
            min: Float(AKPhaseLockedVocoder.amplitudeRange.lowerBound),
            max: Float(AKPhaseLockedVocoder.amplitudeRange.upperBound),
            unit: .generic,
            flags: .default)

        let pitchRatio = AUParameterTree.createParameter(
            withIdentifier: "pitchRatio",
            name: "Pitch Ratio",
            address: AKPhaseLockedVocoderParameter.pitchRatio.rawValue,
            min: Float(AKPhaseLockedVocoder.pitchRatioRange.lowerBound),
            max: Float(AKPhaseLockedVocoder.pitchRatioRange.upperBound),
            unit: .generic,
            flags: .default)

        setParameterTree(AUParameterTree.createTree(withChildren: [position, amplitude, pitchRatio]))
        position.value = Float(AKPhaseLockedVocoder.defaultPosition)
        amplitude.value = Float(AKPhaseLockedVocoder.defaultAmplitude)
        pitchRatio.value = Float(AKPhaseLockedVocoder.defaultPitchRatio)
    }

    public override var canProcessInPlace: Bool { return true }

}
