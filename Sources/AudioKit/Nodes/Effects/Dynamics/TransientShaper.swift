//
//  TransientShaper.swift
//  AudioKit
//
//  Created by Evan Murray on 1/6/21.
//

import AVFoundation
import CAudioKit

/// Transient shaper
public class TransientShaper: Node, AudioUnitContainer, Toggleable {

    /// Unique four-letter identifier "trsh"
    public static let ComponentDescription = AudioComponentDescription(effect: "trsh")

    /// Internal type of audio unit for this node
    public typealias AudioUnitType = InternalAU

    /// Internal audio unit
    public private(set) var internalAU: AudioUnitType?

    // MARK: - Parameters

    /// Specification details for input amount
    public static let inputAmountDef = NodeParameterDef(
        identifier: "inputAmount",
        name: "Input",
        address: akGetParameterAddress("TransientShaperParameterInputAmount"),
        range: -60.0 ... 30.0,
        unit: .decibels,
        flags: .default)

    /// Input Amount
    @Parameter public var inputAmount: AUValue

    /// Specification details for attack amount
    public static let attackAmountDef = NodeParameterDef(
        identifier: "attackAmount",
        name: "Attack",
        address: akGetParameterAddress("TransientShaperParameterAttackAmount"),
        range: -40.0 ... 40.0,
        unit: .decibels,
        flags: .default)

    /// Attack Amount
    @Parameter public var attackAmount: AUValue

    /// Specification details for release amount
    public static let releaseAmountDef = NodeParameterDef(
        identifier: "releaseAmount",
        name: "Release",
        address: akGetParameterAddress("TransientShaperParameterReleaseAmount"),
        range: -40.0 ... 40.0,
        unit: .decibels,
        flags: .default)

    /// Release Amount
    @Parameter public var releaseAmount: AUValue

    /// Specification details for output amount
    public static let outputAmountDef = NodeParameterDef(
        identifier: "outputAmount",
        name: "Output",
        address: akGetParameterAddress("TransientShaperParameterOutputAmount"),
        range: -60.0 ... 30.0,
        unit: .decibels,
        flags: .default)

    /// Output Amount
    @Parameter public var outputAmount: AUValue

    // MARK: - Audio Unit

    /// Internal audio unit for Transient Shaper
    public class InternalAU: AudioUnitBase {
        /// Get an array of the parameter definitions
        /// - Returns: Array of parameter definitions
        public override func getParameterDefs() -> [NodeParameterDef]? {
            [TransientShaper.inputAmountDef,
             TransientShaper.attackAmountDef,
             TransientShaper.releaseAmountDef,
             TransientShaper.outputAmountDef]
        }

        /// Create the DSP Reference for this node
        /// - Returns: DSP Reference
        public override func createDSP() -> DSPRef {
            akCreateDSP("TransientShaperDSP")
        }
    }

    // MARK: - Initialization

    /// Initialize this delay node
    ///
    /// - Parameters:
    ///     - input: Input node to process
    ///     - attackAmount
    ///     - releaseAmount
    ///     - output
    public init(
        _ input: Node,
        inputAmount: AUValue = 0.0,
        attackAmount: AUValue = 0.0,
        releaseAmount: AUValue = 0.0,
        outputAmount: AUValue = 0.0
    ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AudioUnitType

            self.inputAmount = inputAmount
            self.attackAmount = attackAmount
            self.releaseAmount = releaseAmount
            self.outputAmount = outputAmount
        }

        connections.append(input)
    }

}
