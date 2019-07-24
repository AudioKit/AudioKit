//
//  AKHighPassButterworthFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// These filters are Butterworth second-order IIR filters. They offer an almost
/// flat passband and very good precision and stopband attenuation.
///
open class AKHighPassButterworthFilter: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKHighPassButterworthFilterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "bthp")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    fileprivate var cutoffFrequencyParameter: AUParameter?

    /// Lower and upper bounds for Cutoff Frequency
    public static let cutoffFrequencyRange = 12.0 ... 20_000.0

    /// Initial value for Cutoff Frequency
    public static let defaultCutoffFrequency = 500.0

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Cutoff frequency. (in Hertz)
    @objc open dynamic var cutoffFrequency: Double = defaultCutoffFrequency {
        willSet {
            guard cutoffFrequency != newValue else { return }
            if internalAU?.isSetUp == true {
                cutoffFrequencyParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.cutoffFrequency, value: newValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - cutoffFrequency: Cutoff frequency. (in Hertz)
    ///
    @objc public init(
        _ input: AKNode? = nil,
        cutoffFrequency: Double = defaultCutoffFrequency
        ) {

        self.cutoffFrequency = cutoffFrequency

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

        cutoffFrequencyParameter = tree["cutoffFrequency"]

        internalAU?.setParameterImmediately(.cutoffFrequency, value: cutoffFrequency)
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
