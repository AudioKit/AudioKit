//
//  AKSamplePlayer.swift
//  AudioKit
//
//  Created by Jeff Cooper on 5/20/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Foundation

/// A Sample type, just a UInt32
public typealias Sample = UInt32

/// Callback function that can be called from C
public typealias AKCCallback = @convention(block) () -> Void

/// Audio player that loads a sample into memory
open class AKSamplePlayer: AKNode, AKComponent {

    public typealias AKAudioUnitType = AKSamplePlayerAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "smpl")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var startPointParameter: AUParameter?
    fileprivate var endPointParameter: AUParameter?
    fileprivate var loopStartPointParameter: AUParameter?
    fileprivate var loopEndPointParameter: AUParameter?
    fileprivate var rateParameter: AUParameter?
    fileprivate var volumeParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    @objc open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// startPoint in samples - where to start playing the sample from
    @objc open dynamic var startPoint: Sample = 0 {
        willSet {
            if startPoint != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        startPointParameter?.setValue(Float(safeSample(newValue)), originator: existingToken)
                    }
                } else {
                    internalAU?.startPoint = Float(safeSample(newValue))
                }
            }
        }
    }

    /// endPoint - this is where the sample will play to before stopping.
    /// A value less than the start point will play the sample backwards.
    @objc open dynamic var endPoint: Sample = 0 {
        willSet {
            if endPoint != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        endPointParameter?.setValue(Float(safeSample(newValue)), originator: existingToken)
                    }
                } else {
                    internalAU?.endPoint = Float(safeSample(newValue))
                }
            }
        }
    }

    /// loopStartPoint in samples - where to start playing the sample from
    @objc open dynamic var loopStartPoint: Sample = 0 {
        willSet {
            if loopStartPoint != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        loopStartPointParameter?.setValue(Float(safeSample(newValue)), originator: existingToken)
                    }
                } else {
                    internalAU?.loopStartPoint = Float(safeSample(newValue))
                }
            }
        }
    }

    /// loopEndPoint - this is where the sample will play to before stopping.
    @objc open dynamic var loopEndPoint: Sample = 0 {
        willSet {
            if endPoint != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        loopEndPointParameter?.setValue(Float(safeSample(newValue)), originator: existingToken)
                    }
                } else {
                    internalAU?.loopEndPoint = Float(safeSample(newValue))
                }
            }
        }
    }

    /// playback rate - A value of 1 is normal, 2 is double speed, 0.5 is halfspeed, etc.
    @objc open dynamic var rate: Double = 1 {
        willSet {
            if rate != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        rateParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.rate = Float(newValue)
                }
            }
        }
    }

    /// Volume - amplitude adjustment
    @objc open dynamic var volume: Double = 1 {
        willSet {
            if volume != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        volumeParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.volume = Float(newValue)
                }
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
        return Sample(avAudiofile.samplesCount)
    }

    /// Position in the audio file from 0 - 1
    open var normalizedPosition: Double {
        return Double(internalAU!.position())
    }

    /// Position in the audio in samples, but represented as a double since
    /// you could conceivably be at a non-integer sample
    open var position: Double {
        return normalizedPosition * Double(size)
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
    }

    fileprivate var avAudiofile: AVAudioFile
    fileprivate var maximumSamples: Int = 0

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
    public init(file: AVAudioFile,
                startPoint: Sample = 0,
                endPoint: Sample = 0,
                rate: Double = 1,
                volume: Double = 1,
                maximumSamples: Int = 0,
                completionHandler: @escaping AKCCallback = { }) {

        self.startPoint = startPoint
        self.rate = rate
        self.volume = volume
        self.avAudiofile = file
        self.endPoint = Sample(avAudiofile.samplesCount)
        self.maximumSamples = maximumSamples

        _Self.register()

        super.init()

        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self!.internalAU!.completionHandler = completionHandler
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

        token = tree.token(byAddingParameterObserver: { [weak self] _, _ in

            guard let _ = self else {
                AKLog("Unable to create strong reference to self")
                return
            } // Replace _ with strongSelf if needed
            DispatchQueue.main.async {
                // This node does not change its own values so we won't add any
                // value observing, but if you need to, this is where that goes.
            }
        })
        internalAU?.startPoint = Float(startPoint)
        internalAU?.endPoint = Float(self.endPoint)
        internalAU?.loopStartPoint = Float(startPoint)
        internalAU?.loopEndPoint = Float(self.endPoint)
        internalAU?.rate = Float(rate)
        internalAU?.volume = Float(volume)

        if maximumSamples != 0 {
            internalAU?.setupAudioFileTable(UInt32(maximumSamples) * 2)
        }
        load(file: self.avAudiofile)
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
    open func play(from: Sample = 0) {
        startPoint = from
        start()
    }

    /// Play from a certain sample for a certain number of samples
    open func play(from: Sample = 0, length: Sample = 0) {
        startPoint = from
        endPoint = startPoint + length
        start()
    }

    /// Play from a certain sample to an end sample
    open func play(from: Sample = 0, to: Sample = 0) {
        startPoint = from
        endPoint = to
        start()
    }

    func safeSample(_ point: Sample) -> Sample {
        if point > size { return size }
        //if point < 0 { return 0 } doesnt work cause we're using uint32 for sample
        return point
    }

    /// Load a new audio file into memory
    open func loadSound(file: AVAudioFile) {
        load(file: file)
    }

    func load(file: AVAudioFile) {
        Exit: do {
            var err: OSStatus = noErr
            var theFileLengthInFrames: Int64 = 0
            var theFileFormat: AudioStreamBasicDescription = AudioStreamBasicDescription()
            var thePropertySize: UInt32 = UInt32(MemoryLayout.stride(ofValue: theFileFormat))
            var extRef: ExtAudioFileRef?
            var theData: UnsafeMutablePointer<CChar>?
            var theOutputFormat: AudioStreamBasicDescription = AudioStreamBasicDescription()
            err = ExtAudioFileOpenURL(file.url as CFURL, &extRef)
            if err != 0 { AKLog("ExtAudioFileOpenURL FAILED, Error = \(err)"); break Exit }
            // Get the audio data format
            guard let externalAudioFileRef = extRef else {
                break Exit
            }
            err = ExtAudioFileGetProperty(externalAudioFileRef,
                                          kExtAudioFileProperty_FileDataFormat,
                                          &thePropertySize,
                                          &theFileFormat)
            if err != 0 {
                AKLog("ExtAudioFileGetProperty(kExtAudioFileProperty_FileDataFormat) FAILED, Error = \(err)")
                break Exit
            }
            if theFileFormat.mChannelsPerFrame > 2 {
                AKLog("Unsupported Format, channel count is greater than stereo")
                break Exit
            }

            theOutputFormat.mSampleRate = AKSettings.sampleRate
            theOutputFormat.mFormatID = kAudioFormatLinearPCM
            theOutputFormat.mFormatFlags = kLinearPCMFormatFlagIsFloat
            theOutputFormat.mBitsPerChannel = UInt32(MemoryLayout<Float>.stride) * 8
            theOutputFormat.mChannelsPerFrame = 2
            theOutputFormat.mBytesPerFrame = theOutputFormat.mChannelsPerFrame * UInt32(MemoryLayout<Float>.stride)
            theOutputFormat.mFramesPerPacket = 1
            theOutputFormat.mBytesPerPacket = theOutputFormat.mFramesPerPacket * theOutputFormat.mBytesPerFrame

            // Set the desired client (output) data format
            err = ExtAudioFileSetProperty(externalAudioFileRef,
                                          kExtAudioFileProperty_ClientDataFormat,
                                          UInt32(MemoryLayout.stride(ofValue: theOutputFormat)),
                                          &theOutputFormat)
            if err != 0 {
                AKLog("ExtAudioFileSetProperty(kExtAudioFileProperty_ClientDataFormat) FAILED, Error = \(err)")
                break Exit
            }

            // Get the total frame count
            thePropertySize = UInt32(MemoryLayout.stride(ofValue: theFileLengthInFrames))
            err = ExtAudioFileGetProperty(externalAudioFileRef,
                                          kExtAudioFileProperty_FileLengthFrames,
                                          &thePropertySize,
                                          &theFileLengthInFrames)
            if err != 0 {
                AKLog("ExtAudioFileGetProperty(kExtAudioFileProperty_FileLengthFrames) FAILED, Error = \(err)")
                break Exit
            }

            // Read all the data into memory
            let dataSize = UInt32(theFileLengthInFrames) * theOutputFormat.mBytesPerFrame
            theData = UnsafeMutablePointer.allocate(capacity: Int(dataSize))
            if theData != nil {
                var bufferList: AudioBufferList = AudioBufferList()
                bufferList.mNumberBuffers = 1
                bufferList.mBuffers.mDataByteSize = dataSize
                bufferList.mBuffers.mNumberChannels = theOutputFormat.mChannelsPerFrame
                bufferList.mBuffers.mData = UnsafeMutableRawPointer(theData)

                // Read the data into an AudioBufferList
                var ioNumberFrames: UInt32 = UInt32(theFileLengthInFrames)
                err = ExtAudioFileRead(externalAudioFileRef, &ioNumberFrames, &bufferList)
                if err == noErr {
                    // success
                    let data = UnsafeMutablePointer<Float>(
                        bufferList.mBuffers.mData?.assumingMemoryBound(to: Float.self)
                    )

                    if maximumSamples == 0 {
                        maximumSamples = Int(ioNumberFrames * 2)
                        internalAU?.setupAudioFileTable(UInt32(maximumSamples) * 2)
                    }
                    internalAU?.loadAudioData(data, size: ioNumberFrames * 2)

                    self.avAudiofile = file
                    self.startPoint = 0
                    self.endPoint = Sample(file.samplesCount)
                    self.loopStartPoint = 0
                    self.loopEndPoint = Sample(file.samplesCount)
                } else {
                    // failure
                    AKLog("Error = \(err)"); break Exit
                }
            }
            theData?.deallocate(capacity: Int(dataSize))
            theData = nil // make sure to return NULL
            ExtAudioFileDispose(externalAudioFileRef)
            ExtAudioFileDispose(extRef!)
        }
    }
}
