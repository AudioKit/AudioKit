//
//  AKModalResonanceFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// A modal resonance filter used for modal synthesis. Plucked and bell sounds
/// can be created using  passing an impulse through a combination of modal
/// filters.
///
open class AKModalResonanceFilter: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKModalResonanceFilterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "modf")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    fileprivate var frequencyParameter: AUParameter?
    fileprivate var qualityFactorParameter: AUParameter?

    /// Lower and upper bounds for Frequency
    public static let frequencyRange = 12.0 ... 20_000.0

    /// Lower and upper bounds for Quality Factor
    public static let qualityFactorRange = 0.0 ... 100.0

    /// Initial value for Frequency
    public static let defaultFrequency = 500.0

    /// Initial value for Quality Factor
    public static let defaultQualityFactor = 50.0

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Resonant frequency of the filter.
    @objc open dynamic var frequency: Double = defaultFrequency {
        willSet {
            guard frequency != newValue else { return }
            if internalAU?.isSetUp == true {
                frequencyParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.frequency, value: newValue)
        }
    }

    /// Quality factor of the filter. Roughly equal to Q/frequency.
    @objc open dynamic var qualityFactor: Double = defaultQualityFactor {
        willSet {
            guard qualityFactor != newValue else { return }
            if internalAU?.isSetUp == true {
                qualityFactorParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.qualityFactor, value: newValue)
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
    ///   - frequency: Resonant frequency of the filter.
    ///   - qualityFactor: Quality factor of the filter. Roughly equal to Q/frequency.
    ///
    @objc public init(
        _ input: AKNode? = nil,
        frequency: Double = defaultFrequency,
        qualityFactor: Double = defaultQualityFactor
        ) {

        self.frequency = frequency
        self.qualityFactor = qualityFactor

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

        frequencyParameter = tree["frequency"]
        qualityFactorParameter = tree["qualityFactor"]

        internalAU?.setParameterImmediately(.frequency, value: frequency)
        internalAU?.setParameterImmediately(.qualityFactor, value: qualityFactor)
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
