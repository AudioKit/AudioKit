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
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKPhaserParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var notchMinimumFrequency: Double = AKPhaser.defaultNotchMinimumFrequency {
        didSet { setParameter(.notchMinimumFrequency, value: notchMinimumFrequency) }
    }

    var notchMaximumFrequency: Double = AKPhaser.defaultNotchMaximumFrequency {
        didSet { setParameter(.notchMaximumFrequency, value: notchMaximumFrequency) }
    }

    var notchWidth: Double = AKPhaser.defaultNotchWidth {
        didSet { setParameter(.notchWidth, value: notchWidth) }
    }

    var notchFrequency: Double = AKPhaser.defaultNotchFrequency {
        didSet { setParameter(.notchFrequency, value: notchFrequency) }
    }

    var vibratoMode: Double = AKPhaser.defaultVibratoMode {
        didSet { setParameter(.vibratoMode, value: vibratoMode) }
    }

    var depth: Double = AKPhaser.defaultDepth {
        didSet { setParameter(.depth, value: depth) }
    }

    var feedback: Double = AKPhaser.defaultFeedback {
        didSet { setParameter(.feedback, value: feedback) }
    }

    var inverted: Double = AKPhaser.defaultInverted {
        didSet { setParameter(.inverted, value: inverted) }
    }

    var lfoBPM: Double = AKPhaser.defaultLfoBPM {
        didSet { setParameter(.lfoBPM, value: lfoBPM) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createPhaserDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let notchMinimumFrequency = AUParameterTree.createParameter(
            withIdentifier: "notchMinimumFrequency",
            name: "Notch Minimum Frequency",
            address: AKPhaserParameter.notchMinimumFrequency.rawValue,
            min: Float(AKPhaser.notchMinimumFrequencyRange.lowerBound),
            max: Float(AKPhaser.notchMinimumFrequencyRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let notchMaximumFrequency = AUParameterTree.createParameter(
            withIdentifier: "notchMaximumFrequency",
            name: "Notch Maximum Frequency",
            address: AKPhaserParameter.notchMaximumFrequency.rawValue,
            min: Float(AKPhaser.notchMaximumFrequencyRange.lowerBound),
            max: Float(AKPhaser.notchMaximumFrequencyRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let notchWidth = AUParameterTree.createParameter(
            withIdentifier: "notchWidth",
            name: "Between 10 and 5000",
            address: AKPhaserParameter.notchWidth.rawValue,
            min: Float(AKPhaser.notchWidthRange.lowerBound),
            max: Float(AKPhaser.notchWidthRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let notchFrequency = AUParameterTree.createParameter(
            withIdentifier: "notchFrequency",
            name: "Between 1.1 and 4",
            address: AKPhaserParameter.notchFrequency.rawValue,
            min: Float(AKPhaser.notchFrequencyRange.lowerBound),
            max: Float(AKPhaser.notchFrequencyRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let vibratoMode = AUParameterTree.createParameter(
            withIdentifier: "vibratoMode",
            name: "Direct or Vibrato (default)",
            address: AKPhaserParameter.vibratoMode.rawValue,
            min: Float(AKPhaser.vibratoModeRange.lowerBound),
            max: Float(AKPhaser.vibratoModeRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let depth = AUParameterTree.createParameter(
            withIdentifier: "depth",
            name: "Between 0 and 1",
            address: AKPhaserParameter.depth.rawValue,
            min: Float(AKPhaser.depthRange.lowerBound),
            max: Float(AKPhaser.depthRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let feedback = AUParameterTree.createParameter(
            withIdentifier: "feedback",
            name: "Between 0 and 1",
            address: AKPhaserParameter.feedback.rawValue,
            min: Float(AKPhaser.feedbackRange.lowerBound),
            max: Float(AKPhaser.feedbackRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let inverted = AUParameterTree.createParameter(
            withIdentifier: "inverted",
            name: "1 or 0",
            address: AKPhaserParameter.inverted.rawValue,
            min: Float(AKPhaser.invertedRange.lowerBound),
            max: Float(AKPhaser.invertedRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let lfoBPM = AUParameterTree.createParameter(
            withIdentifier: "lfoBPM",
            name: "Between 24 and 360",
            address: AKPhaserParameter.lfoBPM.rawValue,
            min: Float(AKPhaser.lfoBPMRange.lowerBound),
            max: Float(AKPhaser.lfoBPMRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        
        setParameterTree(AUParameterTree.createTree(withChildren: [notchMinimumFrequency, notchMaximumFrequency, notchWidth, notchFrequency, vibratoMode, depth, feedback, inverted, lfoBPM]))
        notchMinimumFrequency.value = Float(AKPhaser.defaultNotchMinimumFrequency)
        notchMaximumFrequency.value = Float(AKPhaser.defaultNotchMaximumFrequency)
        notchWidth.value = Float(AKPhaser.defaultNotchWidth)
        notchFrequency.value = Float(AKPhaser.defaultNotchFrequency)
        vibratoMode.value = Float(AKPhaser.defaultVibratoMode)
        depth.value = Float(AKPhaser.defaultDepth)
        feedback.value = Float(AKPhaser.defaultFeedback)
        inverted.value = Float(AKPhaser.defaultInverted)
        lfoBPM.value = Float(AKPhaser.defaultLfoBPM)
    }

    public override var canProcessInPlace: Bool { return true }

}
