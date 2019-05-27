//
//  AKWaveTable.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// An alternative to AKSampler or AKAudioPlayer, AKWaveTable is a player that
/// doesn't rely on an as much Apple AV foundation/engine code as the others.
/// As any other Sampler, it plays a part of a given sound file at a specified rate
/// with specified volume. Changing the rate plays it faster and therefore sounds
/// higher or lower. Set rate to 2.0 to double playback speed and create an octave.
/// Give it a blast on `Sample Player.xcplaygroundpage`
import Foundation

/// Audio player that loads a sample into memory
open class AKWaveTable: AKNode, AKComponent {

    public typealias AKAudioUnitType = AKWaveTableAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "smpl")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?

    fileprivate var startPointParameter: AUParameter?
    fileprivate var endPointParameter: AUParameter?
    fileprivate var loopStartPointParameter: AUParameter?
    fileprivate var loopEndPointParameter: AUParameter?
    fileprivate var rateParameter: AUParameter?
    fileprivate var volumeParameter: AUParameter?

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// startPoint in samples - where to start playing the sample from
    @objc open dynamic var startPoint: Sample = 0 {
        willSet {
            guard startPoint != newValue else { return }
            internalAU?.startPoint = Float(safeSample(newValue))
        }
    }

    /// endPoint - this is where the sample will play to before stopping.
    /// A value less than the start point will play the sample backwards.
    @objc open dynamic var endPoint: Sample = 0 {
        willSet {
            guard endPoint != newValue else { return }
            internalAU?.endPoint = Float(safeSample(newValue))
        }
    }

    /// loopStartPoint in samples - where to start playing the sample from
    @objc open dynamic var loopStartPoint: Sample = 0 {
        willSet {
            guard loopStartPoint != newValue else { return }
            internalAU?.loopStartPoint = Float(safeSample(newValue))
        }
    }

    /// loopEndPoint - this is where the sample will play to before stopping.
    @objc open dynamic var loopEndPoint: Sample = 0 {
        willSet {
            guard endPoint != newValue else { return }
            internalAU?.loopEndPoint = Float(safeSample(newValue))
        }
    }

    /// playback rate - A value of 1 is normal, 2 is double speed, 0.5 is halfspeed, etc.
    @objc open dynamic var rate: Double = 1 {
        willSet {
            guard rate != newValue else { return }
            if internalAU?.isSetUp == true {
                rateParameter?.value = AUValue(newValue)
            } else {
                internalAU?.rate = Float(newValue)
            }
        }
    }

    /// Volume - amplitude adjustment
    @objc open dynamic var volume: Double = 1 {
        willSet {
            guard volume != newValue else { return }
            if internalAU?.isSetUp == true {
                volumeParameter?.value = AUValue(newValue)
            } else {
                internalAU?.volume = AUValue(newValue)
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
        if avAudiofile != nil {
            return Sample(avAudiofile!.samplesCount)
        }
        return Sample(maximumSamples)
    }

    /// originalSampleRate
    open var originalSampleRate: Double? {
        return avAudiofile?.sampleRate
    }

    /// Position in the audio file from 0 - 1
    open var normalizedPosition: Double {
        guard let internalAU = internalAU else { return 0 }
        return Double(internalAU.position())
    }

    /// Position in the audio in samples, but represented as a double since
    /// you could conceivably be at a non-integer sample
    open var position: Double {
        return normalizedPosition * Double(size)
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    fileprivate var avAudiofile: AVAudioFile?
    fileprivate var maximumSamples: Int = 0

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
    open var loopCallback: AKCallback = {} {
        willSet {
            internalAU?.loopCallback = newValue
        }
    }

    // MARK: - Initialization

    /// Initialize this SamplePlayer node
    ///
    /// - Parameters:
    ///   - file: Initial file to load (defining maximum size unless maximum samples are also set
    ///   - startPoint: Point in samples from which to start playback
    ///   - endPoint: Point in samples at which to stop playback
    ///   - rate: Multiplication factor from original speed (Default: 1)
    ///   - volume: Multiplication factor of the overall amplitude (Default: 1)
    ///   - maximumSamples: Largest number of samples that will be loaded into the sample player
    ///   - completionHandler: Callback to run when the sample playback is completed
    ///
    @objc public init(file: AKAudioFile? = nil,
                      startPoint: Sample = 0,
                      endPoint: Sample = 0,
                      rate: Double = 1,
                      volume: Double = 1,
                      maximumSamples: Int = 0,
                      completionHandler: @escaping AKCCallback = {},
                      loadCompletionHandler: @escaping AKCCallback = {}) {

        self.startPoint = startPoint
        self.rate = rate
        self.volume = volume
        self.endPoint = endPoint
        if file != nil {
            self.avAudiofile = file!
            self.endPoint = Sample(avAudiofile!.samplesCount)
        }
        self.maximumSamples = maximumSamples
        self.completionHandler = completionHandler
        self.loadCompletionHandler = loadCompletionHandler

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
            strongSelf.internalAU!.completionHandler = completionHandler
            strongSelf.internalAU!.loadCompletionHandler = loadCompletionHandler
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        startPointParameter = tree["startPoint"]
        endPointParameter = tree["endPoint"]
        loopStartPointParameter = tree["startPoint"]
        loopEndPointParameter = tree["endPoint"]
        rateParameter = tree["rate"]
        volumeParameter = tree["volume"]
        internalAU?.startPoint = Float(startPoint)
        internalAU?.endPoint = Float(self.endPoint)
        internalAU?.loopStartPoint = Float(startPoint)
        internalAU?.loopEndPoint = Float(self.endPoint)
        internalAU?.rate = Float(rate)
        internalAU?.volume = Float(volume)

        if maximumSamples != 0 {
            internalAU?.setupAudioFileTable(UInt32(maximumSamples) * 2)
        }
        if file != nil {
            load(file: file!)
        }
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        internalAU?.startPoint = Float(safeSample(startPoint))
        internalAU?.endPoint = Float(safeSample(endPoint))
        internalAU?.loopStartPoint = Float(safeSample(loopStartPoint))
        internalAU?.loopEndPoint = Float(safeSample(loopEndPoint))
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        internalAU?.stop()
    }

    /// Play from a certain sample
    open func play() {
        start()
    }

    /// Play from a certain sample
    open func play(from: Sample) {
        internalAU?.tempStartPoint = Float(safeSample(from))
        start()
    }

    /// Play from a certain sample for a certain number of samples
    open func play(from: Sample, length: Sample) {
        internalAU?.tempStartPoint = Float(safeSample(from))
        internalAU?.tempEndPoint = Float(safeSample(from + length))
        start()
    }

    /// Play from a certain sample to an end sample
    open func play(from: Sample, to: Sample) {
        internalAU?.tempStartPoint = Float(safeSample(from))
        internalAU?.tempEndPoint = Float(safeSample(to))
        start()
    }

    func safeSample(_ point: Sample) -> Sample {
        if point > size { return size }
        // if point < 0 { return 0 } doesn't work cause we're using uint32 for sample
        return point
    }

    /// Load a new audio file into memory
    open func load(file: AKAudioFile) {
        if file.channelCount > 2 || file.channelCount < 1 {
            AKLog("AKWaveTable currently only supports mono or stereo samples")
            return
        }
        if let buf = AVAudioPCMBuffer(pcmFormat: file.processingFormat,
                                      frameCapacity: AVAudioFrameCount(file.length)) {
            do {
                file.framePosition = 0
                try file.read(into: buf)
            } catch {
                AKLog("Load audio file failed. Error was: \(error)")
                return
            }
            let sizeToUse = UInt32(file.samplesCount * 2)
            if maximumSamples == 0 {
                maximumSamples = Int(file.samplesCount)
                internalAU?.setupAudioFileTable(sizeToUse)
            }
            avAudiofile = file
            startPoint = 0
            endPoint = Sample(file.samplesCount)
            loopStartPoint = 0
            loopEndPoint = Sample(file.samplesCount)
            let data = buf.floatChannelData
            internalAU?.loadAudioData(data?.pointee, size: UInt32(file.samplesCount) * file.channelCount,
                                      sampleRate: Float(file.sampleRate), numChannels: file.channelCount)
        }
    }

    deinit {
        internalAU?.destroy()
    }
}
