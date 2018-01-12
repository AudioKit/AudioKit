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

    var shift: Double = 0 {
        didSet { setParameter(.shift, value: shift) }
    }
    var windowSize: Double = 1_024 {
        didSet { setParameter(.windowSize, value: windowSize) }
    }
    var crossfade: Double = 512 {
        didSet { setParameter(.crossfade, value: crossfade) }
    }

    var rampTime: Double = 0.0 {
        didSet { setParameter(.rampTime, value: rampTime) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createPitchShifterDSP(Int32(count), sampleRate)
    }

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let shift = AUParameterTree.createParameter(
            withIdentifier: "shift",
            name: "Pitch shift (in semitones)",
            address: AUParameterAddress(0),
            min: -24.0,
            max: 24.0,
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
            min: 0.0,
            max: 10_000.0,
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
            min: 0.0,
            max: 10_000.0,
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [shift, windowSize, crossfade]))
        shift.value = 0
        windowSize.value = 1_024
        crossfade.value = 512
    }

    public override var canProcessInPlace: Bool { get { return true; }}

}
