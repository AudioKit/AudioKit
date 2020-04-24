//
//  AKPitchShifterAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import AVFoundation

public class AKPitchShifterAudioUnit: AKAudioUnitBase {

    private(set) var shift: AUParameter!

    private(set) var windowSize: AUParameter!

    private(set) var crossfade: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createPitchShifterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        shift = AUParameter(
            identifier: "shift",
            name: "Pitch shift (in semitones)",
            address: AKPitchShifterParameter.shift.rawValue,
            range: AKPitchShifter.shiftRange,
            unit: .relativeSemiTones,
            flags: .default)
        windowSize = AUParameter(
            identifier: "windowSize",
            name: "Window size (in samples)",
            address: AKPitchShifterParameter.windowSize.rawValue,
            range: AKPitchShifter.windowSizeRange,
            unit: .hertz,
            flags: .default)
        crossfade = AUParameter(
            identifier: "crossfade",
            name: "Crossfade (in samples)",
            address: AKPitchShifterParameter.crossfade.rawValue,
            range: AKPitchShifter.crossfadeRange,
            unit: .hertz,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [shift, windowSize, crossfade])

        shift.value = AUValue(AKPitchShifter.defaultShift)
        windowSize.value = AUValue(AKPitchShifter.defaultWindowSize)
        crossfade.value = AUValue(AKPitchShifter.defaultCrossfade)
    }
}
