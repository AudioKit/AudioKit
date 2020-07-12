// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Stereo Panner
///
open class AKPanner: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "pan2")

    public typealias AKAudioUnitType = AKPannerAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Panning. A value of -1 is hard left, and a value of 1 is hard right, and 0 is center.
    @Parameter public var pan: AUValue

    // MARK: - Initialization

    /// Initialize this panner node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - pan: Panning. A value of -1 is hard left, and a value of 1 is hard right, and 0 is center.
    ///
    public init(
        _ input: AKNode? = nil,
        pan: AUValue = 0
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.pan = pan
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            input?.connect(to: self)
        }
    }
}
