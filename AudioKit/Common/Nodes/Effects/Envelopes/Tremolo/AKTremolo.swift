//
//  AKTremolo.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Table-lookup tremolo with linear interpolation
///
/// - parameter input: Input node to process
/// - parameter frequency: Frequency (Hz)
///
public class AKTremolo: AKNode, AKToggleable {

    // MARK: - Properties

    internal var internalAU: AKTremoloAudioUnit?
    internal var token: AUParameterObserverToken?

    private var waveform: AKTable?
    private var frequencyParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    public var rampTime: Double = AKSettings.rampTime {
        willSet {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// Frequency (Hz)
    public var frequency: Double = 10 {
        willSet {
            if frequency != newValue {
                if internalAU!.isSetUp() {
                    frequencyParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.frequency = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this tremolo node
    ///
    /// - parameter input: Input node to process
    /// - parameter frequency: Frequency (Hz)
    /// - parameter waveform:  Shape of the tremolo (default to sine)
    ///
    public init(
        _ input: AKNode,
        frequency: Double = 10,
        waveform: AKTable = AKTable(.PositiveSine)) {

        self.waveform = waveform
        self.frequency = frequency

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x7472656d /*'trem'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKTremoloAudioUnit.self,
            as: description,
            name: "Local AKTremolo",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiate(with: description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.auAudioUnit as? AKTremoloAudioUnit

            AudioKit.engine.attach(self.avAudioNode)
            input.addConnectionPoint(self)
            self.internalAU?.setupWaveform(Int32(waveform.size))
            for i in 0 ..< waveform.size {
                self.internalAU?.setWaveformValue(waveform.values[i], at: UInt32(i))
            }
        }

        guard let tree = internalAU?.parameterTree else { return }

        frequencyParameter = tree.value(forKey: "frequency") as? AUParameter
        
        token = tree.token {
            address, value in

            DispatchQueue.main.async {
                if address == self.frequencyParameter!.address {
                    self.frequency = Double(value)
                }
            }
        }
        internalAU?.frequency = Float(frequency)
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
