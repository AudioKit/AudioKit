//
//  AKMetalBar.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

///
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
open class AKMetalBar: AKNode {

    // MARK: - Properties

    internal var internalAU: AKMetalBarAudioUnit?
    internal var token: AUParameterObserverToken?


    fileprivate var leftBoundaryConditionParameter: AUParameter?
    fileprivate var rightBoundaryConditionParameter: AUParameter?
    fileprivate var decayDurationParameter: AUParameter?
    fileprivate var scanSpeedParameter: AUParameter?
    fileprivate var positionParameter: AUParameter?
    fileprivate var strikeVelocityParameter: AUParameter?
    fileprivate var strikeWidthParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open var rampTime: Double = AKSettings.rampTime {
        willSet {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// Boundary condition at left end of bar. 1 = clamped, 2 = pivoting, 3 = free
    open var leftBoundaryCondition: Double = 1 {
        willSet {
            if leftBoundaryCondition != newValue {
                leftBoundaryConditionParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Boundary condition at right end of bar. 1 = clamped, 2 = pivoting, 3 = free
    open var rightBoundaryCondition: Double = 1 {
        willSet {
            if rightBoundaryCondition != newValue {
                rightBoundaryConditionParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// 30db decay time (in seconds).
    open var decayDuration: Double = 3 {
        willSet {
            if decayDuration != newValue {
                decayDurationParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Speed of scanning the output location.
    open var scanSpeed: Double = 0.25 {
        willSet {
            if scanSpeed != newValue {
                scanSpeedParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Position along bar that strike occurs.
    open var position: Double = 0.2 {
        willSet {
            if position != newValue {
                positionParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Normalized strike velocity
    open var strikeVelocity: Double = 500 {
        willSet {
            if strikeVelocity != newValue {
                strikeVelocityParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Spatial width of strike.
    open var strikeWidth: Double = 0.05 {
        willSet {
            if strikeWidth != newValue {
                strikeWidthParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU!.isPlaying()
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

        let description = AudioComponentDescription(generator: "mbar")

        AUAudioUnit.registerSubclass(
            AKMetalBarAudioUnit.self,
            as: description,
            name: "Local AKMetalBar",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiate(with: description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitGenerator = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitGenerator
            self.internalAU = avAudioUnitGenerator.auAudioUnit as? AKMetalBarAudioUnit

            AudioKit.engine.attach(self.avAudioNode)
        }

        guard let tree = internalAU?.parameterTree else { return }

        leftBoundaryConditionParameter  = tree["leftBoundaryCondition"]
        rightBoundaryConditionParameter = tree["rightBoundaryCondition"]
        decayDurationParameter          = tree["decayDuration"]
        scanSpeedParameter              = tree["scanSpeed"]
        positionParameter               = tree["position"]
        strikeVelocityParameter         = tree["strikeVelocity"]
        strikeWidthParameter            = tree["strikeWidth"]

        token = tree.token (byAddingParameterObserver: {
            address, value in

            DispatchQueue.main.async {
                if address == self.leftBoundaryConditionParameter!.address {
                    self.leftBoundaryCondition = Double(value)
                } else if address == self.rightBoundaryConditionParameter!.address {
                    self.rightBoundaryCondition = Double(value)
                } else if address == self.decayDurationParameter!.address {
                    self.decayDuration = Double(value)
                } else if address == self.scanSpeedParameter!.address {
                    self.scanSpeed = Double(value)
                } else if address == self.positionParameter!.address {
                    self.position = Double(value)
                } else if address == self.strikeVelocityParameter!.address {
                    self.strikeVelocity = Double(value)
                } else if address == self.strikeWidthParameter!.address {
                    self.strikeWidth = Double(value)
                }
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
        self.internalAU!.start()
        self.internalAU!.trigger()
    }

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        self.internalAU!.stop()
    }
}
