// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Clips a signal to a predefined limit, in a "soft" manner, using one of three
/// methods.
///
open class AKClipper: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKClipperAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "clip")

    // MARK: - Properties
    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Limit
    public static let limitRange: ClosedRange<Double> = 0.0 ... 1.0

    /// Initial value for Limit
    public static let defaultLimit: Double = 1.0

    /// Threshold / limiting value.
    @objc open var limit: Double = defaultLimit {
        willSet {
            let clampedValue = AKClipper.limitRange.clamp(newValue)
            guard limit != clampedValue else { return }
            internalAU?.limit.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize this clipper node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - limit: Threshold / limiting value.
    ///
    public init(
        _ input: AKNode? = nil,
        limit: Double = defaultLimit
        ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)

            self.limit = limit
        }
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        internalAU?.stop()
    }
}
