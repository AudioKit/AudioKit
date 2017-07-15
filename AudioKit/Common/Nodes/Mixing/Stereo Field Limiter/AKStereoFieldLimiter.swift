//
//  AKStereoFieldLimiter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Stereo Field Limiter
open class AKStereoFieldLimiter: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKStereoFieldLimiterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "sflm")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var amountParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    fileprivate var lastKnownamount: Double = 1.0

    /// Limiting Factor
    open dynamic var amount: Double = 0 {
        willSet {
            if amount != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        amountParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.amount = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
    }

    // MARK: - Initialization

    /// Initialize this stereo field limiter node
    ///
    /// - Parameters:
    ///   - input: AKNode whose output will be limited
    ///   - amount: limit factor (Default: 1, Minimum: 0)
    ///
    public init(
        _ input: AKNode?,
        amount: Double = 1) {

        self.amount = amount

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

        amountParameter = tree["amount"]

        token = tree.token(byAddingParameterObserver: { [weak self] _, _ in

            guard let _ = self else { return } // Replace _ with strongSelf if needed
            DispatchQueue.main.async {
                // This node does not change its own values so we won't add any
                // value observing, but if you need to, this is where that goes.
            }
        })
        internalAU?.amount = Float(amount)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        if isStopped {
            amount = lastKnownamount
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        if isPlaying {
            lastKnownamount = amount
            amount = 1
        }
    }
}
