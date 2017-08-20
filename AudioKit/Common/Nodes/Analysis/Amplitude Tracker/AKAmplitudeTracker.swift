//
//  AKAmplitudeTracker.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

public typealias AKThresholdCallback = @convention(block) (Bool) -> Void

/// Performs a "root-mean-square" on a signal to get overall amplitude of a
/// signal. The output signal looks similar to that of a classic VU meter.
///
open class AKAmplitudeTracker: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKAmplitudeTrackerAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "rmsq")

    // MARK: - Properties
    internal var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var halfPowerPointParameter: AUParameter?
//    open var smoothness: Double = 1 { // should be 0 and above
//        willSet {
//            internalAU?.smoothness = 0.05 * Float(newValue)
//        }
//    } //in development

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

    /// Threshold amplitude
    open dynamic var threshold: Double = 1 {
        willSet {
            internalAU?.threshold = Float(newValue)
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
        halfPowerPoint: Double = 10,
        threshold: Double = 1,
        thresholdCallback: @escaping AKThresholdCallback = { _ in }) {

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self!.internalAU!.thresholdCallback = thresholdCallback

            if let au = self?.internalAU {
                au.setHalfPowerPoint(Float(halfPowerPoint))
            }

            input?.addConnectionPoint(self!)
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
