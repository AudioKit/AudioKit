//
//  AKPitchShifter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Faust-based pitch shfiter
///
/// - parameter input: Input node to process
/// - parameter shift: Pitch shift (in semitones)
/// - parameter windowSize: Window size (in samples)
/// - parameter crossfade: Crossfade (in samples)
///
public class AKPitchShifter: AKNode, AKToggleable {

    // MARK: - Properties

    internal var internalAU: AKPitchShifterAudioUnit?
    internal var token: AUParameterObserverToken?

    private var shiftParameter: AUParameter?
    private var windowSizeParameter: AUParameter?
    private var crossfadeParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    public var rampTime: Double = AKSettings.rampTime {
        willSet {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// Pitch shift (in semitones)
    public var shift: Double = 0 {
        willSet {
            if shift != newValue {
                if internalAU!.isSetUp() {
                    shiftParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.shift = Float(newValue)
                }
            }
        }
    }
    /// Window size (in samples)
    public var windowSize: Double = 1024 {
        willSet {
            if windowSize != newValue {
                if internalAU!.isSetUp() {
                    windowSizeParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.windowSize = Float(newValue)
                }
            }
        }
    }
    /// Crossfade (in samples)
    public var crossfade: Double = 512 {
        willSet {
            if crossfade != newValue {
                if internalAU!.isSetUp() {
                    crossfadeParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.crossfade = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this pitchshifter node
    ///
    /// - parameter input: Input node to process
    /// - parameter shift: Pitch shift (in semitones)
    /// - parameter windowSize: Window size (in samples)
    /// - parameter crossfade: Crossfade (in samples)
    ///
    public init(
        _ input: AKNode,
        shift: Double = 0,
        windowSize: Double = 1024,
        crossfade: Double = 512) {

        self.shift = shift
        self.windowSize = windowSize
        self.crossfade = crossfade

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x70736866 /*'pshf'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKPitchShifterAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKPitchShifter",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKPitchShifterAudioUnit

            AudioKit.engine.attachNode(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        shiftParameter      = tree.valueForKey("shift")      as? AUParameter
        windowSizeParameter = tree.valueForKey("windowSize") as? AUParameter
        crossfadeParameter  = tree.valueForKey("crossfade")  as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.shiftParameter!.address {
                    self.shift = Double(value)
                } else if address == self.windowSizeParameter!.address {
                    self.windowSize = Double(value)
                } else if address == self.crossfadeParameter!.address {
                    self.crossfade = Double(value)
                }
            }
        }

        internalAU?.shift = Float(shift)
        internalAU?.windowSize = Float(windowSize)
        internalAU?.crossfade = Float(crossfade)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        self.internalAU!.stop()
    }
}
