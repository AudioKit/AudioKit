// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import Utilities

#if os(macOS)

/// AudioKit version of Apple's Reverb Audio Unit
///
public class MatrixReverb: Node {
    public var au: AUAudioUnit

    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    // Hacking start, stop, play, and bypass to use dryWetMix because reverbAU's bypass results in no sound

    /// Specification details for dry wet mix
    public static let wetDryMixDef = NodeParameterDef(
        identifier: "wetDryMix",
        name: "Wet-Dry Mix",
        address: 0,
        defaultValue: 100,
        range: 0.0 ... 100.0,
        unit: .generic
    )

    /// Wet/Dry mix. Should be a value between 0-100.
    @Parameter(wetDryMixDef) public var wetDryMix: AUValue

    /// Load an Apple Factory Preset
    public func loadFactoryPreset(_ preset: ReverbPreset) {
        let auPreset = AUAudioUnitPreset()
        auPreset.number = preset.rawValue
        au.currentPreset = auPreset
    }

    /// Initialize the reverb node
    ///
    /// - Parameters:
    ///   - input: Node to reverberate
    ///   - wetDryMix: Amount of processed signal (Default: 100, Range: 0 - 100)
    ///
    public init(_ input: Node, wetDryMix: AUValue = 100) {
        self.input = input

        let desc = AudioComponentDescription(appleEffect: kAudioUnitSubType_MatrixReverb)
        au = instantiateAU(componentDescription: desc)
        associateParams(with: au)

        self.wetDryMix = wetDryMix

    }
}

#endif // os(macOS)
