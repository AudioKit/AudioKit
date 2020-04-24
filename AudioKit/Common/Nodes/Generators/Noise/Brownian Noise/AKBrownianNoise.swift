//
//  AKBrownianNoise.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

/// Brownian noise generator
///
open class AKBrownianNoise: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKBrownianNoiseAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "bron")

    // MARK: - Properties

    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Amplitude
    public static let amplitudeRange: ClosedRange<Double> = 0.0 ... 1.0

    /// Initial value for Amplitude
    public static let defaultAmplitude: Double = 1.0

    /// Amplitude. (Value between 0-1).
    open var amplitude: Double = defaultAmplitude {
        willSet {
            let clampedValue = AKBrownianNoise.amplitudeRange.clamp(newValue)
            guard amplitude != clampedValue else { return }
            internalAU?.amplitude.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization


    /// Initialize this brown-noise node
    ///
    /// - Parameters:
    ///   - amplitude: Amplitude. (Value between 0-1).
    ///
    public init(
        amplitude: Double = defaultAmplitude
    ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            self.amplitude = amplitude
        }
    }

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        internalAU?.stop()
    }
}
