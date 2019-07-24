//
//  AKBitCrusher.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// This will digitally degrade a signal.
///
open class AKBitCrusher: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKBitCrusherAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "btcr")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    fileprivate var bitDepthParameter: AUParameter?
    fileprivate var sampleRateParameter: AUParameter?

    /// Lower and upper bounds for Bit Depth
    public static let bitDepthRange = 1.0 ... 24.0

    /// Lower and upper bounds for Sample Rate
    public static let sampleRateRange = 0.0 ... 20_000.0

    /// Initial value for Bit Depth
    public static let defaultBitDepth = 8.0

    /// Initial value for Sample Rate
    public static let defaultSampleRate = 10_000.0

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// The bit depth of signal output. Typically in range (1-24). Non-integer values are OK.
    @objc open dynamic var bitDepth: Double = defaultBitDepth {
        willSet {
            guard bitDepth != newValue else { return }
            if internalAU?.isSetUp == true {
                bitDepthParameter?.value = AUValue(newValue)
                return
            }
            internalAU?.setParameterImmediately(.bitDepth, value: newValue)
        }
    }

    /// The sample rate of signal output.
    @objc open dynamic var sampleRate: Double = defaultSampleRate {
        willSet {
            guard sampleRate != newValue else { return }
            if internalAU?.isSetUp == true {
                sampleRateParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.sampleRate, value: newValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    // MARK: - Initialization

    /// Initialize this bitcrusher node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - bitDepth: The bit depth of signal output. Typically in range (1-24). Non-integer values are OK.
    ///   - sampleRate: The sample rate of signal output.
    ///
    @objc public init(
        _ input: AKNode? = nil,
        bitDepth: Double = defaultBitDepth,
        sampleRate: Double = defaultSampleRate
        ) {

        self.bitDepth = bitDepth
        self.sampleRate = sampleRate

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in
            guard let strongSelf = self else {
                AKLog("Error: self is nil")
                return
            }
            strongSelf.avAudioUnit = avAudioUnit
            strongSelf.avAudioNode = avAudioUnit
            strongSelf.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: strongSelf)
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        bitDepthParameter = tree["bitDepth"]
        sampleRateParameter = tree["sampleRate"]

        internalAU?.setParameterImmediately(.bitDepth, value: bitDepth)
        internalAU?.setParameterImmediately(.sampleRate, value: sampleRate)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        internalAU?.stop()
    }
}
