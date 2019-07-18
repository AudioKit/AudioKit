//
//  AKCombFilterReverb.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// This filter reiterates input with an echo density determined by
/// loopDuration. The attenuation rate is independent and is determined by
/// reverbDuration, the reverberation duration (defined as the time in seconds
/// for a signal to decay to 1/1000, or 60dB down from its original amplitude).
/// Output from a comb filter will appear only after loopDuration seconds.
///
open class AKCombFilterReverb: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKCombFilterReverbAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "comb")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    fileprivate var reverbDurationParameter: AUParameter?

    /// Lower and upper bounds for Reverb Duration
    public static let reverbDurationRange = 0.0 ... 10.0

    /// Initial value for Reverb Duration
    public static let defaultReverbDuration = 1.0

    /// Initial value for Loop Duration
    public static let defaultLoopDuration = 0.1

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// The time in seconds for a signal to decay to 1/1000, or 60dB from its original amplitude. (aka RT-60).
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

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - reverbDuration: The time in seconds for a signal to decay to 1/1000, or 60dB from its original amplitude. (aka RT-60).
    ///   - loopDuration: The loop time of the filter, in seconds. This can also be thought of as the delay time. Determines frequency response curve, loopDuration * sr/2 peaks spaced evenly between 0 and sr/2.
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
