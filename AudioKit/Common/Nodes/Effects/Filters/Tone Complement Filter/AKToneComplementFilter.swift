//
//  AKToneComplementFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// A complement to the AKLowPassFilter.
///
open class AKToneComplementFilter: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKToneComplementFilterAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "aton")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var halfPowerPointParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Half-Power Point in Hertz. Half power is defined as peak power / square root of 2.
    open var halfPowerPoint: Double = 1_000.0 {
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
    open var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - halfPowerPoint: Half-Power Point in Hertz. Half power is defined as peak power / square root of 2.
    ///
    public init(
        _ input: AKNode,
        halfPowerPoint: Double = 1_000.0) {

        self.halfPowerPoint = halfPowerPoint

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input.addConnectionPoint(self!)
        }

                guard let tree = internalAU?.parameterTree else {
            return
        }

        halfPowerPointParameter = tree["halfPowerPoint"]

        token = tree.token (byAddingParameterObserver: { [weak self] address, value in

            DispatchQueue.main.async {
                if address == self?.halfPowerPointParameter?.address {
                    self?.halfPowerPoint = Double(value)
                }
            }
        })

        internalAU?.halfPowerPoint = Float(halfPowerPoint)
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
