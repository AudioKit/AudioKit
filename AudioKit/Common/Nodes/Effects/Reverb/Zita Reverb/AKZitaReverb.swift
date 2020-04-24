//
//  AKZitaReverb.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

/// 8 FDN stereo zitareverb algorithm, imported from Faust.
///
open class AKZitaReverb: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKZitaReverbAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "zita")

    // MARK: - Properties
    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Predelay
    public static let predelayRange: ClosedRange<Double> = 0.0 ... 200.0

    /// Lower and upper bounds for Crossover Frequency
    public static let crossoverFrequencyRange: ClosedRange<Double> = 10.0 ... 1000.0

    /// Lower and upper bounds for Low Release Time
    public static let lowReleaseTimeRange: ClosedRange<Double> = 0.0 ... 10.0

    /// Lower and upper bounds for Mid Release Time
    public static let midReleaseTimeRange: ClosedRange<Double> = 0.0 ... 10.0

    /// Lower and upper bounds for Damping Frequency
    public static let dampingFrequencyRange: ClosedRange<Double> = 10.0 ... 22050.0

    /// Lower and upper bounds for Equalizer Frequency1
    public static let equalizerFrequency1Range: ClosedRange<Double> = 10.0 ... 1000.0

    /// Lower and upper bounds for Equalizer Level1
    public static let equalizerLevel1Range: ClosedRange<Double> = -100.0 ... 10.0

    /// Lower and upper bounds for Equalizer Frequency2
    public static let equalizerFrequency2Range: ClosedRange<Double> = 10.0 ... 22050.0

    /// Lower and upper bounds for Equalizer Level2
    public static let equalizerLevel2Range: ClosedRange<Double> = -100.0 ... 10.0

    /// Lower and upper bounds for Dry Wet Mix
    public static let dryWetMixRange: ClosedRange<Double> = 0.0 ... 1.0

    /// Initial value for Predelay
    public static let defaultPredelay: Double = 60.0

    /// Initial value for Crossover Frequency
    public static let defaultCrossoverFrequency: Double = 200.0

    /// Initial value for Low Release Time
    public static let defaultLowReleaseTime: Double = 3.0

    /// Initial value for Mid Release Time
    public static let defaultMidReleaseTime: Double = 2.0

    /// Initial value for Damping Frequency
    public static let defaultDampingFrequency: Double = 6000.0

    /// Initial value for Equalizer Frequency1
    public static let defaultEqualizerFrequency1: Double = 315.0

    /// Initial value for Equalizer Level1
    public static let defaultEqualizerLevel1: Double = 0.0

    /// Initial value for Equalizer Frequency2
    public static let defaultEqualizerFrequency2: Double = 1500.0

    /// Initial value for Equalizer Level2
    public static let defaultEqualizerLevel2: Double = 0.0

    /// Initial value for Dry Wet Mix
    public static let defaultDryWetMix: Double = 1.0

    /// Delay in ms before reverberation begins.
    open var predelay: Double = defaultPredelay {
        willSet {
            let clampedValue = AKZitaReverb.predelayRange.clamp(newValue)
            guard predelay != clampedValue else { return }
            internalAU?.predelay.value = AUValue(clampedValue)
        }
    }

    /// Crossover frequency separating low and middle frequencies (Hz).
    open var crossoverFrequency: Double = defaultCrossoverFrequency {
        willSet {
            let clampedValue = AKZitaReverb.crossoverFrequencyRange.clamp(newValue)
            guard crossoverFrequency != clampedValue else { return }
            internalAU?.crossoverFrequency.value = AUValue(clampedValue)
        }
    }

    /// Time (in seconds) to decay 60db in low-frequency band.
    open var lowReleaseTime: Double = defaultLowReleaseTime {
        willSet {
            let clampedValue = AKZitaReverb.lowReleaseTimeRange.clamp(newValue)
            guard lowReleaseTime != clampedValue else { return }
            internalAU?.lowReleaseTime.value = AUValue(clampedValue)
        }
    }

    /// Time (in seconds) to decay 60db in mid-frequency band.
    open var midReleaseTime: Double = defaultMidReleaseTime {
        willSet {
            let clampedValue = AKZitaReverb.midReleaseTimeRange.clamp(newValue)
            guard midReleaseTime != clampedValue else { return }
            internalAU?.midReleaseTime.value = AUValue(clampedValue)
        }
    }

    /// Frequency (Hz) at which the high-frequency T60 is half the middle-band's T60.
    open var dampingFrequency: Double = defaultDampingFrequency {
        willSet {
            let clampedValue = AKZitaReverb.dampingFrequencyRange.clamp(newValue)
            guard dampingFrequency != clampedValue else { return }
            internalAU?.dampingFrequency.value = AUValue(clampedValue)
        }
    }

    /// Center frequency of second-order Regalia Mitra peaking equalizer section 1.
    open var equalizerFrequency1: Double = defaultEqualizerFrequency1 {
        willSet {
            let clampedValue = AKZitaReverb.equalizerFrequency1Range.clamp(newValue)
            guard equalizerFrequency1 != clampedValue else { return }
            internalAU?.equalizerFrequency1.value = AUValue(clampedValue)
        }
    }

    /// Peak level in dB of second-order Regalia-Mitra peaking equalizer section 1
    open var equalizerLevel1: Double = defaultEqualizerLevel1 {
        willSet {
            let clampedValue = AKZitaReverb.equalizerLevel1Range.clamp(newValue)
            guard equalizerLevel1 != clampedValue else { return }
            internalAU?.equalizerLevel1.value = AUValue(clampedValue)
        }
    }

    /// Center frequency of second-order Regalia Mitra peaking equalizer section 2.
    open var equalizerFrequency2: Double = defaultEqualizerFrequency2 {
        willSet {
            let clampedValue = AKZitaReverb.equalizerFrequency2Range.clamp(newValue)
            guard equalizerFrequency2 != clampedValue else { return }
            internalAU?.equalizerFrequency2.value = AUValue(clampedValue)
        }
    }

    /// Peak level in dB of second-order Regalia-Mitra peaking equalizer section 2
    open var equalizerLevel2: Double = defaultEqualizerLevel2 {
        willSet {
            let clampedValue = AKZitaReverb.equalizerLevel2Range.clamp(newValue)
            guard equalizerLevel2 != clampedValue else { return }
            internalAU?.equalizerLevel2.value = AUValue(clampedValue)
        }
    }

    /// 0 = all dry, 1 = all wet
    open var dryWetMix: Double = defaultDryWetMix {
        willSet {
            let clampedValue = AKZitaReverb.dryWetMixRange.clamp(newValue)
            guard dryWetMix != clampedValue else { return }
            internalAU?.dryWetMix.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize this reverb node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - predelay: Delay in ms before reverberation begins.
    ///   - crossoverFrequency: Crossover frequency separating low and middle frequencies (Hz).
    ///   - lowReleaseTime: Time (in seconds) to decay 60db in low-frequency band.
    ///   - midReleaseTime: Time (in seconds) to decay 60db in mid-frequency band.
    ///   - dampingFrequency: Frequency (Hz) at which the high-frequency T60 is half the middle-band's T60.
    ///   - equalizerFrequency1: Center frequency of second-order Regalia Mitra peaking equalizer section 1.
    ///   - equalizerLevel1: Peak level in dB of second-order Regalia-Mitra peaking equalizer section 1
    ///   - equalizerFrequency2: Center frequency of second-order Regalia Mitra peaking equalizer section 2.
    ///   - equalizerLevel2: Peak level in dB of second-order Regalia-Mitra peaking equalizer section 2
    ///   - dryWetMix: 0 = all dry, 1 = all wet
    ///
    public init(
        _ input: AKNode? = nil,
        predelay: Double = defaultPredelay,
        crossoverFrequency: Double = defaultCrossoverFrequency,
        lowReleaseTime: Double = defaultLowReleaseTime,
        midReleaseTime: Double = defaultMidReleaseTime,
        dampingFrequency: Double = defaultDampingFrequency,
        equalizerFrequency1: Double = defaultEqualizerFrequency1,
        equalizerLevel1: Double = defaultEqualizerLevel1,
        equalizerFrequency2: Double = defaultEqualizerFrequency2,
        equalizerLevel2: Double = defaultEqualizerLevel2,
        dryWetMix: Double = defaultDryWetMix
        ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)

            self.predelay = predelay
            self.crossoverFrequency = crossoverFrequency
            self.lowReleaseTime = lowReleaseTime
            self.midReleaseTime = midReleaseTime
            self.dampingFrequency = dampingFrequency
            self.equalizerFrequency1 = equalizerFrequency1
            self.equalizerLevel1 = equalizerLevel1
            self.equalizerFrequency2 = equalizerFrequency2
            self.equalizerLevel2 = equalizerLevel2
            self.dryWetMix = dryWetMix
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
