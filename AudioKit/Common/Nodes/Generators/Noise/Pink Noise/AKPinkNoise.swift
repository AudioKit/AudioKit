//
//  AKPinkNoise.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Faust-based pink noise generator
///
/// - parameter amplitude: Amplitude. (Value between 0-1).
///
public class AKPinkNoise: AKVoice {

    // MARK: - Properties


    internal var internalAU: AKPinkNoiseAudioUnit?
    internal var token: AUParameterObserverToken?

    private var amplitudeParameter: AUParameter?

    /// Amplitude. (Value between 0-1).
    public var amplitude: Double = 1 {
        didSet {
            internalAU?.amplitude = Float(amplitude)
        }
    }
    
    /// Ramp to amplitude over 20 ms
    ///
    /// - parameter amplitude: Target Output Amplitude.
    ///
    public func ramp(amplitude amplitude: Double) {
        amplitudeParameter?.setValue(Float(amplitude), originator: token!)
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    override public var isStarted: Bool {
        return internalAU!.isPlaying()
    }
    
    // MARK: - Initialization
    
    /// Initialize the noise generator with defaults
    public  convenience override init() {
        self.init(amplitude: 1.0)
    }

    /// Initialize this noise node
    ///
    /// - parameter amplitude: Amplitude. (Value between 0-1).
    ///
    public init(amplitude: Double) {

        self.amplitude = amplitude

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Generator
        description.componentSubType      = 0x70696e6b /*'pink'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKPinkNoiseAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKPinkNoise",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitGenerator = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitGenerator
            self.internalAU = avAudioUnitGenerator.AUAudioUnit as? AKPinkNoiseAudioUnit

            AudioKit.engine.attachNode(self.avAudioNode)
        }

        guard let tree = internalAU?.parameterTree else { return }

        amplitudeParameter = tree.valueForKey("amplitude") as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.amplitudeParameter!.address {
                    self.amplitude = Double(value)
                }
            }
        }
        amplitudeParameter?.setValue(Float(amplitude), originator: token!)
    }

    /// Function create an identical new node for use in creating polyphonic instruments
    public override func duplicate() -> AKVoice {
        let copy = AKPinkNoise(amplitude: self.amplitude)
        return copy
    }

    /// Function to start, play, or activate the node, all do the same thing
    public override func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    public override func stop() {
        self.internalAU!.stop()
    }
}
