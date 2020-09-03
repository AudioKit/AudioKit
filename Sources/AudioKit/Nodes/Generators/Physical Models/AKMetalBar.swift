// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// 
///
public class AKMetalBar: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(generator: "mbar")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let leftBoundaryConditionDef = AKNodeParameterDef(
        identifier: "leftBoundaryCondition",
        name: "Boundary condition at left end of bar. 1 = clamped, 2 = pivoting, 3 = free",
        address: akGetParameterAddress("AKMetalBarParameterLeftBoundaryCondition"),
        range: 1 ... 3,
        unit: .hertz,
        flags: .default)

    /// Boundary condition at left end of bar. 1 = clamped, 2 = pivoting, 3 = free
    @Parameter public var leftBoundaryCondition: AUValue

    public static let rightBoundaryConditionDef = AKNodeParameterDef(
        identifier: "rightBoundaryCondition",
        name: "Boundary condition at right end of bar. 1 = clamped, 2 = pivoting, 3 = free",
        address: akGetParameterAddress("AKMetalBarParameterRightBoundaryCondition"),
        range: 1 ... 3,
        unit: .hertz,
        flags: .default)

    /// Boundary condition at right end of bar. 1 = clamped, 2 = pivoting, 3 = free
    @Parameter public var rightBoundaryCondition: AUValue

    public static let decayDurationDef = AKNodeParameterDef(
        identifier: "decayDuration",
        name: "30db decay time (in seconds).",
        address: akGetParameterAddress("AKMetalBarParameterDecayDuration"),
        range: 0 ... 10,
        unit: .hertz,
        flags: .default)

    /// 30db decay time (in seconds).
    @Parameter public var decayDuration: AUValue

    public static let scanSpeedDef = AKNodeParameterDef(
        identifier: "scanSpeed",
        name: "Speed of scanning the output location.",
        address: akGetParameterAddress("AKMetalBarParameterScanSpeed"),
        range: 0 ... 100,
        unit: .hertz,
        flags: .default)

    /// Speed of scanning the output location.
    @Parameter public var scanSpeed: AUValue

    public static let positionDef = AKNodeParameterDef(
        identifier: "position",
        name: "Position along bar that strike occurs.",
        address: akGetParameterAddress("AKMetalBarParameterPosition"),
        range: 0 ... 1,
        unit: .generic,
        flags: .default)

    /// Position along bar that strike occurs.
    @Parameter public var position: AUValue

    public static let strikeVelocityDef = AKNodeParameterDef(
        identifier: "strikeVelocity",
        name: "Normalized strike velocity",
        address: akGetParameterAddress("AKMetalBarParameterStrikeVelocity"),
        range: 0 ... 1_000,
        unit: .generic,
        flags: .default)

    /// Normalized strike velocity
    @Parameter public var strikeVelocity: AUValue

    public static let strikeWidthDef = AKNodeParameterDef(
        identifier: "strikeWidth",
        name: "Spatial width of strike.",
        address: akGetParameterAddress("AKMetalBarParameterStrikeWidth"),
        range: 0 ... 1,
        unit: .generic,
        flags: .default)

    /// Spatial width of strike.
    @Parameter public var strikeWidth: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKMetalBar.leftBoundaryConditionDef,
             AKMetalBar.rightBoundaryConditionDef,
             AKMetalBar.decayDurationDef,
             AKMetalBar.scanSpeedDef,
             AKMetalBar.positionDef,
             AKMetalBar.strikeVelocityDef,
             AKMetalBar.strikeWidthDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKMetalBarDSP")
        }
    }

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

    // TODO This node needs to have tests
}
