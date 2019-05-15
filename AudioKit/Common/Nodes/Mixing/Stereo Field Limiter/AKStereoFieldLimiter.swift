//
//  AKStereoFieldLimiter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Stereo StereoFieldLimiter
///
open class AKStereoFieldLimiter: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKStereoFieldLimiterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "sflm")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?

    fileprivate var amountParameter: AUParameter?

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Limiting Factor
    @objc open dynamic var amount: Double = 1 {
        willSet {
            guard amount != newValue else { return }

            if internalAU?.isSetUp == true {
                amountParameter?.value = AUValue(newValue)
                return
            }
            internalAU?.setParameterImmediately(.amount, value: newValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return self.internalAU?.isPlaying ?? false
    }

    // MARK: - Initialization

    /// Initialize this booster node
    ///
    /// - Parameters:
    ///   - input: AKNode whose output will be amplified
    ///   - amount: limit factor (Default: 1, Minimum: 0)
    ///
    @objc public init(_ input: AKNode? = nil, amount: Double = 1) {

        self.amount = amount

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

        self.amountParameter = tree["amount"]

        internalAU?.setParameterImmediately(.amount, value: amount)
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
