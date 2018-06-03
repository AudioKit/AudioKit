//
//  AKZitaReverb.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// 8 FDN stereo zitareverb algorithm, imported from Faust.
///
open class AKZitaReverb: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKZitaReverbAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "zita")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var predelayParameter: AUParameter?
    fileprivate var crossoverFrequencyParameter: AUParameter?
    fileprivate var lowReleaseTimeParameter: AUParameter?
    fileprivate var midReleaseTimeParameter: AUParameter?
    fileprivate var dampingFrequencyParameter: AUParameter?
    fileprivate var equalizerFrequency1Parameter: AUParameter?
    fileprivate var equalizerLevel1Parameter: AUParameter?
    fileprivate var equalizerFrequency2Parameter: AUParameter?
    fileprivate var equalizerLevel2Parameter: AUParameter?
    fileprivate var dryWetMixParameter: AUParameter?

    /// Lower and upper bounds for Predelay
    public static let predelayRange = 0.0 ... 200.0

    /// Lower and upper bounds for Crossover Frequency
    public static let crossoverFrequencyRange = 10.0 ... 1_000.0

    /// Lower and upper bounds for Low Release Duration
    public static let lowReleaseTimeRange = 0.0 ... 10.0

    /// Lower and upper bounds for Mid Release Duration
    public static let midReleaseTimeRange = 0.0 ... 10.0

    /// Lower and upper bounds for Damping Frequency
    public static let dampingFrequencyRange = 10.0 ... 22_050.0

    /// Lower and upper bounds for Equalizer Frequency1
    public static let equalizerFrequency1Range = 10.0 ... 1_000.0

    /// Lower and upper bounds for Equalizer Level1
    public static let equalizerLevel1Range = -100.0 ... 10.0

    /// Lower and upper bounds for Equalizer Frequency2
    public static let equalizerFrequency2Range = 10.0 ... 22_050.0

    /// Lower and upper bounds for Equalizer Level2
    public static let equalizerLevel2Range = -100.0 ... 10.0

    /// Lower and upper bounds for Dry Wet Mix
    public static let dryWetMixRange = 0.0 ... 1.0

    /// Initial value for Predelay
    public static let defaultPredelay = 60.0

    /// Initial value for Crossover Frequency
    public static let defaultCrossoverFrequency = 200.0

    /// Initial value for Low Release Duration
    public static let defaultLowReleaseTime = 3.0

    /// Initial value for Mid Release Duration
    public static let defaultMidReleaseTime = 2.0

    /// Initial value for Damping Frequency
    public static let defaultDampingFrequency = 6_000.0

    /// Initial value for Equalizer Frequency1
    public static let defaultEqualizerFrequency1 = 315.0

    /// Initial value for Equalizer Level1
    public static let defaultEqualizerLevel1 = 0.0

    /// Initial value for Equalizer Frequency2
    public static let defaultEqualizerFrequency2 = 1_500.0

    /// Initial value for Equalizer Level2
    public static let defaultEqualizerLevel2 = 0.0

    /// Initial value for Dry Wet Mix
    public static let defaultDryWetMix = 1.0

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Delay in ms before reverberation begins.
    @objc open dynamic var predelay: Double = defaultPredelay {
        willSet {
            if predelay == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    predelayParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.predelay, value: newValue)
        }
    }

    /// Crossover frequency separating low and middle frequencies (Hz).
    @objc open dynamic var crossoverFrequency: Double = defaultCrossoverFrequency {
        willSet {
            if crossoverFrequency == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    crossoverFrequencyParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.crossoverFrequency, value: newValue)
        }
    }

    /// Time (in seconds) to decay 60db in low-frequency band.
    @objc open dynamic var lowReleaseTime: Double = defaultLowReleaseTime {
        willSet {
            if lowReleaseTime == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    lowReleaseTimeParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.lowReleaseTime, value: newValue)
        }
    }

    /// Time (in seconds) to decay 60db in mid-frequency band.
    @objc open dynamic var midReleaseTime: Double = defaultMidReleaseTime {
        willSet {
            if midReleaseTime == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    midReleaseTimeParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.midReleaseTime, value: newValue)
        }
    }

    /// Frequency (Hz) at which the high-frequency T60 is half the middle-band's T60.
    @objc open dynamic var dampingFrequency: Double = defaultDampingFrequency {
        willSet {
            if dampingFrequency == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    dampingFrequencyParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.dampingFrequency, value: newValue)
        }
    }

    /// Center frequency of second-order Regalia Mitra peaking equalizer section 1.
    @objc open dynamic var equalizerFrequency1: Double = defaultEqualizerFrequency1 {
        willSet {
            if equalizerFrequency1 == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    equalizerFrequency1Parameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.equalizerFrequency1, value: newValue)
        }
    }

    /// Peak level in dB of second-order Regalia-Mitra peaking equalizer section 1
    @objc open dynamic var equalizerLevel1: Double = defaultEqualizerLevel1 {
        willSet {
            if equalizerLevel1 == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    equalizerLevel1Parameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.equalizerLevel1, value: newValue)
        }
    }

    /// Center frequency of second-order Regalia Mitra peaking equalizer section 2.
    @objc open dynamic var equalizerFrequency2: Double = defaultEqualizerFrequency2 {
        willSet {
            if equalizerFrequency2 == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    equalizerFrequency2Parameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.equalizerFrequency2, value: newValue)
        }
    }

    /// Peak level in dB of second-order Regalia-Mitra peaking equalizer section 2
    @objc open dynamic var equalizerLevel2: Double = defaultEqualizerLevel2 {
        willSet {
            if equalizerLevel2 == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    equalizerLevel2Parameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.equalizerLevel2, value: newValue)
        }
    }

    /// 0 = all dry, 1 = all wet
    @objc open dynamic var dryWetMix: Double = defaultDryWetMix {
        willSet {
            if dryWetMix == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    dryWetMixParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.dryWetMix, value: newValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
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
    @objc public init(
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

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in
            guard let strongSelf = self else {
                AKLog("Error: self is nil")
                return
            }
            strongSelf.avAudioNode = avAudioUnit
            strongSelf.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: strongSelf)
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        predelayParameter = tree["predelay"]
        crossoverFrequencyParameter = tree["crossoverFrequency"]
        lowReleaseTimeParameter = tree["lowReleaseTime"]
        midReleaseTimeParameter = tree["midReleaseTime"]
        dampingFrequencyParameter = tree["dampingFrequency"]
        equalizerFrequency1Parameter = tree["equalizerFrequency1"]
        equalizerLevel1Parameter = tree["equalizerLevel1"]
        equalizerFrequency2Parameter = tree["equalizerFrequency2"]
        equalizerLevel2Parameter = tree["equalizerLevel2"]
        dryWetMixParameter = tree["dryWetMix"]

        token = tree.token(byAddingParameterObserver: { [weak self] _, _ in

            guard let _ = self else {
                AKLog("Unable to create strong reference to self")
                return
            } // Replace _ with strongSelf if needed
            DispatchQueue.main.async {
                // This node does not change its own values so we won't add any
                // value observing, but if you need to, this is where that goes.
            }
        })

        internalAU?.setParameterImmediately(.predelay, value: predelay)
        internalAU?.setParameterImmediately(.crossoverFrequency, value: crossoverFrequency)
        internalAU?.setParameterImmediately(.lowReleaseTime, value: lowReleaseTime)
        internalAU?.setParameterImmediately(.midReleaseTime, value: midReleaseTime)
        internalAU?.setParameterImmediately(.dampingFrequency, value: dampingFrequency)
        internalAU?.setParameterImmediately(.equalizerFrequency1, value: equalizerFrequency1)
        internalAU?.setParameterImmediately(.equalizerLevel1, value: equalizerLevel1)
        internalAU?.setParameterImmediately(.equalizerFrequency2, value: equalizerFrequency2)
        internalAU?.setParameterImmediately(.equalizerLevel2, value: equalizerLevel2)
        internalAU?.setParameterImmediately(.dryWetMix, value: dryWetMix)
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
