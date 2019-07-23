//
//  AKFlatFrequencyResponseReverb.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// This filter reiterates the input with an echo density determined by loop
/// time. The attenuation rate is independent and is determined by the
/// reverberation time (defined as the time in seconds for a signal to decay to
/// 1/1000, or 60dB down from its original amplitude).  Output will begin to
/// appear immediately.
///
open class AKFlatFrequencyResponseReverb: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKFlatFrequencyResponseReverbAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "alps")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    fileprivate var reverbDurationParameter: AUParameter?

    /// Lower and upper bounds for Reverb Duration
    public static let reverbDurationRange = 0.0 ... 10.0

    /// Initial value for Reverb Duration
    public static let defaultReverbDuration = 0.5

    /// Initial value for Loop Duration
    public static let defaultLoopDuration = 0.1

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// The duration in seconds for a signal to decay to 1/1000, or 60dB down from its original amplitude.
    @objc open dynamic var reverbDuration: Double = defaultReverbDuration {
        willSet {
            guard reverbDuration != newValue else { return }
            if internalAU?.isSetUp == true {
                reverbDurationParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.reverbDuration, value: newValue)
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
    ///   - reverbDuration: The duration in seconds for a signal to decay to 1/1000,
    ///                     or 60dB down from its original amplitude.
    ///   - loopDuration: The loop duration of the filter, in seconds. This can also be thought of as the
    ///                   delay time or “echo density” of the reverberation.
    ///
    @objc public init(
        _ input: AKNode? = nil,
        reverbDuration: Double = defaultReverbDuration,
        loopDuration: Double = defaultLoopDuration
        ) {

        self.reverbDuration = reverbDuration

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
            strongSelf.internalAU?.initializeConstant(Float(loopDuration))
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        reverbDurationParameter = tree["reverbDuration"]

        internalAU?.setParameterImmediately(.reverbDuration, value: reverbDuration)
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
