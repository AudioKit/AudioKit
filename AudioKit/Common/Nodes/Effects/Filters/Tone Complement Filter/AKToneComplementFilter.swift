// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// A complement to the AKLowPassFilter.
///
open class AKToneComplementFilter: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKToneComplementFilterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "aton")

    // MARK: - Properties
    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Half Power Point
    public static let halfPowerPointRange: ClosedRange<Double> = 12.0 ... 20_000.0

    /// Initial value for Half Power Point
    public static let defaultHalfPowerPoint: Double = 1_000.0

    /// Half-Power Point in Hertz. Half power is defined as peak power / square root of 2.
    open var halfPowerPoint: Double = defaultHalfPowerPoint {
        willSet {
            let clampedValue = AKToneComplementFilter.halfPowerPointRange.clamp(newValue)
            guard halfPowerPoint != clampedValue else { return }
            internalAU?.halfPowerPoint.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - halfPowerPoint: Half-Power Point in Hertz. Half power is defined as peak power / square root of 2.
    ///
    public init(
        _ input: AKNode? = nil,
        halfPowerPoint: Double = defaultHalfPowerPoint
        ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)

            self.halfPowerPoint = halfPowerPoint
        }
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
