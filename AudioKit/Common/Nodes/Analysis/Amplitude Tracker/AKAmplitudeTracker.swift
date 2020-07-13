// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public typealias AKThresholdCallback = @convention(block) (Bool) -> Void

/// Performs a "root-mean-square" on a signal to get overall amplitude of a
/// signal. The output signal looks similar to that of a classic VU meter.
///
open class AKAmplitudeTracker: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKAmplitudeTrackerAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "rmsq")

    // MARK: - Properties

    public private(set) var internalAU: AKAudioUnitType?

    fileprivate var halfPowerPointParameter: AUParameter?
    //    open var smoothness: AUValue = 1 { // should be 0 and above
    //        willSet {
    //            internalAU?.smoothness = 0.05 * newValue
    //        }
    //    } //in development

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    /// Detected amplitude
    @objc open dynamic var amplitude: AUValue {
        return (leftAmplitude + rightAmplitude) / 2.0
    }

    /// Detected amplitude
    @objc open dynamic var leftAmplitude: AUValue {
        return internalAU?.leftAmplitude ?? 0
    }

    /// Detected right amplitude
    @objc open dynamic var rightAmplitude: AUValue {
        return internalAU?.rightAmplitude ?? 0
    }

    /// Threshold amplitude
    @objc open dynamic var threshold: AUValue = 1 {
        willSet {
            internalAU?.threshold = newValue
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
        halfPowerPoint: AUValue = 10,
        threshold: AUValue = 1,
        thresholdCallback: @escaping AKThresholdCallback = { _ in }) {

        self.threshold = threshold

        super.init(avAudioNode: AVAudioNode())
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.internalAU?.thresholdCallback = thresholdCallback

            if let au = self.internalAU {
                au.setHalfPowerPoint(halfPowerPoint)
            }
            input?.connect(to: self)
        }
    }

    deinit {
        AKLog("* AKAmplitudeTracker")
    }

}

public enum AmplitudeTrackingMode: Int32 {
    case rms = 0
    case maxRMS = 1
    case peak = 2
}
