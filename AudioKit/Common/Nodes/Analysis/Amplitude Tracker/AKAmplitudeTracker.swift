//
//  AKAmplitudeTracker.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Performs a "root-mean-square" on a signal to get overall amplitude of a
/// signal. The output signal looks similar to that of a classic VU meter.
///
/// - parameter input: Input node to process
/// - parameter halfPowerPoint: Half-power point (in Hz) of internal lowpass filter.
///
public class AKAmplitudeTracker: AKNode, AKToggleable {


    // MARK: - Properties


    internal var internalAU: AKAmplitudeTrackerAudioUnit?
    internal var token: AUParameterObserverToken?

    private var halfPowerPointParameter: AUParameter?

    /// Half-power point (in Hz) of internal lowpass filter.
    public var halfPowerPoint: Double = 10 {
        willSet {
            if halfPowerPoint != newValue {
                halfPowerPointParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    /// Detected amplitude
    public var amplitude: Double {
        return Double(self.internalAU!.getAmplitude()) / sqrt(2.0) * 2.0
    }

    // MARK: - Initialization

    /// Initialize this amplitude tracker node
    ///
    /// - parameter input: Input node to process
    /// - parameter halfPowerPoint: Half-power point (in Hz) of internal lowpass filter.
    ///
    public init(
        _ input: AKNode,
        halfPowerPoint: Double = 10) {

        self.halfPowerPoint = halfPowerPoint

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x726d7371 /*'rmsq'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKAmplitudeTrackerAudioUnit.self,
            as: description,
            name: "Local AKAmplitudeTracker",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiate(with: description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.auAudioUnit as? AKAmplitudeTrackerAudioUnit

            AudioKit.engine.attach(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        halfPowerPointParameter = tree.value(forKey: "halfPowerPoint") as? AUParameter

        token = tree.token {
            address, value in

            DispatchQueue.main.async {
                if address == self.halfPowerPointParameter!.address {
                    self.halfPowerPoint = Double(value)
                }
            }
        }
        halfPowerPointParameter?.setValue(Float(halfPowerPoint), originator: token!)
    }
    
    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        internalAU!.stop()
    }
}
