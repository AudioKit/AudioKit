// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Faust-based pitch shfiter
///
open class AKPitchShifter: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "pshf")

    public typealias AKAudioUnitType = AKPitchShifterAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Shift
    public static let shiftRange: ClosedRange<AUValue> = -24.0 ... 24.0

    /// Lower and upper bounds for Window Size
    public static let windowSizeRange: ClosedRange<AUValue> = 0.0 ... 10_000.0

    /// Lower and upper bounds for Crossfade
    public static let crossfadeRange: ClosedRange<AUValue> = 0.0 ... 10_000.0

    /// Initial value for Shift
    public static let defaultShift: AUValue = 0

    /// Initial value for Window Size
    public static let defaultWindowSize: AUValue = 1_024

    /// Initial value for Crossfade
    public static let defaultCrossfade: AUValue = 512

    /// Pitch shift (in semitones)
    public let shift = AKNodeParameter(identifier: "shift")

    /// Window size (in samples)
    public let windowSize = AKNodeParameter(identifier: "windowSize")

    /// Crossfade (in samples)
    public let crossfade = AKNodeParameter(identifier: "crossfade")

    // MARK: - Initialization

    /// Initialize this pitchshifter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - shift: Pitch shift (in semitones)
    ///   - windowSize: Window size (in samples)
    ///   - crossfade: Crossfade (in samples)
    ///
    public init(
        _ input: AKNode? = nil,
        shift: AUValue = defaultShift,
        windowSize: AUValue = defaultWindowSize,
        crossfade: AUValue = defaultCrossfade
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.shift.associate(with: self.internalAU, value: shift)
            self.windowSize.associate(with: self.internalAU, value: windowSize)
            self.crossfade.associate(with: self.internalAU, value: crossfade)

            input?.connect(to: self)
        }
    }
}
