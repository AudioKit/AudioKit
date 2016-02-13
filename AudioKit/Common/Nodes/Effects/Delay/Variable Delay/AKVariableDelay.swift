//
//  AKVariableDelay.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// A delay line with cubic interpolation.
///
/// - parameter input: Input node to process
/// - parameter time: Delay time (in seconds) that can be changed during performance. This value must not exceed the maximum delay time.
///
public class AKVariableDelay: AKNode, AKToggleable {

    // MARK: - Properties


    internal var internalAU: AKVariableDelayAudioUnit?
    internal var token: AUParameterObserverToken?

    private var timeParameter: AUParameter?

    /// Delay time (in seconds) that can be changed during performance. This value must not exceed the maximum delay time.
    public var time: Double = 1 {
        willSet(newValue) {
            if time != newValue {
                timeParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this delay node
    ///
    /// - parameter input: Input node to process
    /// - parameter time: Delay time (in seconds) that can be changed during performance. This value must not exceed the maximum delay time.
    /// - parameter maximumDelayTime: The maximum delay time, in seconds.
    ///
    public init(
        _ input: AKNode,
        time: Double = 1,
        maximumDelayTime: Double = 5) {

        self.time = time

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x76646c61 /*'vdla'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKVariableDelayAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKVariableDelay",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKVariableDelayAudioUnit

            AudioKit.engine.attachNode(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        timeParameter             = tree.valueForKey("time")             as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.timeParameter!.address {
                    self.time = Double(value)
                }
            }
        }
        timeParameter?.setValue(Float(time), originator: token!)
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
