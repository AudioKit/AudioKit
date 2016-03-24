//
//  AKAutoWah.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// An automatic wah effect, ported from Guitarix via Faust.
///
/// - parameter input: Input node to process
/// - parameter wah: Wah Amount
/// - parameter mix: Dry/Wet Mix
/// - parameter amplitude: Overall level
///
public class AKAutoWah: AKNode, AKToggleable {

    // MARK: - Properties


    internal var internalAU: AKAutoWahAudioUnit?
    internal var token: AUParameterObserverToken?

    private var wahParameter: AUParameter?
    private var mixParameter: AUParameter?
    private var amplitudeParameter: AUParameter?

    /// Wah Amount
    public var wah: Double = 0 {
        willSet(newValue) {
            if wah != newValue {
                wahParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }
    /// Dry/Wet Mix
    public var mix: Double = 1 {
        willSet(newValue) {
            if mix != newValue {
                mixParameter?.setValue(Float(newValue * 100.0), originator: token!)
            }
        }
    }
    /// Overall level
    public var amplitude: Double = 0.1 {
        willSet(newValue) {
            if amplitude != newValue {
                amplitudeParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this Auto-Wah node
    ///
    /// - parameter input: Input node to process
    /// - parameter wah: Wah Amount
    /// - parameter mix: Dry/Wet Mix
    /// - parameter amplitude: Overall level
    ///
    public init(
        _ input: AKNode,
        wah: Double = 0,
        mix: Double = 1,
        amplitude: Double = 0.1) {

        self.wah = wah
        self.mix = mix
        self.amplitude = amplitude

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x61776168 /*'awah'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKAutoWahAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKAutoWah",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKAutoWahAudioUnit

            AudioKit.engine.attachNode(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        wahParameter       = tree.valueForKey("wah")       as? AUParameter
        mixParameter       = tree.valueForKey("mix")       as? AUParameter
        amplitudeParameter = tree.valueForKey("amplitude") as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.wahParameter!.address {
                    self.wah = Double(value)
                } else if address == self.mixParameter!.address {
                    self.mix = Double(value)
                } else if address == self.amplitudeParameter!.address {
                    self.amplitude = Double(value)
                }
            }
        }
        wahParameter?.setValue(Float(wah), originator: token!)
        mixParameter?.setValue(Float(mix * 100.0), originator: token!)
        amplitudeParameter?.setValue(Float(amplitude), originator: token!)
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
