// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Faust-based pitch shfiter
///
open class AKPitchShifter: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "pshf")

    public typealias AKAudioUnitType = AKPitchShifterAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Pitch shift (in semitones)
    @Parameter public var shift: AUValue

    /// Window size (in samples)
    @Parameter public var windowSize: AUValue

    /// Crossfade (in samples)
    @Parameter public var crossfade: AUValue

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
        shift: AUValue = 0,
        windowSize: AUValue = 1_024,
        crossfade: AUValue = 512
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.shift = shift
        self.windowSize = windowSize
        self.crossfade = crossfade
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            input?.connect(to: self)
        }
    }
}
