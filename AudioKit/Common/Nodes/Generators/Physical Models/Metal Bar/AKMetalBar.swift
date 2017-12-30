//
//  AKMetalBar.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Metal Bar Physical Model
///
open class AKMetalBar: AKNode, AKComponent {
    public typealias AKAudioUnitType = AKMetalBarAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "mbar")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var leftBoundaryConditionParameter: AUParameter?
    fileprivate var rightBoundaryConditionParameter: AUParameter?
    fileprivate var decayDurationParameter: AUParameter?
    fileprivate var scanSpeedParameter: AUParameter?
    fileprivate var positionParameter: AUParameter?
    fileprivate var strikeVelocityParameter: AUParameter?
    fileprivate var strikeWidthParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    @objc open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Boundary condition at left end of bar. 1 = clamped, 2 = pivoting, 3 = free
    @objc open dynamic var leftBoundaryCondition: Double = 1 {
        willSet {
            if leftBoundaryCondition != newValue {
                if let existingToken = token {
                    leftBoundaryConditionParameter?.setValue(Float(newValue), originator: existingToken)
                }
            }
        }
    }

    /// Boundary condition at right end of bar. 1 = clamped, 2 = pivoting, 3 = free
    @objc open dynamic var rightBoundaryCondition: Double = 1 {
        willSet {
            if rightBoundaryCondition != newValue {
                if let existingToken = token {
                    rightBoundaryConditionParameter?.setValue(Float(newValue), originator: existingToken)
                }
            }
        }
    }

    /// 30db decay time (in seconds).
    @objc open dynamic var decayDuration: Double = 3 {
        willSet {
            if decayDuration != newValue {
                if let existingToken = token {
                    decayDurationParameter?.setValue(Float(newValue), originator: existingToken)
                }
            }
        }
    }

    /// Speed of scanning the output location.
    @objc open dynamic var scanSpeed: Double = 0.25 {
        willSet {
            if scanSpeed != newValue {
                if let existingToken = token {
                    scanSpeedParameter?.setValue(Float(newValue), originator: existingToken)
                }
            }
        }
    }

    /// Position along bar that strike occurs.
    @objc open dynamic var position: Double = 0.2 {
        willSet {
            if position != newValue {
                if let existingToken = token {
                    positionParameter?.setValue(Float(newValue), originator: existingToken)
                }
            }
        }
    }

    /// Normalized strike velocity
    @objc open dynamic var strikeVelocity: Double = 500 {
        willSet {
            if strikeVelocity != newValue {
                if let existingToken = token {
                    strikeVelocityParameter?.setValue(Float(newValue), originator: existingToken)
                }
            }
        }
    }

    /// Spatial width of strike.
    @objc open dynamic var strikeWidth: Double = 0.05 {
        willSet {
            if strikeWidth != newValue {
                if let existingToken = token {
                    strikeWidthParameter?.setValue(Float(newValue), originator: existingToken)
                }
            }
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
        leftBoundaryCondition: Double = 1,
        rightBoundaryCondition: Double = 1,
        decayDuration: Double = 3,
        scanSpeed: Double = 0.25,
        position: Double = 0.2,
        strikeVelocity: Double = 500,
        strikeWidth: Double = 0.05,
        stiffness: Double = 3,
        highFrequencyDamping: Double = 0.001) {

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

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
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

        token = tree.token(byAddingParameterObserver: { [weak self] _, _ in

            guard let _ = self else {
                AKLog("Unable to create strong reference to self")
                return
            } // Replace _ with strongSelf if needed
            DispatchQueue.main.async {
                // This node does not change its own values so we won't add any
                // value observing, but if you need to, this is where that goes.
            }
        })
        internalAU?.leftBoundaryCondition = Float(leftBoundaryCondition)
        internalAU?.rightBoundaryCondition = Float(rightBoundaryCondition)
        internalAU?.decayDuration = Float(decayDuration)
        internalAU?.scanSpeed = Float(scanSpeed)
        internalAU?.position = Float(position)
        internalAU?.strikeVelocity = Float(strikeVelocity)
        internalAU?.strikeWidth = Float(strikeWidth)
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
