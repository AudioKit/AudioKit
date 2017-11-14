//
//  AKToneFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// A first-order recursive low-pass filter with variable frequency response.
///
open class AKToneFilter: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKToneFilterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "tone")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var halfPowerPointParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    @objc open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// The response curve's half-power point, in Hertz. Half power is defined as peak power / root 2.
    @objc open dynamic var halfPowerPoint: Double = 1_000.0 {
        willSet {
            if halfPowerPoint != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        halfPowerPointParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.halfPowerPoint = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - halfPowerPoint: The response curve's half-power point, in Hz. Half power is defined as peak power / root 2.
    ///
    @objc public init(
        _ input: AKNode? = nil,
        halfPowerPoint: Double = 1_000.0) {

        self.halfPowerPoint = halfPowerPoint

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self!)
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        halfPowerPointParameter = tree["halfPowerPoint"]

        token = tree.token(byAddingParameterObserver: { [weak self] _, _ in

            guard let _ = self else {
                AKLog("Unable to create strong reference to self")
                return
            } // Replace _ with strongSelf if needed
            DispatchQueue.main.async {
                // This node does not change its own values so we won't add any
                // value observing, but if you need to, this is where that goes.
            }
        })

        internalAU?.halfPowerPoint = Float(halfPowerPoint)
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
