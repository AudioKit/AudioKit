//
//  AKPhaserAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKPhaserAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKPhaserParameter, value: Double) {
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKPhaserParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var notchMinimumFrequency: Double = 100 {
        didSet { setParameter(.notchMinimumFrequency, value: notchMinimumFrequency) }
    }
    var notchMaximumFrequency: Double = 800 {
        didSet { setParameter(.notchMaximumFrequency, value: notchMaximumFrequency) }
    }
    var notchWidth: Double = 1_000 {
        didSet { setParameter(.notchWidth, value: notchWidth) }
    }
    var notchFrequency: Double = 1.5 {
        didSet { setParameter(.notchFrequency, value: notchFrequency) }
    }
    var vibratoMode: Double = 1 {
        didSet { setParameter(.vibratoMode, value: vibratoMode) }
    }
    var depth: Double = 1 {
        didSet { setParameter(.depth, value: depth) }
    }
    var feedback: Double = 0 {
        didSet { setParameter(.feedback, value: feedback) }
    }
    var inverted: Double = 0 {
        didSet { setParameter(.inverted, value: inverted) }
    }
    var lfoBPM: Double = 30 {
        didSet { setParameter(.lfoBPM, value: lfoBPM) }
    }

    var rampTime: Double = 0.0 {
        didSet { setParameter(.rampTime, value: rampTime) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createPhaserDSP(Int32(count), sampleRate)
    }

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let notchMinimumFrequency = AUParameterTree.createParameter(
            withIdentifier: "notchMinimumFrequency",
            name: "Notch Minimum Frequency",
            address: AUParameterAddress(0),
            min: 20,
            max: 5_000,
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let notchMaximumFrequency = AUParameterTree.createParameter(
            withIdentifier: "notchMaximumFrequency",
            name: "Notch Maximum Frequency",
            address: AUParameterAddress(1),
            min: 20,
            max: 10_000,
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let notchWidth = AUParameterTree.createParameter(
            withIdentifier: "notchWidth",
            name: "Between 10 and 5000",
            address: AUParameterAddress(2),
            min: 10,
            max: 5_000,
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let notchFrequency = AUParameterTree.createParameter(
            withIdentifier: "notchFrequency",
            name: "Between 1.1 and 4",
            address: AUParameterAddress(3),
            min: 1.1,
            max: 4.0,
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let vibratoMode = AUParameterTree.createParameter(
            withIdentifier: "vibratoMode",
            name: "Direct or Vibrato (default)",
            address: AUParameterAddress(4),
            min: 0,
            max: 1,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let depth = AUParameterTree.createParameter(
            withIdentifier: "depth",
            name: "Between 0 and 1",
            address: AUParameterAddress(5),
            min: 0,
            max: 1,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let feedback = AUParameterTree.createParameter(
            withIdentifier: "feedback",
            name: "Between 0 and 1",
            address: AUParameterAddress(6),
            min: 0,
            max: 1,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let inverted = AUParameterTree.createParameter(
            withIdentifier: "inverted",
            name: "1 or 0",
            address: AUParameterAddress(7),
            min: 0,
            max: 1,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let lfoBPM = AUParameterTree.createParameter(
            withIdentifier: "lfoBPM",
            name: "Between 24 and 360",
            address: AUParameterAddress(8),
            min: 24,
            max: 360,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [notchMinimumFrequency, notchMaximumFrequency, notchWidth, notchFrequency, vibratoMode, depth, feedback, inverted, lfoBPM]))
        notchMinimumFrequency.value = 100
        notchMaximumFrequency.value = 800
        notchWidth.value = 1_000
        notchFrequency.value = 1.5
        vibratoMode.value = 1
        depth.value = 1
        feedback.value = 0
        inverted.value = 0
        lfoBPM.value = 30
    }

    public override var canProcessInPlace: Bool { get { return true; }}

}
