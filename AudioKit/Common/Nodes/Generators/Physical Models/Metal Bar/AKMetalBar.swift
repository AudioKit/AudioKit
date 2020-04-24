//
//  AKMetalBar.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

/// 
///
open class AKMetalBar: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKMetalBarAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "mbar")

    // MARK: - Properties

    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Left Boundary Condition
    public static let leftBoundaryConditionRange: ClosedRange<Double> = 1 ... 3

    /// Lower and upper bounds for Right Boundary Condition
    public static let rightBoundaryConditionRange: ClosedRange<Double> = 1 ... 3

    /// Lower and upper bounds for Decay Duration
    public static let decayDurationRange: ClosedRange<Double> = 0 ... 10

    /// Lower and upper bounds for Scan Speed
    public static let scanSpeedRange: ClosedRange<Double> = 0 ... 100

    /// Lower and upper bounds for Position
    public static let positionRange: ClosedRange<Double> = 0 ... 1

    /// Lower and upper bounds for Strike Velocity
    public static let strikeVelocityRange: ClosedRange<Double> = 0 ... 1000

    /// Lower and upper bounds for Strike Width
    public static let strikeWidthRange: ClosedRange<Double> = 0 ... 1

    /// Initial value for Left Boundary Condition
    public static let defaultLeftBoundaryCondition: Double = 1

    /// Initial value for Right Boundary Condition
    public static let defaultRightBoundaryCondition: Double = 1

    /// Initial value for Decay Duration
    public static let defaultDecayDuration: Double = 3

    /// Initial value for Scan Speed
    public static let defaultScanSpeed: Double = 0.25

    /// Initial value for Position
    public static let defaultPosition: Double = 0.2

    /// Initial value for Strike Velocity
    public static let defaultStrikeVelocity: Double = 500

    /// Initial value for Strike Width
    public static let defaultStrikeWidth: Double = 0.05

    /// Initial value for Stiffness
    public static let defaultStiffness: Double = 3

    /// Initial value for High Frequency Damping
    public static let defaultHighFrequencyDamping: Double = 0.001

    /// Boundary condition at left end of bar. 1 = clamped, 2 = pivoting, 3 = free
    open var leftBoundaryCondition: Double = defaultLeftBoundaryCondition {
        willSet {
            let clampedValue = AKMetalBar.leftBoundaryConditionRange.clamp(newValue)
            guard leftBoundaryCondition != clampedValue else { return }
            internalAU?.leftBoundaryCondition.value = AUValue(clampedValue)
        }
    }

    /// Boundary condition at right end of bar. 1 = clamped, 2 = pivoting, 3 = free
    open var rightBoundaryCondition: Double = defaultRightBoundaryCondition {
        willSet {
            let clampedValue = AKMetalBar.rightBoundaryConditionRange.clamp(newValue)
            guard rightBoundaryCondition != clampedValue else { return }
            internalAU?.rightBoundaryCondition.value = AUValue(clampedValue)
        }
    }

    /// 30db decay time (in seconds).
    open var decayDuration: Double = defaultDecayDuration {
        willSet {
            let clampedValue = AKMetalBar.decayDurationRange.clamp(newValue)
            guard decayDuration != clampedValue else { return }
            internalAU?.decayDuration.value = AUValue(clampedValue)
        }
    }

    /// Speed of scanning the output location.
    open var scanSpeed: Double = defaultScanSpeed {
        willSet {
            let clampedValue = AKMetalBar.scanSpeedRange.clamp(newValue)
            guard scanSpeed != clampedValue else { return }
            internalAU?.scanSpeed.value = AUValue(clampedValue)
        }
    }

    /// Position along bar that strike occurs.
    open var position: Double = defaultPosition {
        willSet {
            let clampedValue = AKMetalBar.positionRange.clamp(newValue)
            guard position != clampedValue else { return }
            internalAU?.position.value = AUValue(clampedValue)
        }
    }

    /// Normalized strike velocity
    open var strikeVelocity: Double = defaultStrikeVelocity {
        willSet {
            let clampedValue = AKMetalBar.strikeVelocityRange.clamp(newValue)
            guard strikeVelocity != clampedValue else { return }
            internalAU?.strikeVelocity.value = AUValue(clampedValue)
        }
    }

    /// Spatial width of strike.
    open var strikeWidth: Double = defaultStrikeWidth {
        willSet {
            let clampedValue = AKMetalBar.strikeWidthRange.clamp(newValue)
            guard strikeWidth != clampedValue else { return }
            internalAU?.strikeWidth.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU?.isStarted ?? false
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
        leftBoundaryCondition: Double = defaultLeftBoundaryCondition,
        rightBoundaryCondition: Double = defaultRightBoundaryCondition,
        decayDuration: Double = defaultDecayDuration,
        scanSpeed: Double = defaultScanSpeed,
        position: Double = defaultPosition,
        strikeVelocity: Double = defaultStrikeVelocity,
        strikeWidth: Double = defaultStrikeWidth,
        stiffness: Double = defaultStiffness,
        highFrequencyDamping: Double = defaultHighFrequencyDamping
    ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            self.leftBoundaryCondition = leftBoundaryCondition
            self.rightBoundaryCondition = rightBoundaryCondition
            self.decayDuration = decayDuration
            self.scanSpeed = scanSpeed
            self.position = position
            self.strikeVelocity = strikeVelocity
            self.strikeWidth = strikeWidth
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
