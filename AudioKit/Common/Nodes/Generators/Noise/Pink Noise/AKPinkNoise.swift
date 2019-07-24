//
//  AKPinkNoise.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Faust-based pink noise generator
///
open class AKPinkNoise: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKPinkNoiseAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "pink")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?

    fileprivate var amplitudeParameter: AUParameter?

    /// Lower and upper bounds for Amplitude
    public static let amplitudeRange = 0.0 ... 1.0

    /// Initial value for Amplitude
    public static let defaultAmplitude = 1.0

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Amplitude. (Value between 0-1).
    @objc open dynamic var amplitude: Double = defaultAmplitude {
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

    /// Initialize this noise node
    ///
    /// - Parameters:
    ///   - amplitude: Amplitude. (Value between 0-1).
    ///
    @objc public init(
        amplitude: Double = defaultAmplitude) {

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

        amplitudeParameter = tree["amplitude"]
        internalAU?.setParameterImmediately(.amplitude, value: amplitude)
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
