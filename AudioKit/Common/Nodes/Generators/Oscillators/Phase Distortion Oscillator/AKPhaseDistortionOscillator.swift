// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Casio-style phase distortion with "pivot point" on the X axis This module is
/// designed to emulate the classic phase distortion synthesis technique. From
/// the mid 90's. The technique reads the first and second halves of the ftbl at
/// different rates in order to warp the waveform. For example, pdhalf can
/// smoothly transition a sinewave into something approximating a sawtooth wave.
///
open class AKPhaseDistortionOscillator: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(generator: "pdho")

    public typealias AKAudioUnitType = AKPhaseDistortionOscillatorAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    fileprivate var waveform: AKTable?

    /// Frequency in cycles per second
    @Parameter public var frequency: AUValue

    /// Output Amplitude.
    @Parameter public var amplitude: AUValue

    /// Amount of distortion, within the range [-1, 1]. 0 is no distortion.
    @Parameter public var phaseDistortion: AUValue

    /// Frequency offset in Hz.
    @Parameter public var detuningOffset: AUValue

    /// Frequency detuning multiplier
    @Parameter public var detuningMultiplier: AUValue

    // MARK: - Initialization

    /// Initialize this oscillator node
    ///
    /// - Parameters:
    ///   - waveform: The waveform of oscillation
    ///   - frequency: Frequency in cycles per second
    ///   - amplitude: Output Amplitude.
    ///   - phaseDistortion: Amount of distortion, within the range [-1, 1]. 0 is no distortion.
    ///   - detuningOffset: Frequency offset in Hz.
    ///   - detuningMultiplier: Frequency detuning multiplier
    ///
    public init(
        waveform: AKTable = AKTable(.sine),
        frequency: AUValue = 440,
        amplitude: AUValue = 1,
        phaseDistortion: AUValue = 0,
        detuningOffset: AUValue = 0,
        detuningMultiplier: AUValue = 1
    ) {
        super.init(avAudioNode: AVAudioNode())

        self.waveform = waveform
        self.frequency = frequency
        self.amplitude = amplitude
        self.phaseDistortion = phaseDistortion
        self.detuningOffset = detuningOffset
        self.detuningMultiplier = detuningMultiplier

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.internalAU?.setWavetable(waveform.content)
        }

    }
}
