//
//  AKClipper.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Clips a signal to a predefined limit, in a "soft" manner, using one of three
/// methods.
///
/// - Parameters:
///   - input: Input node to process
///   - limit: Threshold / limiting value.
///
public class AKClipper: AKNode, AKToggleable {

    // MARK: - Properties

    internal var internalAU: AKClipperAudioUnit?
    internal var token: AUParameterObserverToken?

    private var limitParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    public var rampTime: Double = AKSettings.rampTime {
        willSet {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// Threshold / limiting value.
    public var limit: Double = 1.0 {
        willSet {
            if limit != newValue {
                if internalAU!.isSetUp() {
                    limitParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.limit = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this clipper node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - limit: Threshold / limiting value.
    ///
    public init(
        _ input: AKNode,
        limit: Double = 1.0) {

        self.limit = limit

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x636c6970 /*'clip'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKClipperAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKClipper",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKClipperAudioUnit

            AudioKit.engine.attachNode(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        limitParameter = tree.valueForKey("limit") as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.limitParameter!.address {
                    self.limit = Double(value)
                }
            }
        }

        internalAU?.limit = Float(limit)
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
