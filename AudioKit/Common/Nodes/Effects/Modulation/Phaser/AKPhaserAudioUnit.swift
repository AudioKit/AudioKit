// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKPhaserAudioUnit: AKAudioUnitBase {

    private(set) var notchMinimumFrequency: AUParameter!

    private(set) var notchMaximumFrequency: AUParameter!

    private(set) var notchWidth: AUParameter!

    private(set) var notchFrequency: AUParameter!

    private(set) var vibratoMode: AUParameter!

    private(set) var depth: AUParameter!

    private(set) var feedback: AUParameter!

    private(set) var inverted: AUParameter!

    private(set) var lfoBPM: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createPhaserDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        notchMinimumFrequency = AUParameter(
            identifier: "notchMinimumFrequency",
            name: "Notch Minimum Frequency",
            address: AKPhaserParameter.notchMinimumFrequency.rawValue,
            range: AKPhaser.notchMinimumFrequencyRange,
            unit: .hertz,
            flags: .default)
        notchMaximumFrequency = AUParameter(
            identifier: "notchMaximumFrequency",
            name: "Notch Maximum Frequency",
            address: AKPhaserParameter.notchMaximumFrequency.rawValue,
            range: AKPhaser.notchMaximumFrequencyRange,
            unit: .hertz,
            flags: .default)
        notchWidth = AUParameter(
            identifier: "notchWidth",
            name: "Between 10 and 5000",
            address: AKPhaserParameter.notchWidth.rawValue,
            range: AKPhaser.notchWidthRange,
            unit: .hertz,
            flags: .default)
        notchFrequency = AUParameter(
            identifier: "notchFrequency",
            name: "Between 1.1 and 4",
            address: AKPhaserParameter.notchFrequency.rawValue,
            range: AKPhaser.notchFrequencyRange,
            unit: .hertz,
            flags: .default)
        vibratoMode = AUParameter(
            identifier: "vibratoMode",
            name: "Direct or Vibrato (default)",
            address: AKPhaserParameter.vibratoMode.rawValue,
            range: AKPhaser.vibratoModeRange,
            unit: .generic,
            flags: .default)
        depth = AUParameter(
            identifier: "depth",
            name: "Between 0 and 1",
            address: AKPhaserParameter.depth.rawValue,
            range: AKPhaser.depthRange,
            unit: .generic,
            flags: .default)
        feedback = AUParameter(
            identifier: "feedback",
            name: "Between 0 and 1",
            address: AKPhaserParameter.feedback.rawValue,
            range: AKPhaser.feedbackRange,
            unit: .generic,
            flags: .default)
        inverted = AUParameter(
            identifier: "inverted",
            name: "1 or 0",
            address: AKPhaserParameter.inverted.rawValue,
            range: AKPhaser.invertedRange,
            unit: .generic,
            flags: .default)
        lfoBPM = AUParameter(
            identifier: "lfoBPM",
            name: "Between 24 and 360",
            address: AKPhaserParameter.lfoBPM.rawValue,
            range: AKPhaser.lfoBPMRange,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [notchMinimumFrequency, notchMaximumFrequency, notchWidth, notchFrequency, vibratoMode, depth, feedback, inverted, lfoBPM])

        notchMinimumFrequency.value = AUValue(AKPhaser.defaultNotchMinimumFrequency)
        notchMaximumFrequency.value = AUValue(AKPhaser.defaultNotchMaximumFrequency)
        notchWidth.value = AUValue(AKPhaser.defaultNotchWidth)
        notchFrequency.value = AUValue(AKPhaser.defaultNotchFrequency)
        vibratoMode.value = AUValue(AKPhaser.defaultVibratoMode)
        depth.value = AUValue(AKPhaser.defaultDepth)
        feedback.value = AUValue(AKPhaser.defaultFeedback)
        inverted.value = AUValue(AKPhaser.defaultInverted)
        lfoBPM.value = AUValue(AKPhaser.defaultLfoBPM)
    }
}
