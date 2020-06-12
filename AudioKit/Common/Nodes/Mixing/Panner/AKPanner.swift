// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Stereo Panner
///
open class AKPanner: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "pan2")

    public typealias AKAudioUnitType = AKPannerAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Pan
    public static let panRange: ClosedRange<AUValue> = -1 ... 1

    /// Initial value for Pan
    public static let defaultPan: AUValue = 0

    /// Panning. A value of -1 is hard left, and a value of 1 is hard right, and 0 is center.
    public let pan = AKNodeParameter(identifier: "pan")

    // MARK: - Initialization

    /// Initialize this panner node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - pan: Panning. A value of -1 is hard left, and a value of 1 is hard right, and 0 is center.
    ///
    public init(
        _ input: AKNode? = nil,
        pan: AUValue = defaultPan
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.pan.associate(with: self.internalAU, value: pan)

            input?.connect(to: self)
        }
    }
}
