//
//  AKAmplitudeTracker.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Performs a "root-mean-square" on a signal to get overall amplitude of a
/// signal. The output signal looks similar to that of a classic VU meter.
///
open class AKAmplitudeTracker: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKAmplitudeTrackerAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "rmsq")

    // MARK: - Properties
    internal var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var halfPowerPointParameter: AUParameter?

    /// Half-power point (in Hz) of internal lowpass filter.
    open dynamic var halfPowerPoint: Double = 10 {
        willSet {
            if halfPowerPoint != newValue {
                if let existingToken = token {
                    halfPowerPointParameter?.setValue(Float(newValue), originator: existingToken)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
    }

    /// Detected amplitude
    open dynamic var amplitude: Double {
        if let amp = internalAU?.amplitude {
            return Double(amp) / sqrt(2.0) * 2.0
        } else {
            return 0.0
        }
    }

    // MARK: - Initialization

    /// Initialize this amplitude tracker node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - halfPowerPoint: Half-power point (in Hz) of internal lowpass filter.
    ///
    public init(
        _ input: AKNode?,
        halfPowerPoint: Double = 10) {

        self.halfPowerPoint = halfPowerPoint

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

        halfPowerPointParameter = tree["halfPowerPoint"]

        token = tree.token (byAddingParameterObserver: { [weak self] address, value in

            DispatchQueue.main.async {
                if address == self?.halfPowerPointParameter?.address {
                    self?.halfPowerPoint = Double(value)
                }
            }
        })
        if let existingToken = token {
            halfPowerPointParameter?.setValue(Float(halfPowerPoint), originator: existingToken)
        }
    }

    deinit {
        AKLog("* AKAmplitudeTracker")
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
