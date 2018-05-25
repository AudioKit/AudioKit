//
//  AKPitchShifterAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKPitchShifterAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKPitchShifterParameter, value: Double) {
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKPitchShifterParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var shift: Double = AKPitchShifter.defaultShift {
        didSet { setParameter(.shift, value: shift) }
    }

    var windowSize: Double = AKPitchShifter.defaultWindowSize {
        didSet { setParameter(.windowSize, value: windowSize) }
    }

    var crossfade: Double = AKPitchShifter.defaultCrossfade {
        didSet { setParameter(.crossfade, value: crossfade) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createPitchShifterDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let shift = AUParameterTree.createParameter(
            withIdentifier: "shift",
            name: "Pitch shift (in semitones)",
            address: AUParameterAddress(0),
            min: Float(AKPitchShifter.shiftRange.lowerBound),
            max: Float(AKPitchShifter.shiftRange.upperBound),
            unit: .relativeSemiTones,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let windowSize = AUParameterTree.createParameter(
            withIdentifier: "windowSize",
            name: "Window size (in samples)",
            address: AUParameterAddress(1),
            min: Float(AKPitchShifter.windowSizeRange.lowerBound),
            max: Float(AKPitchShifter.windowSizeRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let crossfade = AUParameterTree.createParameter(
            withIdentifier: "crossfade",
            name: "Crossfade (in samples)",
            address: AUParameterAddress(2),
            min: Float(AKPitchShifter.crossfadeRange.lowerBound),
            max: Float(AKPitchShifter.crossfadeRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [shift, windowSize, crossfade]))
        shift.value = Float(AKPitchShifter.defaultShift)
        windowSize.value = Float(AKPitchShifter.defaultWindowSize)
        crossfade.value = Float(AKPitchShifter.defaultCrossfade)
    }

    public override var canProcessInPlace: Bool { return true } 

}
