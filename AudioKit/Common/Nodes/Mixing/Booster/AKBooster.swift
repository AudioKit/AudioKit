//
//  AKBooster.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Stereo Booster
///
open class AKBooster: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKBoosterAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "gain")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var gainParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    fileprivate var lastKnownGain: Double = 1.0

    /// Amplification Factor
    open dynamic var gain: Double = 1 {
        willSet {
            if gain != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        gainParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.gain = Float(newValue)
                }
            }
        }
    }

    /// Amplification Factor in db
    open dynamic var dB: Double {
        set {
            gain = pow(10.0, Double(newValue / 20))
        }
        get {
            return 20.0 * log10(gain)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
    }

    // MARK: - Initialization

    /// Initialize this gainner node
    ///
    /// - Parameters:
    ///   - input: AKNode whose output will be amplified
    ///   - gain: Amplification factor (Default: 1, Minimum: 0)
    ///
    public init(
        _ input: AKNode?,
        gain: Double = 1) {

        self.gain = gain

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

        gainParameter = tree["gain"]

        token = tree.token (byAddingParameterObserver: { [weak self] address, value in

            DispatchQueue.main.async {
                if address == self?.gainParameter?.address {
                    self?.gain = Double(value)
                }
            }
        })
        internalAU?.gain = Float(gain)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        if isStopped {
            gain = lastKnownGain
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        if isPlaying {
            lastKnownGain = gain
            gain = 1
        }
    }
}
