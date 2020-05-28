// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Implements the DC blocking filter Y[i] = X[i] - X[i-1] + (igain * Y[i-1]) 
/// Based on work by Perry Cook.
///
open class AKDCBlock: AKNode, AKToggleable, AKComponent, AKInput {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "dcbk")

    public typealias AKAudioUnitType = AKDCBlockAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - Parameters

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///
    public init(
        _ input: AKNode? = nil
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input?.connect(to: self)
        }
    }
}
