// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Transient shaper
public class TransientShaper: Node {

    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Underlying AVAudioNode
    public var avAudioNode = instantiate(effect: "trsh")

    // MARK: - Parameters

    /// Specification details for input amount
    public static let inputAmountDef = NodeParameterDef(
        identifier: "inputAmount",
        name: "Input",
        address: akGetParameterAddress("TransientShaperParameterInputAmount"),
        defaultValue: 0.0,
        range: -60.0 ... 30.0,
        unit: .decibels)

    /// Input Amount
    @Parameter(inputAmountDef) public var inputAmount: AUValue

    /// Specification details for attack amount
    public static let attackAmountDef = NodeParameterDef(
        identifier: "attackAmount",
        name: "Attack",
        address: akGetParameterAddress("TransientShaperParameterAttackAmount"),
        defaultValue: 0.0,
        range: -40.0 ... 40.0,
        unit: .decibels)

    /// Attack Amount
    @Parameter(attackAmountDef) public var attackAmount: AUValue

    /// Specification details for release amount
    public static let releaseAmountDef = NodeParameterDef(
        identifier: "releaseAmount",
        name: "Release",
        address: akGetParameterAddress("TransientShaperParameterReleaseAmount"),
        defaultValue: 0.0,
        range: -40.0 ... 40.0,
        unit: .decibels)

    /// Release Amount
    @Parameter(releaseAmountDef) public var releaseAmount: AUValue

    /// Specification details for output amount
    public static let outputAmountDef = NodeParameterDef(
        identifier: "outputAmount",
        name: "Output",
        address: akGetParameterAddress("TransientShaperParameterOutputAmount"),
        defaultValue: 0.0,
        range: -60.0 ... 30.0,
        unit: .decibels)

    /// Output Amount
    @Parameter(outputAmountDef) public var outputAmount: AUValue

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
        inputAmount: AUValue = inputAmountDef.defaultValue,
        attackAmount: AUValue = attackAmountDef.defaultValue,
        releaseAmount: AUValue = releaseAmountDef.defaultValue,
        outputAmount: AUValue = outputAmountDef.defaultValue
    ) {
        self.input = input
       
        setupParameters()
        
        self.inputAmount = inputAmount
        self.attackAmount = attackAmount
        self.releaseAmount = releaseAmount
        self.outputAmount = outputAmount
    }
    
}
