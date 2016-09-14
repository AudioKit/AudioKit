//
//  AKPluckedString.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Karplus-Strong plucked string instrument.
///
/// - Parameters:
///   - frequency: Variable frequency. Values less than the initial frequency will be doubled until it is greater than that.
///   - amplitude: Amplitude
///   - lowestFrequency: This frequency is used to allocate all the buffers needed for the delay. This should be the lowest frequency you plan on using.
///
public class AKPluckedString: AKNode, AKToggleable {

    // MARK: - Properties

    internal var internalAU: AKPluckedStringAudioUnit?
    internal var token: AUParameterObserverToken?


    private var frequencyParameter: AUParameter?
    private var amplitudeParameter: AUParameter?
    private var lowestFrequency: Double

    /// Ramp Time represents the speed at which parameters are allowed to change
    public var rampTime: Double = AKSettings.rampTime {
        willSet {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// Variable frequency. Values less than the initial frequency will be doubled until it is greater than that.
    public var frequency: Double = 110 {
        willSet {
            if frequency != newValue {
                frequencyParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Amplitude
    public var amplitude: Double = 0.5 {
        willSet {
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

    /// Initialize the pluck with defaults
    override convenience init() {
        self.init(frequency: 110)
    }

    /// Initialize this pluck node
    ///
    /// - Parameters:
    ///   - frequency: Variable frequency. Values less than the initial frequency will be doubled until it is greater than that.
    ///   - amplitude: Amplitude
    ///   - lowestFrequency: This frequency is used to allocate all the buffers needed for the delay. This should be the lowest frequency you plan on using.
    ///
    public init(
        frequency: Double = 440,
        amplitude: Double = 0.5,
        lowestFrequency: Double = 110) {


        self.frequency = frequency
        self.amplitude = amplitude
        self.lowestFrequency = lowestFrequency

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Generator
        description.componentSubType      = 0x706c756b /*'pluk'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKPluckedStringAudioUnit.self,
            as: description,
            name: "Local AKPluckedString",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiate(with: description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitGenerator = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitGenerator
            self.internalAU = avAudioUnitGenerator.auAudioUnit as? AKPluckedStringAudioUnit

            AudioKit.engine.attach(self.avAudioNode)
        }

        guard let tree = internalAU?.parameterTree else { return }

        frequencyParameter       = tree.value(forKey: "frequency")       as? AUParameter
        amplitudeParameter       = tree.value(forKey: "amplitude")       as? AUParameter

        token = tree.token(byAddingParameterObserver: {
            address, value in

            DispatchQueue.main.async {
                if address == self.frequencyParameter!.address {
                    self.frequency = Double(value)
                } else if address == self.amplitudeParameter!.address {
                    self.amplitude = Double(value)
                }
            }
        })
        internalAU?.frequency = Float(frequency)
        internalAU?.amplitude = Float(amplitude)
    }

    /// Trigger the sound with an optional set of parameters
    ///   - frequency: Frequency in Hz
    /// - amplitude amplitude: Volume
    ///
    public func trigger(frequency: Double, amplitude: Double = 1) {
        self.frequency = frequency
        self.amplitude = amplitude
        self.internalAU!.start()
        self.internalAU!.triggerFrequency(Float(frequency), amplitude: Float(amplitude))
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
