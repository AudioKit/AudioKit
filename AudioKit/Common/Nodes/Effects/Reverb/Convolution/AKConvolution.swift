//
//  AKConvolution.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// This module will perform partitioned convolution on an input signal using an
/// audio file as an impulse response.
///
open class AKConvolution: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKConvolutionAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "conv")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    fileprivate var impulseResponseFileURL: CFURL
    fileprivate var partitionLength: Int = 2_048

    // MARK: - Initialization

    /// Initialize this convolution node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - impulseResponseFileURL: Location of the imulseResponse audio File
    ///   - partitionLength: Partition length (in samples). Must be a power of 2. Lower values will add less latency,
    ///                      at the cost of requiring more CPU power.
    ///
    @objc public init(_ input: AKNode? = nil,
                      impulseResponseFileURL: URL,
                      partitionLength: Int = 2_048) {

        self.impulseResponseFileURL = impulseResponseFileURL as CFURL
        self.partitionLength = partitionLength

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
            input?.connect(to: strongSelf)
            strongSelf.internalAU?.setPartitionLength(Int32(partitionLength))
            strongSelf.readAudioFile()
            strongSelf.internalAU?.initConvolutionEngine()
            strongSelf.internalAU?.start()
        }
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

    private func readAudioFile() {
        Exit: do {
            var err: OSStatus = noErr
            var theFileLengthInFrames: Int64 = 0
            var theFileFormat: AudioStreamBasicDescription = AudioStreamBasicDescription()
            var thePropertySize: UInt32 = UInt32(MemoryLayout.stride(ofValue: theFileFormat))
            var extRef: ExtAudioFileRef?
            var theData: UnsafeMutablePointer<CChar>?
            var theOutputFormat: AudioStreamBasicDescription = AudioStreamBasicDescription()

            err = ExtAudioFileOpenURL(impulseResponseFileURL, &extRef)
            if err != 0 { AKLog("ExtAudioFileOpenURL FAILED, Error = \(err)"); break Exit }

            guard let externalAudioFileRef = extRef else {
                break Exit
            }

            // Get the audio data format
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
                    let data = UnsafeMutablePointer<Float>(bufferList.mBuffers.mData?.assumingMemoryBound(to: Float.self))
                    internalAU?.setupAudioFileTable(data!, size: ioNumberFrames)
                } else {
                    // failure
                    theData?.deallocate()
                    theData = nil // make sure to return NULL
                    AKLog("Error = \(err)"); break Exit
                }
            }
        }
    }

}
