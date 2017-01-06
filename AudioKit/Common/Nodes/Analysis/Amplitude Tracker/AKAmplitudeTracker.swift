//
//  AKAmplitudeTracker.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Performs a "root-mean-square" on a signal to get overall amplitude of a
/// signal. The output signal looks similar to that of a classic VU meter.
///
open class AKAmplitudeTracker: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKAmplitudeTrackerAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "rmsq")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var halfPowerPointParameter: AUParameter?

    /// Half-power point (in Hz) of internal lowpass filter.
    open var halfPowerPoint: Double = 10 {
        willSet {
            if halfPowerPoint != newValue {
                halfPowerPointParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    /// Detected amplitude
    open var amplitude: Double {
        return Double(self.internalAU!.amplitude) / sqrt(2.0) * 2.0
    }

    // MARK: - Initialization

    /// Initialize this amplitude tracker node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - halfPowerPoint: Half-power point (in Hz) of internal lowpass filter.
    ///
    public init(
        _ input: AKNode,
        halfPowerPoint: Double = 10) {

        self.halfPowerPoint = halfPowerPoint

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) {
            avAudioUnit in

            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        halfPowerPointParameter = tree["halfPowerPoint"]

        token = tree.token (byAddingParameterObserver: {
            address, value in

            DispatchQueue.main.async {
                if address == self.halfPowerPointParameter!.address {
                    self.halfPowerPoint = Double(value)
                }
            }
        })
        halfPowerPointParameter?.setValue(Float(halfPowerPoint), originator: token!)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        internalAU!.stop()
    }
}
