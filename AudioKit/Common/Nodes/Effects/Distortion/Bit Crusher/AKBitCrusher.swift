//
//  AKBitCrusher.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// This will digitally degrade a signal.
///
open class AKBitCrusher: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKBitCrusherAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "btcr")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var bitDepthParameter: AUParameter?
    fileprivate var sampleRateParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// The bit depth of signal output. Typically in range (1-24). Non-integer values are OK.
    open dynamic var bitDepth: Double = 8 {
        willSet {
            if bitDepth != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        bitDepthParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.bitDepth = Float(newValue)
                }
            }
        }
    }
    /// The sample rate of signal output.
    open dynamic var sampleRate: Double = 10_000 {
        willSet {
            if sampleRate != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        sampleRateParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.sampleRate = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
    }

    // MARK: - Initialization

    /// Initialize this bitcrusher node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - bitDepth: The bit depth of signal output. Typically in range (1-24). Non-integer values are OK.
    ///   - sampleRate: The sample rate of signal output.
    ///
    public init(
        _ input: AKNode?,
        bitDepth: Double = 8,
        sampleRate: Double = 10_000) {

        self.bitDepth = bitDepth
        self.sampleRate = sampleRate

        _Self.register()

        super.init()

        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input?.addConnectionPoint(self!)
        }

        guard let tree = internalAU?.parameterTree else {
            return
        }

        bitDepthParameter = tree["bitDepth"]
        sampleRateParameter = tree["sampleRate"]

        token = tree.token(byAddingParameterObserver: { [weak self] _, _ in

            guard let _ = self else { return } // Replace _ with strongSelf if needed
            DispatchQueue.main.async {
                // This node does not change its own values so we won't add any
                // value observing, but if you need to, this is where that goes.
            }
        })

        internalAU?.bitDepth = Float(bitDepth)
        internalAU?.sampleRate = Float(sampleRate)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        internalAU?.stop()
    }
}
