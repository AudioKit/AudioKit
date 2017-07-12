//
//  AKTremolo.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Table-lookup tremolo with linear interpolation
///
open class AKTremolo: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKTremoloAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "trem")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var waveform: AKTable?
    fileprivate var frequencyParameter: AUParameter?
    fileprivate var depthParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Frequency (Hz)
    open dynamic var frequency: Double = 10 {
        willSet {
            if frequency != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        frequencyParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.frequency = Float(newValue)
                }
            }
        }
    }

    /// Depth
    open dynamic var depth: Double = 1 {
        willSet {
            if depth != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        depthParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.depth = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
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
        _ input: AKNode?,
        frequency: Double = 10,
        depth: Double = 1.0,
        waveform: AKTable = AKTable(.positiveSine)) {

        self.waveform = waveform
        self.frequency = frequency

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input?.addConnectionPoint(self!)
            self?.internalAU?.setupWaveform(Int32(waveform.count))
            for (i, sample) in waveform.enumerated() {
                self?.internalAU?.setWaveformValue(sample, at: UInt32(i))
            }
        }

        guard let tree = internalAU?.parameterTree else {
            return
        }

        frequencyParameter = tree["frequency"]

        token = tree.token(byAddingParameterObserver: { [weak self] address, value in

            guard let _ = self else { return } // Replace _ with strongSelf if needed
            DispatchQueue.main.async {
                // This node does not change its own values so we won't add any
                // value observing, but if you need to, this is where that goes.
            }
        })
        internalAU?.frequency = Float(frequency)

        depthParameter = tree["depth"]

        token = tree.token (byAddingParameterObserver: { [weak self] address, value in

            DispatchQueue.main.async {
                if address == self?.depthParameter?.address {
                    self?.depth = Double(value)
                }
            }
        })
        internalAU?.depth = Float(depth)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open dynamic func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        internalAU?.stop()
    }
}
