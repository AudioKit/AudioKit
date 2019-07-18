//
//  AKHighShelfParametricEqualizerFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// This is an implementation of Zoelzer's parametric equalizer filter.
///
open class AKHighShelfParametricEqualizerFilter: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKHighShelfParametricEqualizerFilterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "peq2")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    fileprivate var centerFrequencyParameter: AUParameter?
    fileprivate var gainParameter: AUParameter?
    fileprivate var qParameter: AUParameter?

    /// Lower and upper bounds for Center Frequency
    public static let centerFrequencyRange = 12.0 ... 20_000.0

    /// Lower and upper bounds for Gain
    public static let gainRange = 0.0 ... 10.0

    /// Lower and upper bounds for Q
    public static let qRange = 0.0 ... 2.0

    /// Initial value for Center Frequency
    public static let defaultCenterFrequency = 1_000.0

    /// Initial value for Gain
    public static let defaultGain = 1.0

    /// Initial value for Q
    public static let defaultQ = 0.707

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Corner frequency.
    @objc open dynamic var centerFrequency: Double = defaultCenterFrequency {
        willSet {
            guard centerFrequency != newValue else { return }
            if internalAU?.isSetUp == true {
                centerFrequencyParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.centerFrequency, value: newValue)
        }
    }

    /// Amount at which the corner frequency value shall be increased or decreased. A value of 1 is a flat response.
    @objc open dynamic var gain: Double = defaultGain {
        willSet {
            guard gain != newValue else { return }
            if internalAU?.isSetUp == true {
                gainParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.gain, value: newValue)
        }
    }

    /// Q of the filter. sqrt(0.5) is no resonance.
    @objc open dynamic var q: Double = defaultQ {
        willSet {
            guard q != newValue else { return }
            if internalAU?.isSetUp == true {
                qParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.Q, value: newValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    // MARK: - Initialization

    /// Initialize this equalizer node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - centerFrequency: Corner frequency.
    ///   - gain: Amount at which the corner frequency value shall be increased or decreased. A value of 1 is a flat response.
    ///   - q: Q of the filter. sqrt(0.5) is no resonance.
    ///
    @objc public init(
        _ input: AKNode? = nil,
        centerFrequency: Double = defaultCenterFrequency,
        gain: Double = defaultGain,
        q: Double = defaultQ
        ) {

        self.centerFrequency = centerFrequency
        self.gain = gain
        self.q = q

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

        centerFrequencyParameter = tree["centerFrequency"]
        gainParameter = tree["gain"]
        qParameter = tree["q"]

        internalAU?.setParameterImmediately(.centerFrequency, value: centerFrequency)
        internalAU?.setParameterImmediately(.gain, value: gain)
        internalAU?.setParameterImmediately(.Q, value: q)
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
