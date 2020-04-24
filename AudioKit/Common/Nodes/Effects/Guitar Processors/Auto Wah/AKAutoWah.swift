//
//  AKAutoWah.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

/// An automatic wah effect, ported from Guitarix via Faust.
///
open class AKAutoWah: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKAutoWahAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "awah")

    // MARK: - Properties
    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Wah
    public static let wahRange: ClosedRange<Double> = 0.0 ... 1.0

    /// Lower and upper bounds for Mix
    public static let mixRange: ClosedRange<Double> = 0.0 ... 1.0

    /// Lower and upper bounds for Amplitude
    public static let amplitudeRange: ClosedRange<Double> = 0.0 ... 1.0

    /// Initial value for Wah
    public static let defaultWah: Double = 0.0

    /// Initial value for Mix
    public static let defaultMix: Double = 1.0

    /// Initial value for Amplitude
    public static let defaultAmplitude: Double = 0.1

    /// Wah Amount
    open var wah: Double = defaultWah {
        willSet {
            let clampedValue = AKAutoWah.wahRange.clamp(newValue)
            guard wah != clampedValue else { return }
            internalAU?.wah.value = AUValue(clampedValue)
        }
    }

    /// Dry/Wet Mix
    open var mix: Double = defaultMix {
        willSet {
            let clampedValue = AKAutoWah.mixRange.clamp(newValue)
            guard mix != clampedValue else { return }
            internalAU?.mix.value = AUValue(clampedValue)
        }
    }

    /// Overall level
    open var amplitude: Double = defaultAmplitude {
        willSet {
            let clampedValue = AKAutoWah.amplitudeRange.clamp(newValue)
            guard amplitude != clampedValue else { return }
            internalAU?.amplitude.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize this autoWah node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - wah: Wah Amount
    ///   - mix: Dry/Wet Mix
    ///   - amplitude: Overall level
    ///
    public init(
        _ input: AKNode? = nil,
        wah: Double = defaultWah,
        mix: Double = defaultMix,
        amplitude: Double = defaultAmplitude
        ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)

            self.wah = wah
            self.mix = mix
            self.amplitude = amplitude
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
