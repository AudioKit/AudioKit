//
//  AKTremolo.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Table-lookup tremolo with linear interpolation
///
open class AKTremolo: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKTremoloAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "trem")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var waveform: AKTable?
    fileprivate var frequencyParameter: AUParameter?
    fileprivate var depthParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Frequency (Hz)
    open var frequency: Double = 10 {
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

    /// Depth
    open var depth: Double = 1 {
        willSet {
            if depth != newValue {
                if internalAU!.isSetUp() {
                    depthParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.depth = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this tremolo node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - frequency: Frequency (Hz)
    ///   - depth: Depth
    ///   - waveform:  Shape of the tremolo (default to sine)
    ///
    public init(
        _ input: AKNode,
        frequency: Double = 10,
        depth: Double = 1.0,
        waveform: AKTable = AKTable(.positiveSine)) {

        self.waveform = waveform
        self.frequency = frequency

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) {
            avAudioUnit in

            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input.addConnectionPoint(self)
            self.internalAU?.setupWaveform(Int32(waveform.count))
            for (i, sample) in waveform.enumerated() {
                self.internalAU?.setWaveformValue(sample, at: UInt32(i))
            }
        }

        guard let tree = internalAU?.parameterTree else { return }

        frequencyParameter = tree["frequency"]

        token = tree.token (byAddingParameterObserver: {
            address, value in

            DispatchQueue.main.async {
                if address == self.frequencyParameter!.address {
                    self.frequency = Double(value)
                }
            }
        })
        internalAU?.frequency = Float(frequency)

        depthParameter = tree["depth"]

        token = tree.token (byAddingParameterObserver: {
            address, value in

            DispatchQueue.main.async {
                if address == self.depthParameter!.address {
                    self.depth = Double(value)
                }
            }
        })
        internalAU?.depth = Float(depth)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        self.internalAU!.stop()
    }
}
