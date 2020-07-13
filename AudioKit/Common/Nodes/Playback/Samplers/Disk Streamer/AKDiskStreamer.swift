// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// An alternative to AKSampler or AKAudioPlayer, AKDiskStreamer is a player that
/// will playback samples from disk, without incurring lots of memory usage

import Foundation

/// Audio player that loads a sample into memory
open class AKDiskStreamer: AKNode, AKComponent {
    public typealias AKAudioUnitType = AKDiskStreamerAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "akds")

    // MARK: - Properties

    public private(set) var internalAU: AKAudioUnitType?

    fileprivate var volumeParameter: AUParameter?

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// startPoint in samples - where to start playing the sample from
    private var startPoint: Sample = 0

    /// endPoint - this is where the sample will play to before stopping.
    private var endPoint: Sample {
        return Sample(avAudiofile?.length ?? 0)
    }

    /// playback rate - A value of 1 is normal, 2 is double speed, 0.5 is halfspeed, etc.

    @objc open dynamic var rate: AUValue {
        set { internalAU?.setRate(newValue) }
        get { return internalAU?.getRate() ?? 0 }
    }

    /// Volume - amplitude adjustment
    @objc open dynamic var volume: AUValue = 1 {
        willSet {
            guard volume != newValue else { return }
            if internalAU?.isSetUp == true {
                volumeParameter?.value = newValue
            } else {
                internalAU?.volume = newValue
            }
        }
    }

    /// Loop Enabled - if enabled, the sample will loop back to the startpoint when the endpoint is reached.
    /// When disabled, the sample will play through once from startPoint to endPoint
    @objc open dynamic var loopEnabled: Bool = false {
        willSet {
            internalAU?.loop = newValue
        }
    }

    /// Number of samples in the audio stored in memory
    open var size: Sample {
        if let file = avAudiofile {
            return Sample(file.length)
        }
        return 0
    }

    /// originalSampleRate
    open var originalSampleRate: Double? {
        return avAudiofile?.fileFormat.sampleRate
    }

    /// Position in the audio file from 0 - 1
    open var normalizedPosition: AUValue {
        guard let internalAU = internalAU else { return 0 }
        return internalAU.position()
    }

    /// Position in the audio in samples, but represented as a double since
    /// you could conceivably be at a non-integer sample
    open var position: AUValue {
        return normalizedPosition * AUValue(size)
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    fileprivate var avAudiofile: AVAudioFile?

    open var loadCompletionHandler: AKCallback = {} {
        willSet {
            internalAU?.loadCompletionHandler = newValue
        }
    }

    open var completionHandler: AKCallback = {} {
        willSet {
            internalAU?.completionHandler = newValue
        }
    }

    open var loadedFile: AVAudioFile?

    // MARK: - Initialization

    /// Initialize this SamplePlayer node
    ///
    /// - Parameters:
    ///   - volume: Multiplication factor of the overall amplitude (Default: 1)
    ///   - completionHandler: Callback to run when the sample playback is completed
    ///   - loadCompletionHandler: Callback to run when the sample is loaded
    ///
    @objc public init(volume: AUValue = 1,
                      completionHandler: @escaping AKCCallback = {},
                      loadCompletionHandler: @escaping AKCCallback = {}) {
        self.volume = volume
        self.completionHandler = completionHandler
        self.loadCompletionHandler = loadCompletionHandler

        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.internalAU?.completionHandler = completionHandler
            self.internalAU?.loadCompletionHandler = loadCompletionHandler
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        volumeParameter = tree["volume"]

        internalAU?.volume = volume
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        internalAU?.startPoint = Float(safeSample(startPoint))
        internalAU?.endPoint = Float(safeSample(endPoint))
        internalAU?.loopStartPoint = Float(safeSample(startPoint))
        internalAU?.loopEndPoint = Float(safeSample(endPoint))
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        internalAU?.stop()
    }

    /// Play from a certain sample
    open func play() {
        start()
    }

    func safeSample(_ point: Sample) -> Sample {
        if point > size { return size }
        // if point < 0 { return 0 } doesn't work cause we're using uint32 for sample
        return point
    }

    /// Load a new audio file into memory - this must be done after audiokit starts
    open func load(file: AVAudioFile) {
        if file.fileFormat.channelCount > 2 || file.fileFormat.channelCount < 1 {
            AKLog("AKDiskStreamer currently only supports mono or stereo samples")
            return
        }
        startPoint = 0
        avAudiofile = file
        internalAU?.endPoint = Float(safeSample(endPoint))
        internalAU?.loopStartPoint = Float(safeSample(startPoint))
        internalAU?.loopEndPoint = Float(safeSample(endPoint))
        internalAU?.loadFile(file.url.path)
        loadedFile = file
    }

    open func rewind() {
        internalAU?.rewind()
    }

    open func seek(to sample: AUValue) {
        internalAU?.seek(to: sample)
    }
}
