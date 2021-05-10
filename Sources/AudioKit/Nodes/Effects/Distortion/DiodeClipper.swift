// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Clips a signal to a predefined limit, in a "soft" manner, using one of three
/// methods.
///
public class DiodeClipper: Node {
    
    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Underlying AVAudioNode
    public var avAudioNode = instantiate(effect: "dclp")
    
    // MARK: - Parameters

    /// Specification for the cutoff frequency
    public static let cutoffFrequencyDef = NodeParameterDef(
        identifier: "cutoffFrequency",
        name: "Cutoff Frequency (Hz)",
        address: akGetParameterAddress("DiodeClipperParameterCutoff"),
        defaultValue: 10_000.0,
        range: 12.0 ... 20_000.0,
        unit: .hertz)

    /// Filter cutoff frequency.
    @Parameter(cutoffFrequencyDef) public var cutoffFrequency: AUValue

    /// Specification for the gain
    public static let gainDef = NodeParameterDef(
        identifier: "gain",
        name: "Gain",
        address: akGetParameterAddress("DiodeClipperParameterGaindB"),
        defaultValue: 20.0,
        range: 0.0 ... 40.0,
        unit: .decibels)

    /// Determines the amount of gain applied to the signal before waveshaping. A value of 1 gives slight distortion.
    @Parameter(gainDef) public var gain: AUValue
    
    // MARK: - Initialization

    /// Initialize this clipper node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - cutoffFrequency: Cutoff frequency
    ///   - gain: Gain in dB
    ///
    public init(_ input: Node,
                cutoffFrequency: AUValue = cutoffFrequencyDef.defaultValue,
                gain: AUValue = gainDef.defaultValue
    ) {
        self.input = input
        
        setupParameters()
        
        self.cutoffFrequency = cutoffFrequency
        self.gain = gain
    }
}
