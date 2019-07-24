//
//  AKFlute.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// STK Flute
///
open class AKFlute: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKFluteAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "flut")
    // MARK: - Properties

    private var internalAU: AKAudioUnitType?

    fileprivate var frequencyParameter: AUParameter?
    fileprivate var amplitudeParameter: AUParameter?

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Variable frequency. Values less than the initial frequency will be doubled until it is greater than that.
    @objc open dynamic var frequency: Double = 110 {
        willSet {
            guard frequency != newValue else { return }
            if internalAU?.isSetUp == true {
                frequencyParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.frequency, value: newValue)
        }
    }

    /// Amplitude
    @objc open dynamic var amplitude: Double = 0.5 {
        willSet {
            guard amplitude != newValue else { return }
            if internalAU?.isSetUp == true {
                amplitudeParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.amplitude, value: newValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    // MARK: - Initialization

    /// Initialize the mandolin with defaults
    override convenience init() {
        self.init(frequency: 110)
    }

    /// Initialize the STK Flute model
    ///
    /// - Parameters:
    ///   - frequency: Variable frequency. Values less than the initial frequency will be doubled until it is
    ///                greater than that.
    ///   - amplitude: Amplitude
    ///
    @objc public init(
        frequency: Double = 440,
        amplitude: Double = 0.5) {

        self.frequency = frequency
        self.amplitude = amplitude

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
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        frequencyParameter = tree["frequency"]
        amplitudeParameter = tree["amplitude"]
        internalAU?.setParameterImmediately(.frequency, value: frequency)
        internalAU?.setParameterImmediately(.amplitude, value: amplitude)
    }

    /// Trigger the sound with current parameters
    ///
    open func trigger() {
        internalAU?.start()
        internalAU?.trigger()
    }

    /// Trigger the sound with a set of parameters
    ///
    /// - Parameters:
    ///   - frequency: Frequency in Hz
    ///   - amplitude amplitude: Volume
    ///
    open func trigger(frequency: Double, amplitude: Double = 1) {
        self.frequency = frequency
        self.amplitude = amplitude
        internalAU?.start()
        internalAU?.triggerFrequency(Float(frequency), amplitude: Float(amplitude))
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
