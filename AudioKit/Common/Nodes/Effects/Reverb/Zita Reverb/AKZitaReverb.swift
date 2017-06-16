//
//  AKZitaReverb.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// 8 FDN stereo zitareverb algorithm, imported from Faust.
///
open class AKZitaReverb: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKZitaReverbAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "zita")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var delayParameter: AUParameter?
    fileprivate var crossoverFrequencyParameter: AUParameter?
    fileprivate var lowReleaseTimeParameter: AUParameter?
    fileprivate var midReleaseTimeParameter: AUParameter?
    fileprivate var dampingFrequencyParameter: AUParameter?
    fileprivate var equalizerFrequency1Parameter: AUParameter?
    fileprivate var equalizerLevel1Parameter: AUParameter?
    fileprivate var equalizerFrequency2Parameter: AUParameter?
    fileprivate var equalizerLevel2Parameter: AUParameter?
    fileprivate var dryWetMixParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = rampTime
        }
    }

    /// Delay in ms before reverberation begins.
    open dynamic var delay: Double = 60.0 {
        willSet {
            if delay != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        delayParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.delay = Float(newValue)
                }
            }
        }
    }

    /// Crossover frequency separating low and middle frequencies (Hz).
    open dynamic var crossoverFrequency: Double = 200.0 {
        willSet {
            if crossoverFrequency != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        crossoverFrequencyParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.crossoverFrequency = Float(newValue)
                }
            }
        }
    }

    /// Time (in seconds) to decay 60db in low-frequency band.
    open dynamic var lowReleaseTime: Double = 3.0 {
        willSet {
            if lowReleaseTime != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        lowReleaseTimeParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.lowReleaseTime = Float(newValue)
                }
            }
        }
    }

    /// Time (in seconds) to decay 60db in mid-frequency band.
    open dynamic var midReleaseTime: Double = 2.0 {
        willSet {
            if midReleaseTime != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        midReleaseTimeParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.midReleaseTime = Float(newValue)
                }
            }
        }
    }

    /// Frequency (Hz) at which the high-frequency T60 is half the middle-band's T60.
    open dynamic var dampingFrequency: Double = 6_000.0 {
        willSet {
            if dampingFrequency != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        dampingFrequencyParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.dampingFrequency = Float(newValue)
                }
            }
        }
    }

    /// Center frequency of second-order Regalia Mitra peaking equalizer section 1.
    open dynamic var equalizerFrequency1: Double = 315.0 {
        willSet {
            if equalizerFrequency1 != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        equalizerFrequency1Parameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.equalizerFrequency1 = Float(newValue)
                }
            }
        }
    }

    /// Peak level in dB of second-order Regalia-Mitra peaking equalizer section 1
    open dynamic var equalizerLevel1: Double = 0.0 {
        willSet {
            if equalizerLevel1 != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        equalizerLevel1Parameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.equalizerLevel1 = Float(newValue)
                }
            }
        }
    }

    /// Center frequency of second-order Regalia Mitra peaking equalizer section 2.
    open dynamic var equalizerFrequency2: Double = 1_500.0 {
        willSet {
            if equalizerFrequency2 != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        equalizerFrequency2Parameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.equalizerFrequency2 = Float(newValue)
                }
            }
        }
    }

    /// Peak level in dB of second-order Regalia-Mitra peaking equalizer section 2
    open dynamic var equalizerLevel2: Double = 0.0 {
        willSet {
            if equalizerLevel2 != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        equalizerLevel2Parameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.equalizerLevel2 = Float(newValue)
                }
            }
        }
    }

    /// 0 = all dry, 1 = all wet
    open dynamic var dryWetMix: Double = 1.0 {
        willSet {
            if dryWetMix != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        dryWetMixParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.dryWetMix = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
    }

    // MARK: - Initialization

    /// Initialize this reverb node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - delay: Delay in ms before reverberation begins.
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
        _ input: AKNode?,
        delay: Double = 60.0,
        crossoverFrequency: Double = 200.0,
        lowReleaseTime: Double = 3.0,
        midReleaseTime: Double = 2.0,
        dampingFrequency: Double = 6_000.0,
        equalizerFrequency1: Double = 315.0,
        equalizerLevel1: Double = 0.0,
        equalizerFrequency2: Double = 1_500.0,
        equalizerLevel2: Double = 0.0,
        dryWetMix: Double = 1.0) {

        self.delay = delay
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

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input?.addConnectionPoint(self!)
        }

        guard let tree = internalAU?.parameterTree else {
            return
        }

        delayParameter = tree["delay"]
        crossoverFrequencyParameter = tree["crossoverFrequency"]
        lowReleaseTimeParameter = tree["lowReleaseTime"]
        midReleaseTimeParameter = tree["midReleaseTime"]
        dampingFrequencyParameter = tree["dampingFrequency"]
        equalizerFrequency1Parameter = tree["equalizerFrequency1"]
        equalizerLevel1Parameter = tree["equalizerLevel1"]
        equalizerFrequency2Parameter = tree["equalizerFrequency2"]
        equalizerLevel2Parameter = tree["equalizerLevel2"]
        dryWetMixParameter = tree["dryWetMix"]

        token = tree.token(byAddingParameterObserver: { [weak self] address, value in

            DispatchQueue.main.async {
                if address == self?.delayParameter?.address {
                    self?.delay = Double(value)
                } else if address == self?.crossoverFrequencyParameter?.address {
                    self?.crossoverFrequency = Double(value)
                } else if address == self?.lowReleaseTimeParameter?.address {
                    self?.lowReleaseTime = Double(value)
                } else if address == self?.midReleaseTimeParameter?.address {
                    self?.midReleaseTime = Double(value)
                } else if address == self?.dampingFrequencyParameter?.address {
                    self?.dampingFrequency = Double(value)
                } else if address == self?.equalizerFrequency1Parameter?.address {
                    self?.equalizerFrequency1 = Double(value)
                } else if address == self?.equalizerLevel1Parameter?.address {
                    self?.equalizerLevel1 = Double(value)
                } else if address == self?.equalizerFrequency2Parameter?.address {
                    self?.equalizerFrequency2 = Double(value)
                } else if address == self?.equalizerLevel2Parameter?.address {
                    self?.equalizerLevel2 = Double(value)
                } else if address == self?.dryWetMixParameter?.address {
                    self?.dryWetMix = Double(value)
                }
            }
        })

        internalAU?.delay = Float(delay)
        internalAU?.crossoverFrequency = Float(crossoverFrequency)
        internalAU?.lowReleaseTime = Float(lowReleaseTime)
        internalAU?.midReleaseTime = Float(midReleaseTime)
        internalAU?.dampingFrequency = Float(dampingFrequency)
        internalAU?.equalizerFrequency1 = Float(equalizerFrequency1)
        internalAU?.equalizerLevel1 = Float(equalizerLevel1)
        internalAU?.equalizerFrequency2 = Float(equalizerFrequency2)
        internalAU?.equalizerLevel2 = Float(equalizerLevel2)
        internalAU?.dryWetMix = Float(dryWetMix)
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
