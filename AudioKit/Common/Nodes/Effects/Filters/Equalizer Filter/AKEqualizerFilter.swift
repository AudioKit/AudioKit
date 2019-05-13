//
//  AKEqualizerFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// A 2nd order tunable equalization filter that provides a peak/notch filter
/// for building parametric/graphic equalizers. With gain above 1, there will be
/// a peak at the center frequency with a width dependent on bandwidth. If gain
/// is less than 1, a notch is formed around the center frequency.
///
open class AKEqualizerFilter: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKEqualizerFilterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "eqfl")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    fileprivate var centerFrequencyParameter: AUParameter?
    fileprivate var bandwidthParameter: AUParameter?
    fileprivate var gainParameter: AUParameter?

    /// Lower and upper bounds for Center Frequency
    public static let centerFrequencyRange = 12.0 ... 20_000.0

    /// Lower and upper bounds for Bandwidth
    public static let bandwidthRange = 0.0 ... 20_000.0

    /// Lower and upper bounds for Gain
    public static let gainRange = -100.0 ... 100.0

    /// Initial value for Center Frequency
    public static let defaultCenterFrequency = 1_000.0

    /// Initial value for Bandwidth
    public static let defaultBandwidth = 100.0

    /// Initial value for Gain
    public static let defaultGain = 10.0

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Center frequency. (in Hertz)
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

    /// The peak/notch bandwidth in Hertz
    @objc open dynamic var bandwidth: Double = defaultBandwidth {
        willSet {
            guard bandwidth != newValue else { return }
            if internalAU?.isSetUp == true {
                bandwidthParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.bandwidth, value: newValue)
        }
    }

    /// The peak/notch gain
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

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - centerFrequency: Center frequency. (in Hertz)
    ///   - bandwidth: The peak/notch bandwidth in Hertz
    ///   - gain: The peak/notch gain
    ///
    @objc public init(
        _ input: AKNode? = nil,
        centerFrequency: Double = defaultCenterFrequency,
        bandwidth: Double = defaultBandwidth,
        gain: Double = defaultGain
        ) {

        self.centerFrequency = centerFrequency
        self.bandwidth = bandwidth
        self.gain = gain

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
        bandwidthParameter = tree["bandwidth"]
        gainParameter = tree["gain"]

        internalAU?.setParameterImmediately(.centerFrequency, value: centerFrequency)
        internalAU?.setParameterImmediately(.bandwidth, value: bandwidth)
        internalAU?.setParameterImmediately(.gain, value: gain)
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
