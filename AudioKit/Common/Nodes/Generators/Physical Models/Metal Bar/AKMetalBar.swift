// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// 
///
open class AKMetalBar: AKNode, AKToggleable, AKComponent, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "mbar")

    public typealias AKAudioUnitType = AKMetalBarAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Left Boundary Condition
    public static let leftBoundaryConditionRange: ClosedRange<AUValue> = 1 ... 3

    /// Lower and upper bounds for Right Boundary Condition
    public static let rightBoundaryConditionRange: ClosedRange<AUValue> = 1 ... 3

    /// Lower and upper bounds for Decay Duration
    public static let decayDurationRange: ClosedRange<AUValue> = 0 ... 10

    /// Lower and upper bounds for Scan Speed
    public static let scanSpeedRange: ClosedRange<AUValue> = 0 ... 100

    /// Lower and upper bounds for Position
    public static let positionRange: ClosedRange<AUValue> = 0 ... 1

    /// Lower and upper bounds for Strike Velocity
    public static let strikeVelocityRange: ClosedRange<AUValue> = 0 ... 1_000

    /// Lower and upper bounds for Strike Width
    public static let strikeWidthRange: ClosedRange<AUValue> = 0 ... 1

    /// Initial value for Left Boundary Condition
    public static let defaultLeftBoundaryCondition: AUValue = 1

    /// Initial value for Right Boundary Condition
    public static let defaultRightBoundaryCondition: AUValue = 1

    /// Initial value for Decay Duration
    public static let defaultDecayDuration: AUValue = 3

    /// Initial value for Scan Speed
    public static let defaultScanSpeed: AUValue = 0.25

    /// Initial value for Position
    public static let defaultPosition: AUValue = 0.2

    /// Initial value for Strike Velocity
    public static let defaultStrikeVelocity: AUValue = 500

    /// Initial value for Strike Width
    public static let defaultStrikeWidth: AUValue = 0.05

    /// Initial value for Stiffness
    public static let defaultStiffness: AUValue = 3

    /// Initial value for High Frequency Damping
    public static let defaultHighFrequencyDamping: AUValue = 0.001

    /// Boundary condition at left end of bar. 1 = clamped, 2 = pivoting, 3 = free
    public let leftBoundaryCondition = AKNodeParameter(identifier: "leftBoundaryCondition")

    /// Boundary condition at right end of bar. 1 = clamped, 2 = pivoting, 3 = free
    public let rightBoundaryCondition = AKNodeParameter(identifier: "rightBoundaryCondition")

    /// 30db decay time (in seconds).
    public let decayDuration = AKNodeParameter(identifier: "decayDuration")

    /// Speed of scanning the output location.
    public let scanSpeed = AKNodeParameter(identifier: "scanSpeed")

    /// Position along bar that strike occurs.
    public let position = AKNodeParameter(identifier: "position")

    /// Normalized strike velocity
    public let strikeVelocity = AKNodeParameter(identifier: "strikeVelocity")

    /// Spatial width of strike.
    public let strikeWidth = AKNodeParameter(identifier: "strikeWidth")

    // MARK: - Initialization

    /// Initialize this Bar node
    ///
    /// - Parameters:
    ///   - leftBoundaryCondition: Boundary condition at left end of bar. 1 = clamped, 2 = pivoting, 3 = free
    ///   - rightBoundaryCondition: Boundary condition at right end of bar. 1 = clamped, 2 = pivoting, 3 = free
    ///   - decayDuration: 30db decay time (in seconds).
    ///   - scanSpeed: Speed of scanning the output location.
    ///   - position: Position along bar that strike occurs.
    ///   - strikeVelocity: Normalized strike velocity
    ///   - strikeWidth: Spatial width of strike.
    ///   - stiffness: Dimensionless stiffness parameter
    ///   - highFrequencyDamping: High-frequency loss parameter. Keep this small
    ///
    public init(
        leftBoundaryCondition: AUValue = defaultLeftBoundaryCondition,
        rightBoundaryCondition: AUValue = defaultRightBoundaryCondition,
        decayDuration: AUValue = defaultDecayDuration,
        scanSpeed: AUValue = defaultScanSpeed,
        position: AUValue = defaultPosition,
        strikeVelocity: AUValue = defaultStrikeVelocity,
        strikeWidth: AUValue = defaultStrikeWidth,
        stiffness: AUValue = defaultStiffness,
        highFrequencyDamping: AUValue = defaultHighFrequencyDamping
    ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.leftBoundaryCondition.associate(with: self.internalAU, value: leftBoundaryCondition)
            self.rightBoundaryCondition.associate(with: self.internalAU, value: rightBoundaryCondition)
            self.decayDuration.associate(with: self.internalAU, value: decayDuration)
            self.scanSpeed.associate(with: self.internalAU, value: scanSpeed)
            self.position.associate(with: self.internalAU, value: position)
            self.strikeVelocity.associate(with: self.internalAU, value: strikeVelocity)
            self.strikeWidth.associate(with: self.internalAU, value: strikeWidth)
        }

    }
}
