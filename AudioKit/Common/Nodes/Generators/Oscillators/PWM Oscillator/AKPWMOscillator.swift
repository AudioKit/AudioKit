// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Casio-style phase distortion with "pivot point" on the X axis This module is
/// designed to emulate the classic phase distortion synthesis technique. From
/// the mid 90's. The technique reads the first and second halves of the ftbl at
/// different rates in order to warp the waveform. For example, pdhalf can
/// smoothly transition a sinewave into something approximating a sawtooth wave.
///
open class AKPWMOscillator: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(generator: "pwmo")

    public typealias AKAudioUnitType = AKPWMOscillatorAudioUnit

    public private(set) var internalAU: AKAudioUnitType?
    public var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Frequency in cycles per second
    @Parameter public var frequency: AUValue

    /// Output Amplitude.
    @Parameter public var amplitude: AUValue

    /// Duty Cycle Width 0 - 1
    @Parameter public var pulseWidth: AUValue

    /// Frequency offset in Hz.
    @Parameter public var detuningOffset: AUValue

    /// Frequency detuning multiplier
    @Parameter public var detuningMultiplier: AUValue

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
        amplitude: AUValue = 1,
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
