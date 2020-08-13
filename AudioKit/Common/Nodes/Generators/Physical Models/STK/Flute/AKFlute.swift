// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// STK Flute
///
public class AKFlute: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(generator: "flut")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let frequencyDef = AKNodeParameterDef(
        identifier: "frequency",
        name: "Frequency (Hz)",
        address: akGetParameterAddress("AKFluteParameterFrequency"),
        range: 0.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    /// Variable frequency. Values less than the initial frequency will be doubled until it is greater than that.
    @Parameter public var frequency: AUValue

    public static let amplitudeDef = AKNodeParameterDef(
            identifier: "amplitude",
            name: "Amplitude",
            address: akGetParameterAddress("AKFluteParameterAmplitude"),
            range: 0...10,
            unit: .generic,
            flags: .default)

        /// Amplitude
        @Parameter public var amplitude: AUValue


    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKFlute.frequencyDef,
             AKFlute.amplitudeDef]
        }

        public override func createDSP() -> AKDSPRef {
            return akCreateDSP("AKFluteDSP")
        }
    }


    // MARK: - Initialization

    /// Initialize the STK Flute model
    ///
    /// - Parameters:
    ///   - frequency: Variable frequency. Values less than the initial frequency will be doubled until it is
    ///                greater than that.
    ///   - amplitude: Amplitude
    ///
    public init(frequency: AUValue = 440, amplitude: AUValue = 0.5) {
        super.init(avAudioNode: AVAudioNode())
        self.frequency = frequency
        self.amplitude = amplitude

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            self.parameterAutomation = AKParameterAutomation(avAudioUnit)
        }
    }

    /// Trigger the sound with current parameters
    ///
    public func trigger() {
        internalAU?.start()
        internalAU?.trigger()
    }

    /// Trigger the sound with a set of parameters
    ///
    /// - Parameters:
    ///   - frequency: Frequency in Hz
    ///   - amplitude amplitude: Volume
    ///
    public func trigger(frequency: AUValue, amplitude: AUValue = 1) {
        self.frequency = frequency
        self.amplitude = amplitude
        internalAU?.start()
        internalAU?.triggerFrequency(frequency, amplitude: amplitude)
    }

}
