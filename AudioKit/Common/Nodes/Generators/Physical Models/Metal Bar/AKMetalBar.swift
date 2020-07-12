// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// 
///
open class AKMetalBar: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(generator: "mbar")

    public typealias AKAudioUnitType = AKMetalBarAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Boundary condition at left end of bar. 1 = clamped, 2 = pivoting, 3 = free
    @Parameter public var leftBoundaryCondition: AUValue

    /// Boundary condition at right end of bar. 1 = clamped, 2 = pivoting, 3 = free
    @Parameter public var rightBoundaryCondition: AUValue

    /// 30db decay time (in seconds).
    @Parameter public var decayDuration: AUValue

    /// Speed of scanning the output location.
    @Parameter public var scanSpeed: AUValue

    /// Position along bar that strike occurs.
    @Parameter public var position: AUValue

    /// Normalized strike velocity
    @Parameter public var strikeVelocity: AUValue

    /// Spatial width of strike.
    @Parameter public var strikeWidth: AUValue

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
        leftBoundaryCondition: AUValue = 1,
        rightBoundaryCondition: AUValue = 1,
        decayDuration: AUValue = 3,
        scanSpeed: AUValue = 0.25,
        position: AUValue = 0.2,
        strikeVelocity: AUValue = 500,
        strikeWidth: AUValue = 0.05,
        stiffness: AUValue = 3,
        highFrequencyDamping: AUValue = 0.001
    ) {
        super.init(avAudioNode: AVAudioNode())

        self.leftBoundaryCondition = leftBoundaryCondition
        self.rightBoundaryCondition = rightBoundaryCondition
        self.decayDuration = decayDuration
        self.scanSpeed = scanSpeed
        self.position = position
        self.strikeVelocity = strikeVelocity
        self.strikeWidth = strikeWidth

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)
        }

    }
}
