// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Casio-style phase distortion with "pivot point" on the X axis This module is
/// designed to emulate the classic phase distortion synthesis technique. From
/// the mid 90's. The technique reads the first and second halves of the ftbl at
/// different rates in order to warp the waveform. For example, pdhalf can
/// smoothly transition a sinewave into something approximating a sawtooth wave.
///
public class AKPWMOscillator: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(generator: "pwmo")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    static let frequencyDef = AKNodeParameterDef(
        identifier: "frequency",
        name: "Frequency (Hz)",
        address: AKPWMOscillatorParameter.frequency.rawValue,
        range: 0.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    /// In cycles per second, or Hz.
    @Parameter public var frequency: AUValue

    static let amplitudeDef = AKNodeParameterDef(
        identifier: "amplitude",
        name: "Amplitude",
        address: AKPWMOscillatorParameter.amplitude.rawValue,
        range: 0.0 ... 10.0,
        unit: .hertz,
        flags: .default)

    /// Output amplitude
    @Parameter public var amplitude: AUValue

    static let pulseWidthDef = AKNodeParameterDef(
        identifier: "pulseWidth",
        name: "Pulse Width",
        address: AKPWMOscillatorParameter.pulseWidth.rawValue,
        range: 0.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Duty cycle width (range 0-1).
    @Parameter public var pulseWidth: AUValue

    static let detuningOffsetDef = AKNodeParameterDef(
        identifier: "detuningOffset",
        name: "Frequency offset (Hz)",
        address: AKPWMOscillatorParameter.detuningOffset.rawValue,
        range: -1_000.0 ... 1_000.0,
        unit: .hertz,
        flags: .default)

    /// Frequency offset in Hz.
    @Parameter public var detuningOffset: AUValue

    static let detuningMultiplierDef = AKNodeParameterDef(
        identifier: "detuningMultiplier",
        name: "Frequency detuning multiplier",
        address: AKPWMOscillatorParameter.detuningMultiplier.rawValue,
        range: 0.9 ... 1.11,
        unit: .generic,
        flags: .default)

    /// Frequency detuning multiplier
    @Parameter public var detuningMultiplier: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            return [AKPWMOscillator.frequencyDef,
                    AKPWMOscillator.amplitudeDef,
                    AKPWMOscillator.pulseWidthDef,
                    AKPWMOscillator.detuningOffsetDef,
                    AKPWMOscillator.detuningMultiplierDef]
        }

        public override func createDSP() -> AKDSPRef {
            return createPWMOscillatorDSP()
        }
    }

    // MARK: - Initialization

    /// Initialize this oscillator node
    ///
    /// - Parameters:
    ///   - frequency: In cycles per second, or Hz.
    ///   - amplitude: Output amplitude
    ///   - pulseWidth: Duty cycle width (range 0-1).
    ///   - detuningOffset: Frequency offset in Hz.
    ///   - detuningMultiplier: Frequency detuning multiplier
    ///
    public init(
        frequency: AUValue = 440,
        amplitude: AUValue = 1.0,
        pulseWidth: AUValue = 0.5,
        detuningOffset: AUValue = 0,
        detuningMultiplier: AUValue = 1
    ) {
        super.init(avAudioNode: AVAudioNode())

        self.frequency = frequency
        self.amplitude = amplitude
        self.pulseWidth = pulseWidth
        self.detuningOffset = detuningOffset
        self.detuningMultiplier = detuningMultiplier

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)
        }
    }
}
