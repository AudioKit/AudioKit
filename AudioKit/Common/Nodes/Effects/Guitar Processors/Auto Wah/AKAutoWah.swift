// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// An automatic wah effect, ported from Guitarix via Faust.
///
open class AKAutoWah: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "awah")

    public typealias AKAudioUnitType = AKAutoWahAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Wah Amount
    @Parameter public var wah: AUValue

    /// Dry/Wet Mix
    @Parameter public var mix: AUValue

    /// Overall level
    @Parameter public var amplitude: AUValue

    // MARK: - Initialization

    /// Initialize this autoWah node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - wah: Wah Amount
    ///   - mix: Dry/Wet Mix
    ///   - amplitude: Overall level
    ///
    public init(
        _ input: AKNode? = nil,
        wah: AUValue = 0.0,
        mix: AUValue = 1.0,
        amplitude: AUValue = 0.1
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.wah = wah
        self.mix = mix
        self.amplitude = amplitude
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            input?.connect(to: self)
        }
    }
}
