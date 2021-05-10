// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
// This file was auto-autogenerated by scripts and templates at http://github.com/AudioKit/AudioKitDevTools/

import AVFoundation
import CAudioKit

/// 3-pole (18 db/oct slope) Low-Pass filter with resonance and tanh distortion.
public class ThreePoleLowpassFilter: Node {

    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Underlying AVAudioNode
    public var avAudioNode = instantiate2(effect: "lp18")

    // MARK: - Parameters

    /// Specification details for distortion
    public static let distortionDef = NodeParameterDef(
        identifier: "distortion",
        name: "Distortion (%)",
        address: akGetParameterAddress("ThreePoleLowpassFilterParameterDistortion"),
        defaultValue: 0.5,
        range: 0.0 ... 2.0,
        unit: .percent)

    /// Distortion amount.  Zero gives a clean output. Greater than zero adds tanh distortion controlled by the filter parameters, in such a way that both low cutoff and high resonance increase the distortion amount.
    @Parameter(distortionDef) public var distortion: AUValue

    /// Specification details for cutoffFrequency
    public static let cutoffFrequencyDef = NodeParameterDef(
        identifier: "cutoffFrequency",
        name: "Cutoff Frequency (Hz)",
        address: akGetParameterAddress("ThreePoleLowpassFilterParameterCutoffFrequency"),
        defaultValue: 1_500,
        range: 12.0 ... 20_000.0,
        unit: .hertz)

    /// Filter cutoff frequency in Hertz.
    @Parameter(cutoffFrequencyDef) public var cutoffFrequency: AUValue

    /// Specification details for resonance
    public static let resonanceDef = NodeParameterDef(
        identifier: "resonance",
        name: "Resonance (%)",
        address: akGetParameterAddress("ThreePoleLowpassFilterParameterResonance"),
        defaultValue: 0.5,
        range: 0.0 ... 2.0,
        unit: .percent)

    /// Resonance. Usually a value in the range 0-1. A value of 1.0 will self oscillate at the cutoff frequency. Values slightly greater than 1 are possible for more sustained oscillation and an “overdrive” effect.
    @Parameter(resonanceDef) public var resonance: AUValue

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - distortion: Distortion amount.  Zero gives a clean output. Greater than zero adds tanh distortion controlled by the filter parameters, in such a way that both low cutoff and high resonance increase the distortion amount.
    ///   - cutoffFrequency: Filter cutoff frequency in Hertz.
    ///   - resonance: Resonance. Usually a value in the range 0-1. A value of 1.0 will self oscillate at the cutoff frequency. Values slightly greater than 1 are possible for more sustained oscillation and an “overdrive” effect.
    ///
    public init(
        _ input: Node,
        distortion: AUValue = distortionDef.defaultValue,
        cutoffFrequency: AUValue = cutoffFrequencyDef.defaultValue,
        resonance: AUValue = resonanceDef.defaultValue
        ) {
        self.input = input

        setupParameters()

        self.distortion = distortion
        self.cutoffFrequency = cutoffFrequency
        self.resonance = resonance
   }
}
