//
//  AKAmplitudeTracker.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

public typealias AKThresholdCallback = @convention(block) (Bool) -> Void

/// Performs a "root-mean-square" on a signal to get overall amplitude of a
/// signal. The output signal looks similar to that of a classic VU meter.
///
open class AKAmplitudeTracker: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKAmplitudeTrackerAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "rmsq")

    // MARK: - Properties

    internal var internalAU: AKAudioUnitType?

    fileprivate var halfPowerPointParameter: AUParameter?
    //    open var smoothness: Double = 1 { // should be 0 and above
    //        willSet {
    //            internalAU?.smoothness = 0.05 * AUValue(newValue)
    //        }
    //    } //in development

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    /// Detected amplitude
    @objc open dynamic var amplitude: Double {
        return (leftAmplitude + rightAmplitude) / 2.0
    }

    /// Detected amplitude
    @objc open dynamic var leftAmplitude: Double {
        return Double(internalAU?.leftAmplitude ?? 0)
    }

    /// Detected right amplitude
    @objc open dynamic var rightAmplitude: Double {
        return Double(internalAU?.rightAmplitude ?? 0)
    }

    /// Threshold amplitude
    @objc open dynamic var threshold: Double = 1 {
        willSet {
            internalAU?.threshold = AUValue(newValue)
        }
    }

    /// Mode
    /// - rms (default): takes the root mean squared of the signal
    /// - maxRMS: takes the root mean squared of the signal, then uses the max RMS found per buffer
    /// - peak: takes the peak signal from a buffer and uses that as an output
    open var mode: AmplitudeTrackingMode = .rms {
        didSet {
            internalAU?.mode = mode.rawValue
        }
    }

    // MARK: - Initialization

    /// Initialize this amplitude tracker node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - halfPowerPoint: Half-power point (in Hz) of internal lowpass filter.
    ///   - threshold: point at which the callback is called
    ///   - thresholdCallback: function to execute when the threshold is reached
    ///
    @objc public init(
        _ input: AKNode? = nil,
        halfPowerPoint: Double = 10,
        threshold: Double = 1,
        thresholdCallback: @escaping AKThresholdCallback = { _ in }) {

        self.threshold = threshold

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
            strongSelf.internalAU?.thresholdCallback = thresholdCallback

            if let au = strongSelf.internalAU {
                au.setHalfPowerPoint(Float(halfPowerPoint))
            }
            input?.connect(to: strongSelf)
        }
    }

    deinit {
        AKLog("* AKAmplitudeTracker")
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

public enum AmplitudeTrackingMode: Int32 {
    case rms = 0
    case maxRMS = 1
    case peak = 2
}
