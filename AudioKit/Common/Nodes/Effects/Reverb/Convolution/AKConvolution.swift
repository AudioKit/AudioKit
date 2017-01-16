//
//  AKConvolution.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// This module will perform partitioned convolution on an input signal using an
/// audio file as an impulse response.
///
open class AKConvolution: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKConvolutionAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "conv")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    fileprivate var impulseResponseFileURL: CFURL
    fileprivate var partitionLength: Int = 2048

    // MARK: - Initialization

    /// Initialize this convolution node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - impulseResponseFileURL: Location of the imulseResponse audio File
    ///   - partitionLength: Partition length (in samples). Must be a power of 2. Lower values will add less latency, at the cost of requiring more CPU power.
    ///
    public init(
        _ input: AKNode,
        impulseResponseFileURL: URL,
        partitionLength: Int = 2048) {

        self.impulseResponseFileURL = impulseResponseFileURL as CFURL
        self.partitionLength = partitionLength

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) {
            avAudioUnit in

            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input.addConnectionPoint(self)
            self.internalAU!.setPartitionLength(Int32(partitionLength))
        }
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        Exit: do {
            var err: OSStatus = noErr
            var theFileLengthInFrames: Int64 = 0
            var theFileFormat: AudioStreamBasicDescription = AudioStreamBasicDescription()
            var thePropertySize: UInt32 = UInt32(MemoryLayout.stride(ofValue: theFileFormat))
            var extRef: ExtAudioFileRef? = nil
            var theData: UnsafeMutablePointer<CChar>? = nil
            var theOutputFormat: AudioStreamBasicDescription = AudioStreamBasicDescription()

            err = ExtAudioFileOpenURL(self.impulseResponseFileURL, &extRef)
            if err != 0 { AKLog("ExtAudioFileOpenURL FAILED, Error = \(err)"); break Exit }
            // Get the audio data format
            err = ExtAudioFileGetProperty(extRef!, kExtAudioFileProperty_FileDataFormat, &thePropertySize, &theFileFormat)
            if err != 0 { AKLog("ExtAudioFileGetProperty(kExtAudioFileProperty_FileDataFormat) FAILED, Error = \(err)"); break Exit }
            if theFileFormat.mChannelsPerFrame > 2 { AKLog("Unsupported Format, channel count is greater than stereo"); break Exit }

            theOutputFormat.mSampleRate = AKSettings.sampleRate
            theOutputFormat.mFormatID = kAudioFormatLinearPCM
            theOutputFormat.mFormatFlags = kLinearPCMFormatFlagIsFloat
            theOutputFormat.mBitsPerChannel = UInt32(MemoryLayout<Float>.stride) * 8
            theOutputFormat.mChannelsPerFrame = 1; // Mono
            theOutputFormat.mBytesPerFrame = theOutputFormat.mChannelsPerFrame * UInt32(MemoryLayout<Float>.stride)
            theOutputFormat.mFramesPerPacket = 1
            theOutputFormat.mBytesPerPacket = theOutputFormat.mFramesPerPacket * theOutputFormat.mBytesPerFrame

            // Set the desired client (output) data format
            err = ExtAudioFileSetProperty(extRef!, kExtAudioFileProperty_ClientDataFormat, UInt32(MemoryLayout.stride(ofValue: theOutputFormat)), &theOutputFormat)
            if err != 0 { AKLog("ExtAudioFileSetProperty(kExtAudioFileProperty_ClientDataFormat) FAILED, Error = \(err)"); break Exit }

            // Get the total frame count
            thePropertySize = UInt32(MemoryLayout.stride(ofValue: theFileLengthInFrames))
            err = ExtAudioFileGetProperty(extRef!, kExtAudioFileProperty_FileLengthFrames, &thePropertySize, &theFileLengthInFrames)
            if err != 0 { AKLog("ExtAudioFileGetProperty(kExtAudioFileProperty_FileLengthFrames) FAILED, Error = \(err)"); break Exit }

            // Read all the data into memory
            let dataSize = UInt32(theFileLengthInFrames) * theOutputFormat.mBytesPerFrame
            theData = UnsafeMutablePointer.allocate(capacity: Int(dataSize))
            if theData != nil {
                var theDataBuffer: AudioBufferList = AudioBufferList()
                theDataBuffer.mNumberBuffers = 1
                theDataBuffer.mBuffers.mDataByteSize = dataSize
                theDataBuffer.mBuffers.mNumberChannels = theOutputFormat.mChannelsPerFrame
                theDataBuffer.mBuffers.mData = UnsafeMutableRawPointer(theData)

                // Read the data into an AudioBufferList
                var ioNumberFrames: UInt32 = UInt32(theFileLengthInFrames)
                err = ExtAudioFileRead(extRef!, &ioNumberFrames, &theDataBuffer)
                if err == noErr {
                    // success
                    let data = UnsafeMutablePointer<Float>(theDataBuffer.mBuffers.mData?.assumingMemoryBound(to: Float.self))
                    internalAU?.setupAudioFileTable(data, size: ioNumberFrames)
                    internalAU!.start()
                } else {
                    // failure
                    theData?.deallocate(capacity: Int(dataSize))
                    theData = nil // make sure to return NULL
                    AKLog("Error = \(err)"); break Exit;
                }
            }
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        internalAU!.stop()
    }


}
