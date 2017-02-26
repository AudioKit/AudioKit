//
//  AKFlatFrequencyResponseReverb.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// This filter reiterates the input with an echo density determined by loop
/// time. The attenuation rate is independent and is determined by the
/// reverberation time (defined as the time in seconds for a signal to decay to
/// 1/1000, or 60dB down from its original amplitude).  Output will begin to
/// appear immediately.
///
open class AKFlatFrequencyResponseReverb: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKFlatFrequencyResponseReverbAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "alps")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var reverbDurationParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// The duration in seconds for a signal to decay to 1/1000, or 60dB down from its original amplitude.
    open dynamic var reverbDuration: Double = 0.5 {
        willSet {
            if reverbDuration != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        reverbDurationParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.reverbDuration = Float(newValue)
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
    ///   - reverbDuration: The duration in seconds for a signal to decay to 1/1000,
    ///                     or 60dB down from its original amplitude.
    ///   - loopDuration: The loop duration of the filter, in seconds. This can also be thought of as the
    ///                   delay time or “echo density” of the reverberation.
    ///
    public init(
        _ input: AKNode,
        reverbDuration: Double = 0.5,
        loopDuration: Double = 0.1) {

        self.reverbDuration = reverbDuration

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input.addConnectionPoint(self!)
            self?.internalAU!.setLoopDuration(Float(loopDuration))
        }

        guard let tree = internalAU?.parameterTree else {
            return
        }

        reverbDurationParameter = tree["reverbDuration"]

        token = tree.token (byAddingParameterObserver: { [weak self] address, value in

            DispatchQueue.main.async {
                if address == self?.reverbDurationParameter?.address {
                    self?.reverbDuration = Double(value)
                }
            }
        })

        internalAU?.reverbDuration = Float(reverbDuration)
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
