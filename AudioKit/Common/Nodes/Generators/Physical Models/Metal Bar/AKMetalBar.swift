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
/// - parameter leftBoundaryCondition: Boundary condition at left end of bar. 1 = clamped, 2 = pivoting, 3 = free
/// - parameter rightBoundaryCondition: Boundary condition at right end of bar. 1 = clamped, 2 = pivoting, 3 = free
/// - parameter decayDuration: 30db decay time (in seconds).
/// - parameter scanSpeed: Speed of scanning the output location.
/// - parameter position: Position along bar that strike occurs.
/// - parameter strikeVelocity: Normalized strike velocity
/// - parameter strikeWidth: Spatial width of strike.
/// - parameter stiffness: Dimensionless stiffness parameter
/// - parameter highFrequencyDamping: High-frequency loss parameter. Keep this small
///
public class AKMetalBar: AKNode {

    // MARK: - Properties

    internal var internalAU: AKMetalBarAudioUnit?
    internal var token: AUParameterObserverToken?


    private var leftBoundaryConditionParameter: AUParameter?
    private var rightBoundaryConditionParameter: AUParameter?
    private var decayDurationParameter: AUParameter?
    private var scanSpeedParameter: AUParameter?
    private var positionParameter: AUParameter?
    private var strikeVelocityParameter: AUParameter?
    private var strikeWidthParameter: AUParameter?

   /// Ramp Time represents the speed at which parameters are allowed to change
    public var rampTime: Double = AKSettings.rampTime {
        willSet(newValue) {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// Boundary condition at left end of bar. 1 = clamped, 2 = pivoting, 3 = free
    public var leftBoundaryCondition: Double = 1 {
        willSet(newValue) {
            if leftBoundaryCondition != newValue {
                leftBoundaryConditionParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Boundary condition at right end of bar. 1 = clamped, 2 = pivoting, 3 = free
    public var rightBoundaryCondition: Double = 1 {
        willSet(newValue) {
            if rightBoundaryCondition != newValue {
                rightBoundaryConditionParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// 30db decay time (in seconds).
    public var decayDuration: Double = 3 {
        willSet(newValue) {
            if decayDuration != newValue {
                decayDurationParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Speed of scanning the output location.
    public var scanSpeed: Double = 0.25 {
        willSet(newValue) {
            if scanSpeed != newValue {
                scanSpeedParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Position along bar that strike occurs.
    public var position: Double = 0.2 {
        willSet(newValue) {
            if position != newValue {
                positionParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Normalized strike velocity
    public var strikeVelocity: Double = 500 {
        willSet(newValue) {
            if strikeVelocity != newValue {
                strikeVelocityParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Spatial width of strike.
    public var strikeWidth: Double = 0.05 {
        willSet(newValue) {
            if strikeWidth != newValue {
                strikeWidthParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this Bar node
    ///
    /// - parameter leftBoundaryCondition: Boundary condition at left end of bar. 1 = clamped, 2 = pivoting, 3 = free
    /// - parameter rightBoundaryCondition: Boundary condition at right end of bar. 1 = clamped, 2 = pivoting, 3 = free
    /// - parameter decayDuration: 30db decay time (in seconds).
    /// - parameter scanSpeed: Speed of scanning the output location.
    /// - parameter position: Position along bar that strike occurs.
    /// - parameter strikeVelocity: Normalized strike velocity
    /// - parameter strikeWidth: Spatial width of strike.
    /// - parameter stiffness: Dimensionless stiffness parameter
    /// - parameter highFrequencyDamping: High-frequency loss parameter. Keep this small
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

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Generator
        description.componentSubType      = 0x6d626172 /*'mbar'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKMetalBarAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKMetalBar",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitGenerator = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitGenerator
            self.internalAU = avAudioUnitGenerator.AUAudioUnit as? AKMetalBarAudioUnit

            AudioKit.engine.attachNode(self.avAudioNode)
        }

        guard let tree = internalAU?.parameterTree else { return }

        leftBoundaryConditionParameter  = tree.valueForKey("leftBoundaryCondition")  as? AUParameter
        rightBoundaryConditionParameter = tree.valueForKey("rightBoundaryCondition") as? AUParameter
        decayDurationParameter          = tree.valueForKey("decayDuration")          as? AUParameter
        scanSpeedParameter              = tree.valueForKey("scanSpeed")              as? AUParameter
        positionParameter               = tree.valueForKey("position")               as? AUParameter
        strikeVelocityParameter         = tree.valueForKey("strikeVelocity")         as? AUParameter
        strikeWidthParameter            = tree.valueForKey("strikeWidth")            as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
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
        }
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
    public func trigger() {
        self.internalAU!.start()
        self.internalAU!.trigger()
    }

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        self.internalAU!.stop()
    }
}
