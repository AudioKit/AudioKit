//
//  AKBandRejectButterworthFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// These filters are Butterworth second-order IIR filters. They offer an almost
/// flat passband and very good precision and stopband attenuation.
///
open class AKBandRejectButterworthFilter: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKBandRejectButterworthFilterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "btbr")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    fileprivate var centerFrequencyParameter: AUParameter?
    fileprivate var bandwidthParameter: AUParameter?

    /// Lower and upper bounds for Center Frequency
    public static let centerFrequencyRange = 12.0 ... 20_000.0

    /// Lower and upper bounds for Bandwidth
    public static let bandwidthRange = 0.0 ... 20_000.0

    /// Initial value for Center Frequency
    public static let defaultCenterFrequency = 3_000.0

    /// Initial value for Bandwidth
    public static let defaultBandwidth = 2_000.0

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

    /// Bandwidth. (in Hertz)
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
    ///   - bandwidth: Bandwidth. (in Hertz)
    ///
    @objc public init(
        _ input: AKNode? = nil,
        centerFrequency: Double = defaultCenterFrequency,
        bandwidth: Double = defaultBandwidth
        ) {

        self.centerFrequency = centerFrequency
        self.bandwidth = bandwidth

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

        internalAU?.setParameterImmediately(.centerFrequency, value: centerFrequency)
        internalAU?.setParameterImmediately(.bandwidth, value: bandwidth)
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
