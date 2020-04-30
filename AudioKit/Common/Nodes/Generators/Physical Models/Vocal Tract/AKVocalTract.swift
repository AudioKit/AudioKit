// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Based on the Pink Trombone algorithm by Neil Thapen, this implements a
/// physical model of the vocal tract glottal pulse wave. The tract model is
/// based on the classic Kelly-Lochbaum segmented cylindrical 1d waveguide
/// model, and the glottal pulse wave is a LF glottal pulse model.
///
open class AKVocalTract: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKVocalTractAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "vocw")

    // MARK: - Properties

    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Frequency
    public static let frequencyRange: ClosedRange<Double> = 0.0 ... 22050.0

    /// Lower and upper bounds for Tongue Position
    public static let tonguePositionRange: ClosedRange<Double> = 0.0 ... 1.0

    /// Lower and upper bounds for Tongue Diameter
    public static let tongueDiameterRange: ClosedRange<Double> = 0.0 ... 1.0

    /// Lower and upper bounds for Tenseness
    public static let tensenessRange: ClosedRange<Double> = 0.0 ... 1.0

    /// Lower and upper bounds for Nasality
    public static let nasalityRange: ClosedRange<Double> = 0.0 ... 1.0

    /// Initial value for Frequency
    public static let defaultFrequency: Double = 160.0

    /// Initial value for Tongue Position
    public static let defaultTonguePosition: Double = 0.5

    /// Initial value for Tongue Diameter
    public static let defaultTongueDiameter: Double = 1.0

    /// Initial value for Tenseness
    public static let defaultTenseness: Double = 0.6

    /// Initial value for Nasality
    public static let defaultNasality: Double = 0.0

    /// Glottal frequency.
    open var frequency: Double = defaultFrequency {
        willSet {
            let clampedValue = AKVocalTract.frequencyRange.clamp(newValue)
            guard frequency != clampedValue else { return }
            internalAU?.frequency.value = AUValue(clampedValue)
        }
    }

    /// Tongue position (0-1)
    open var tonguePosition: Double = defaultTonguePosition {
        willSet {
            let clampedValue = AKVocalTract.tonguePositionRange.clamp(newValue)
            guard tonguePosition != clampedValue else { return }
            internalAU?.tonguePosition.value = AUValue(clampedValue)
        }
    }

    /// Tongue diameter (0-1)
    open var tongueDiameter: Double = defaultTongueDiameter {
        willSet {
            let clampedValue = AKVocalTract.tongueDiameterRange.clamp(newValue)
            guard tongueDiameter != clampedValue else { return }
            internalAU?.tongueDiameter.value = AUValue(clampedValue)
        }
    }

    /// Vocal tenseness. 0 = all breath. 1=fully saturated.
    open var tenseness: Double = defaultTenseness {
        willSet {
            let clampedValue = AKVocalTract.tensenessRange.clamp(newValue)
            guard tenseness != clampedValue else { return }
            internalAU?.tenseness.value = AUValue(clampedValue)
        }
    }

    /// Sets the velum size. Larger values of this creates more nasally sounds.
    open var nasality: Double = defaultNasality {
        willSet {
            let clampedValue = AKVocalTract.nasalityRange.clamp(newValue)
            guard nasality != clampedValue else { return }
            internalAU?.nasality.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization


    /// Initialize this vocal tract node
    ///
    /// - Parameters:
    ///   - frequency: Glottal frequency.
    ///   - tonguePosition: Tongue position (0-1)
    ///   - tongueDiameter: Tongue diameter (0-1)
    ///   - tenseness: Vocal tenseness. 0 = all breath. 1=fully saturated.
    ///   - nasality: Sets the velum size. Larger values of this creates more nasally sounds.
    ///
    public init(
        frequency: Double = defaultFrequency,
        tonguePosition: Double = defaultTonguePosition,
        tongueDiameter: Double = defaultTongueDiameter,
        tenseness: Double = defaultTenseness,
        nasality: Double = defaultNasality
    ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            self.frequency = frequency
            self.tonguePosition = tonguePosition
            self.tongueDiameter = tongueDiameter
            self.tenseness = tenseness
            self.nasality = nasality
        }
    }

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        internalAU?.stop()
    }
}
