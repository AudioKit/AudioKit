//
//  AKSamplePlayer.swift
//  AudioKit For iOS
//
//  Created by Jeff Cooper on 5/20/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Foundation

public typealias Sample = UInt32

open class AKSamplePlayer: AKNode, AKComponent {
    public typealias AKAudioUnitType = AKSamplePlayerAudioUnit
    public static let ComponentDescription = AudioComponentDescription(generator: "smpl")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var startPointParameter: AUParameter?
    fileprivate var endPointParameter: AUParameter?
    fileprivate var rateParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// startPoint in time. When non-changing it will do a spectral freeze of a the current point in time.
    open dynamic var startPoint: Sample = 0 {
        willSet {
            if startPoint != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        startPointParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.startPoint = Float(newValue)
                }
            }
        }
    }

    /// endPoint.
    open dynamic var endPoint: Sample = 0 {
        willSet {
            if endPoint != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        endPointParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.endPoint = Float(newValue)
                }
            }
        }
    }

    /// Pitch ratio. A value of 1 is normal, 2 is double speed, 0.5 is halfspeed, etc.
    open dynamic var rate: Double = 1 {
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

    /// Loop Enabled
    open dynamic var loopEnabled: Bool = false {
        willSet {
            internalAU?.loop = newValue
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
    }

    fileprivate var avAudiofile: AVAudioFile

    // MARK: - Initialization

    /// Initialize this SamplePlayer node
    ///
    public init(
        file: AVAudioFile,
        startPoint: Sample = 0,
        endPoint: Sample = 0,
        rate: Double = 1) {

        self.startPoint = startPoint
        self.endPoint = endPoint
        self.rate = rate
        self.avAudiofile = file

        _Self.register()

        super.init()

        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
        }

        guard let tree = internalAU?.parameterTree else {
            return
        }

        startPointParameter = tree["startPoint"]
        endPointParameter = tree["endPoint"]
        rateParameter = tree["rate"]

        token = tree.token(byAddingParameterObserver: { [weak self] address, value in

            DispatchQueue.main.async {
                if address == self?.startPointParameter?.address {
                    self?.startPoint = Sample(value)
                } else if address == self?.endPointParameter?.address {
                    self?.endPoint = Sample(value)
                } else if address == self?.rateParameter?.address {
                    self?.rate = Double(value)
                }
            }
        })
        internalAU?.startPoint = Float(startPoint)
        internalAU?.endPoint = Float(endPoint)
        internalAU?.rate = Float(rate)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        Exit: do {
            var err: OSStatus = noErr
            var theFileLengthInFrames: Int64 = 0
            var theFileFormat: AudioStreamBasicDescription = AudioStreamBasicDescription()
            var thePropertySize: UInt32 = UInt32(MemoryLayout.stride(ofValue: theFileFormat))
            var extRef: ExtAudioFileRef?
            var theData: UnsafeMutablePointer<CChar>?
            var theOutputFormat: AudioStreamBasicDescription = AudioStreamBasicDescription()

            err = ExtAudioFileOpenURL(self.avAudiofile.url as CFURL, &extRef)
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
            theOutputFormat.mChannelsPerFrame = 1 // Mono
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
                    internalAU?.setupAudioFileTable(data, size: ioNumberFrames)
                    internalAU?.start()
                } else {
                    // failure
                    theData?.deallocate(capacity: Int(dataSize))
                    theData = nil // make sure to return NULL
                    AKLog("Error = \(err)"); break Exit
                }
            }
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        internalAU?.stop()
    }

    /// Play from a certain sample
    open func play(from: Sample = 0) {
        startPoint = from
        start()
    }
    
    open func play(from: Sample = 0, length: Sample = 0) {
        startPoint = from
        endPoint = startPoint + length
        start()
    }
    
    open func play(from: Sample = 0, to: Sample = 0) {
        startPoint = from
        endPoint = to
        start()
    }
}
