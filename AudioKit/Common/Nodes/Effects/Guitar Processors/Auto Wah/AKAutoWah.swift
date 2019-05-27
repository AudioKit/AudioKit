//
//  AKAutoWah.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// An automatic wah effect, ported from Guitarix via Faust.
///
open class AKAutoWah: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKAutoWahAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "awah")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    fileprivate var wahParameter: AUParameter?
    fileprivate var mixParameter: AUParameter?
    fileprivate var amplitudeParameter: AUParameter?

    /// Lower and upper bounds for Wah
    public static let wahRange = 0.0 ... 1.0

    /// Lower and upper bounds for Mix
    public static let mixRange = 0.0 ... 1.0

    /// Lower and upper bounds for Amplitude
    public static let amplitudeRange = 0.0 ... 1.0

    /// Initial value for Wah
    public static let defaultWah = 0.0

    /// Initial value for Mix
    public static let defaultMix = 1.0

    /// Initial value for Amplitude
    public static let defaultAmplitude = 0.1

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Wah Amount
    @objc open dynamic var wah: Double = defaultWah {
        willSet {
            guard wah != newValue else { return }
            if internalAU?.isSetUp == true {
                wahParameter?.value = AUValue(newValue)
                return
            }
            internalAU?.setParameterImmediately(.wah, value: newValue)
        }
    }

    /// Dry/Wet Mix
    @objc open dynamic var mix: Double = defaultMix {
        willSet {
            guard mix != newValue else { return }
            if internalAU?.isSetUp == true {
                mixParameter?.value = AUValue(newValue)
                return
            }
            internalAU?.setParameterImmediately(.mix, value: newValue)
        }
    }

    /// Overall level
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

    /// Initialize this autoWah node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - wah: Wah Amount
    ///   - mix: Dry/Wet Mix
    ///   - amplitude: Overall level
    ///
    @objc public init(
        _ input: AKNode? = nil,
        wah: Double = defaultWah,
        mix: Double = defaultMix,
        amplitude: Double = defaultAmplitude
        ) {

        self.wah = wah
        self.mix = mix
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
            input?.connect(to: strongSelf)
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        wahParameter = tree["wah"]
        mixParameter = tree["mix"]
        amplitudeParameter = tree["amplitude"]

        internalAU?.setParameterImmediately(.wah, value: wah)
        internalAU?.setParameterImmediately(.mix, value: mix)
        internalAU?.setParameterImmediately(.amplitude, value: amplitude)
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
