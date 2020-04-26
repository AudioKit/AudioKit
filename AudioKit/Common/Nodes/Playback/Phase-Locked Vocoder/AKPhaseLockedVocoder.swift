// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// This is a phase locked vocoder. It has the ability to play back an audio
/// file loaded into an ftable like a sampler would. Unlike a typical sampler,
/// mincer allows time and pitch to be controlled separately.
///
open class AKPhaseLockedVocoder: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKPhaseLockedVocoderAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "minc")

    // MARK: - Properties
    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Position
    public static let positionRange: ClosedRange<Double> = 0 ... 1

    /// Lower and upper bounds for Amplitude
    public static let amplitudeRange: ClosedRange<Double> = 0 ... 1

    /// Lower and upper bounds for Pitch Ratio
    public static let pitchRatioRange: ClosedRange<Double> = 0 ... 1000

    /// Initial value for Position
    public static let defaultPosition: Double = 0

    /// Initial value for Amplitude
    public static let defaultAmplitude: Double = 1

    /// Initial value for Pitch Ratio
    public static let defaultPitchRatio: Double = 1

    /// Position in time. When non-changing it will do a spectral freeze of a the current point in time.
    open var position: Double = defaultPosition {
        willSet {
            let clampedValue = AKPhaseLockedVocoder.positionRange.clamp(newValue)
            guard position != clampedValue else { return }
            internalAU?.position.value = AUValue(clampedValue)
        }
    }

    /// Amplitude.
    open var amplitude: Double = defaultAmplitude {
        willSet {
            let clampedValue = AKPhaseLockedVocoder.amplitudeRange.clamp(newValue)
            guard amplitude != clampedValue else { return }
            internalAU?.amplitude.value = AUValue(clampedValue)
        }
    }

    /// Pitch ratio. A value of. 1  normal, 2 is double speed, 0.5 is halfspeed, etc.
    open var pitchRatio: Double = defaultPitchRatio {
        willSet {
            let clampedValue = AKPhaseLockedVocoder.pitchRatioRange.clamp(newValue)
            guard pitchRatio != clampedValue else { return }
            internalAU?.pitchRatio.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize this vocoder node
    ///
    /// - Parameters:
    ///   - position: Position in time. When non-changing it will do a spectral freeze of a the current point in time.
    ///   - amplitude: Amplitude.
    ///   - pitchRatio: Pitch ratio. A value of. 1  normal, 2 is double speed, 0.5 is halfspeed, etc.
    ///
    public init(
        position: Double = defaultPosition,
        amplitude: Double = defaultAmplitude,
        pitchRatio: Double = defaultPitchRatio
        ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            self.position = position
            self.amplitude = amplitude
            self.pitchRatio = pitchRatio
        }
    }

    /// Function create an identical new node for use in creating polyphonic instruments
    public func copy() -> AKPhaseLockedVocoder {
        let copy = AKPhaseLockedVocoder(position: self.position, amplitude: self.amplitude, pitchRatio: self.pitchRatio)
        return copy
    }
    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        internalAU?.stop()
    }
}
