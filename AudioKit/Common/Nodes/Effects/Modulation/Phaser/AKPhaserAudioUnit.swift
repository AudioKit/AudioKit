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

        let notchMinimumFrequency = AUParameter(
            identifier: "notchMinimumFrequency",
            name: "Notch Minimum Frequency",
            address: AKPhaserParameter.notchMinimumFrequency.rawValue,
            range: AKPhaser.notchMinimumFrequencyRange,
            unit: .hertz,
            flags: .default)
        let notchMaximumFrequency = AUParameter(
            identifier: "notchMaximumFrequency",
            name: "Notch Maximum Frequency",
            address: AKPhaserParameter.notchMaximumFrequency.rawValue,
            range: AKPhaser.notchMaximumFrequencyRange,
            unit: .hertz,
            flags: .default)
        let notchWidth = AUParameter(
            identifier: "notchWidth",
            name: "Between 10 and 5000",
            address: AKPhaserParameter.notchWidth.rawValue,
            range: AKPhaser.notchWidthRange,
            unit: .hertz,
            flags: .default)
        let notchFrequency = AUParameter(
            identifier: "notchFrequency",
            name: "Between 1.1 and 4",
            address: AKPhaserParameter.notchFrequency.rawValue,
            range: AKPhaser.notchFrequencyRange,
            unit: .hertz,
            flags: .default)
        let vibratoMode = AUParameter(
            identifier: "vibratoMode",
            name: "Direct or Vibrato (default)",
            address: AKPhaserParameter.vibratoMode.rawValue,
            range: AKPhaser.vibratoModeRange,
            unit: .generic,
            flags: .default)
        let depth = AUParameter(
            identifier: "depth",
            name: "Between 0 and 1",
            address: AKPhaserParameter.depth.rawValue,
            range: AKPhaser.depthRange,
            unit: .generic,
            flags: .default)
        let feedback = AUParameter(
            identifier: "feedback",
            name: "Between 0 and 1",
            address: AKPhaserParameter.feedback.rawValue,
            range: AKPhaser.feedbackRange,
            unit: .generic,
            flags: .default)
        let inverted = AUParameter(
            identifier: "inverted",
            name: "1 or 0",
            address: AKPhaserParameter.inverted.rawValue,
            range: AKPhaser.invertedRange,
            unit: .generic,
            flags: .default)
        let lfoBPM = AUParameter(
            identifier: "lfoBPM",
            name: "Between 24 and 360",
            address: AKPhaserParameter.lfoBPM.rawValue,
            range: AKPhaser.lfoBPMRange,
            unit: .generic,
            flags: .default)

        setParameterTree(AUParameterTree(children: [notchMinimumFrequency, notchMaximumFrequency, notchWidth, notchFrequency, vibratoMode, depth, feedback, inverted, lfoBPM]))
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
