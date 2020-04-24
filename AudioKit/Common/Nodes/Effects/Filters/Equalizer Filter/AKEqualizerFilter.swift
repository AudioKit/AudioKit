//
//  AKEqualizerFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
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
    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Center Frequency
    public static let centerFrequencyRange: ClosedRange<Double> = 12.0 ... 20000.0

    /// Lower and upper bounds for Bandwidth
    public static let bandwidthRange: ClosedRange<Double> = 0.0 ... 20000.0

    /// Lower and upper bounds for Gain
    public static let gainRange: ClosedRange<Double> = -100.0 ... 100.0

    /// Initial value for Center Frequency
    public static let defaultCenterFrequency: Double = 1000.0

    /// Initial value for Bandwidth
    public static let defaultBandwidth: Double = 100.0

    /// Initial value for Gain
    public static let defaultGain: Double = 10.0

    /// Center frequency. (in Hertz)
    open var centerFrequency: Double = defaultCenterFrequency {
        willSet {
            let clampedValue = AKEqualizerFilter.centerFrequencyRange.clamp(newValue)
            guard centerFrequency != clampedValue else { return }
            internalAU?.centerFrequency.value = AUValue(clampedValue)
        }
    }

    /// The peak/notch bandwidth in Hertz
    open var bandwidth: Double = defaultBandwidth {
        willSet {
            let clampedValue = AKEqualizerFilter.bandwidthRange.clamp(newValue)
            guard bandwidth != clampedValue else { return }
            internalAU?.bandwidth.value = AUValue(clampedValue)
        }
    }

    /// The peak/notch gain
    open var gain: Double = defaultGain {
        willSet {
            let clampedValue = AKEqualizerFilter.gainRange.clamp(newValue)
            guard gain != clampedValue else { return }
            internalAU?.gain.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU?.isStarted ?? false
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
    public init(
        _ input: AKNode? = nil,
        centerFrequency: Double = defaultCenterFrequency,
        bandwidth: Double = defaultBandwidth,
        gain: Double = defaultGain
        ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)

            self.centerFrequency = centerFrequency
            self.bandwidth = bandwidth
            self.gain = gain
        }
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
