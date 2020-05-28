// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// This is based on an algorithm originally created by Miller Puckette.
///
open class AKFrequencyTracker: AKNode, AKToggleable, AKComponent, AKInput {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "ptrk")

    public typealias AKAudioUnitType = AKFrequencyTrackerAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - Parameters

    /// Detected Amplitude (Use AKAmplitude tracker if you don't need frequency)
    @objc open dynamic var amplitude: Double {
        return Double(internalAU?.amplitude ?? 0) / Double(AKSettings.channelCount)
    }

    /// Detected frequency
    @objc open dynamic var frequency: Double {
        return Double(internalAU?.frequency ?? 0) * Double(AKSettings.channelCount)
    }

    // MARK: - Initialization

    /// Initialize this Pitch-tracker node
    ///
    /// - parameter input: Input node to process
    /// - parameter hopSize: Hop size.
    /// - parameter peakCount: Number of peaks.
    ///
    public init(
        _ input: AKNode? = nil,
        hopSize: Int = 4_096,
        peakCount: Int = 20
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input?.connect(to: self)

            self.internalAU?.setPeakCount(UInt32(peakCount))
            self.internalAU?.setHopSize(UInt32(hopSize))
        }
    }
}
