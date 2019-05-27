//
//  AKMetalBar.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

///
///
open class AKMetalBar: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKMetalBarAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "mbar")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?

    fileprivate var leftBoundaryConditionParameter: AUParameter?
    fileprivate var rightBoundaryConditionParameter: AUParameter?
    fileprivate var decayDurationParameter: AUParameter?
    fileprivate var scanSpeedParameter: AUParameter?
    fileprivate var positionParameter: AUParameter?
    fileprivate var strikeVelocityParameter: AUParameter?
    fileprivate var strikeWidthParameter: AUParameter?
    fileprivate var stiffnessParameter: AUParameter?
    fileprivate var highFrequencyDampingParameter: AUParameter?

    /// Lower and upper bounds for Left Boundary Condition
    public static let leftBoundaryConditionRange = 1.0 ... 3.0

    /// Lower and upper bounds for Right Boundary Condition
    public static let rightBoundaryConditionRange = 1.0 ... 3.0

    /// Lower and upper bounds for Decay Duration
    public static let decayDurationRange = 0.0 ... 10.0

    /// Lower and upper bounds for Scan Speed
    public static let scanSpeedRange = 0.0 ... 100.0

    /// Lower and upper bounds for Position
    public static let positionRange = 0.0 ... 1.0

    /// Lower and upper bounds for Strike Velocity
    public static let strikeVelocityRange = 0.0 ... 1_000.0

    /// Lower and upper bounds for Strike Width
    public static let strikeWidthRange = 0.0 ... 1.0

    /// Initial value for Left Boundary Condition
    public static let defaultLeftBoundaryCondition = 1.0

    /// Initial value for Right Boundary Condition
    public static let defaultRightBoundaryCondition = 1.0

    /// Initial value for Decay Duration
    public static let defaultDecayDuration = 3.0

    /// Initial value for Scan Speed
    public static let defaultScanSpeed = 0.25

    /// Initial value for Position
    public static let defaultPosition = 0.2

    /// Initial value for Strike Velocity
    public static let defaultStrikeVelocity = 500.0

    /// Initial value for Strike Width
    public static let defaultStrikeWidth = 0.05

    /// Initial value for Stiffness
    public static let defaultStiffness = 3.0

    /// Initial value for High Frequency Damping
    public static let defaultHighFrequencyDamping = 0.001

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Boundary condition at left end of bar. 1 = clamped, 2 = pivoting, 3 = free
    @objc open dynamic var leftBoundaryCondition: Double = defaultLeftBoundaryCondition {
        willSet {
            guard leftBoundaryCondition != newValue else { return }
            if internalAU?.isSetUp == true {
                leftBoundaryConditionParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.leftBoundaryCondition, value: newValue)
        }
    }

    /// Boundary condition at right end of bar. 1 = clamped, 2 = pivoting, 3 = free
    @objc open dynamic var rightBoundaryCondition: Double = defaultRightBoundaryCondition {
        willSet {
            guard rightBoundaryCondition != newValue else { return }
            if internalAU?.isSetUp == true {
                rightBoundaryConditionParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.rightBoundaryCondition, value: newValue)
        }
    }

    /// 30db decay time (in seconds).
    @objc open dynamic var decayDuration: Double = defaultDecayDuration {
        willSet {
            guard decayDuration != newValue else { return }
            if internalAU?.isSetUp == true {
                decayDurationParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.decayDuration, value: newValue)
        }
    }

    /// Speed of scanning the output location.
    @objc open dynamic var scanSpeed: Double = defaultScanSpeed {
        willSet {
            guard scanSpeed != newValue else { return }
            if internalAU?.isSetUp == true {
                scanSpeedParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.scanSpeed, value: newValue)
        }
    }

    /// Position along bar that strike occurs.
    @objc open dynamic var position: Double = defaultPosition {
        willSet {
            guard position != newValue else { return }
            if internalAU?.isSetUp == true {
                positionParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.position, value: newValue)
        }
    }

    /// Normalized strike velocity
    @objc open dynamic var strikeVelocity: Double = defaultStrikeVelocity {
        willSet {
            guard strikeVelocity != newValue else { return }
            if internalAU?.isSetUp == true {
                strikeVelocityParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.strikeVelocity, value: newValue)
        }
    }

    /// Spatial width of strike.
    @objc open dynamic var strikeWidth: Double = defaultStrikeWidth {
        willSet {
            guard strikeWidth != newValue else { return }
            if internalAU?.isSetUp == true {
                strikeWidthParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.strikeWidth, value: newValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
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
    @objc public init(
        leftBoundaryCondition: Double = defaultLeftBoundaryCondition,
        rightBoundaryCondition: Double = defaultRightBoundaryCondition,
        decayDuration: Double = defaultDecayDuration,
        scanSpeed: Double = defaultScanSpeed,
        position: Double = defaultPosition,
        strikeVelocity: Double = defaultStrikeVelocity,
        strikeWidth: Double = defaultStrikeWidth,
        stiffness: Double = defaultStiffness,
        highFrequencyDamping: Double = defaultHighFrequencyDamping) {

        self.leftBoundaryCondition = leftBoundaryCondition
        self.rightBoundaryCondition = rightBoundaryCondition
        self.decayDuration = decayDuration
        self.scanSpeed = scanSpeed
        self.position = position
        self.strikeVelocity = strikeVelocity
        self.strikeWidth = strikeWidth

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in
            guard let strongSelf = self else {
                AKLog("Error: self is nil")
                return
            }
            strongSelf.avAudioUnit = avAudioUnit
            strongSelf.avAudioNode = avAudioUnit
            strongSelf.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        leftBoundaryConditionParameter = tree["leftBoundaryCondition"]
        rightBoundaryConditionParameter = tree["rightBoundaryCondition"]
        decayDurationParameter = tree["decayDuration"]
        scanSpeedParameter = tree["scanSpeed"]
        positionParameter = tree["position"]
        strikeVelocityParameter = tree["strikeVelocity"]
        strikeWidthParameter = tree["strikeWidth"]
        internalAU?.setParameterImmediately(.leftBoundaryCondition, value: leftBoundaryCondition)
        internalAU?.setParameterImmediately(.rightBoundaryCondition, value: rightBoundaryCondition)
        internalAU?.setParameterImmediately(.decayDuration, value: decayDuration)
        internalAU?.setParameterImmediately(.scanSpeed, value: scanSpeed)
        internalAU?.setParameterImmediately(.position, value: position)
        internalAU?.setParameterImmediately(.strikeVelocity, value: strikeVelocity)
        internalAU?.setParameterImmediately(.strikeWidth, value: strikeWidth)
    }

    // MARK: - Control

    /// Trigger the sound with an optional set of parameters
    ///
    open func trigger() {
        internalAU?.start()
        internalAU?.trigger()
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
