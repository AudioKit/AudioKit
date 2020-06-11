// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// An automatic wah effect, ported from Guitarix via Faust.
///
open class AKAutoWah: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "awah")

    public typealias AKAudioUnitType = AKAutoWahAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Wah
    public static let wahRange: ClosedRange<AUValue> = 0.0 ... 1.0

    /// Lower and upper bounds for Mix
    public static let mixRange: ClosedRange<AUValue> = 0.0 ... 1.0

    /// Lower and upper bounds for Amplitude
    public static let amplitudeRange: ClosedRange<AUValue> = 0.0 ... 1.0

    /// Initial value for Wah
    public static let defaultWah: AUValue = 0.0

    /// Initial value for Mix
    public static let defaultMix: AUValue = 1.0

    /// Initial value for Amplitude
    public static let defaultAmplitude: AUValue = 0.1

    /// Wah Amount
    public let wah = AKNodeParameter(identifier: "wah")

    /// Dry/Wet Mix
    public let mix = AKNodeParameter(identifier: "mix")

    /// Overall level
    public let amplitude = AKNodeParameter(identifier: "amplitude")

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
        wah: AUValue = defaultWah,
        mix: AUValue = defaultMix,
        amplitude: AUValue = defaultAmplitude
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.wah.associate(with: self.internalAU, value: wah)
            self.mix.associate(with: self.internalAU, value: mix)
            self.amplitude.associate(with: self.internalAU, value: amplitude)

            input?.connect(to: self)
        }
    }
}
