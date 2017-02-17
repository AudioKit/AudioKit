//
//  AKPanner.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Stereo Panner
///
open class AKPanner: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKPannerAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "pan2")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var panParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Panning. A value of -1 is hard left, and a value of 1 is hard right, and 0 is center.
    open var pan: Double = 0 {
        willSet {
            if pan != newValue {
                if internalAU!.isSetUp() {
                    panParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.pan = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this panner node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - pan: Panning. A value of -1 is hard left, and a value of 1 is hard right, and 0 is center.
    ///
    public init(
        _ input: AKNode,
        pan: Double = 0) {

        self.pan = pan

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

        panParameter = tree["pan"]

        token = tree.token (byAddingParameterObserver: { [weak self] address, value in

            DispatchQueue.main.async {
                if address == self?.panParameter!.address {
                    self?.pan = Double(value)
                }
            }
        })
        internalAU?.pan = Float(pan)
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
