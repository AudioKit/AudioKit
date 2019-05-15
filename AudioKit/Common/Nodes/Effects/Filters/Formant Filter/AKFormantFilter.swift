//
//  AKFormantFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// When fed with a pulse train, it will generate a series of overlapping
/// grains. Overlapping will occur when 1/freq < dec, but there is no upper
/// limit on the number of overlaps.
///
open class AKFormantFilter: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKFormantFilterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "fofi")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    fileprivate var centerFrequencyParameter: AUParameter?
    fileprivate var attackDurationParameter: AUParameter?
    fileprivate var decayDurationParameter: AUParameter?

    /// Lower and upper bounds for Center Frequency
    public static let centerFrequencyRange = 12.0 ... 20_000.0

    /// Lower and upper bounds for Attack Duration
    public static let attackDurationRange = 0.0 ... 0.1

    /// Lower and upper bounds for Decay Duration
    public static let decayDurationRange = 0.0 ... 0.1

    /// Initial value for Center Frequency
    public static let defaultCenterFrequency = 1_000.0

    /// Initial value for Attack Duration
    public static let defaultAttackDuration = 0.007

    /// Initial value for Decay Duration
    public static let defaultDecayDuration = 0.04

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Center frequency.
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

    /// Impulse response attack duration (in seconds).
    @objc open dynamic var attackDuration: Double = defaultAttackDuration {
        willSet {
            guard attackDuration != newValue else { return }
            if internalAU?.isSetUp == true {
                attackDurationParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.attackDuration, value: newValue)
        }
    }

    /// Impulse reponse decay duration (in seconds)
    @objc open dynamic var decayDuration: Double = defaultDecayDuration {
        willSet {
            guard decayDuration != newValue else { return }
            if internalAU?.isSetUp == true {
                decayDurationParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.decayDuration, value: newValue)
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
    ///   - centerFrequency: Center frequency.
    ///   - attackDuration: Impulse response attack duration (in seconds).
    ///   - decayDuration: Impulse reponse decay duration (in seconds)
    ///
    @objc public init(
        _ input: AKNode? = nil,
        centerFrequency: Double = defaultCenterFrequency,
        attackDuration: Double = defaultAttackDuration,
        decayDuration: Double = defaultDecayDuration
        ) {

        self.centerFrequency = centerFrequency
        self.attackDuration = attackDuration
        self.decayDuration = decayDuration

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
        attackDurationParameter = tree["attackDuration"]
        decayDurationParameter = tree["decayDuration"]

        internalAU?.setParameterImmediately(.centerFrequency, value: centerFrequency)
        internalAU?.setParameterImmediately(.attackDuration, value: attackDuration)
        internalAU?.setParameterImmediately(.decayDuration, value: decayDuration)
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
