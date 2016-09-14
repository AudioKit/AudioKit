//
//  AKConvolution.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// This module will perform partitioned convolution on an input signal using an
/// audio file as an impulse response.
///
/// - Parameters:
///   - input: Input node to process
///   - impulseResponseFileURL: Location of the imulseResponse audio File
///   - partitionLength: Partition length (in samples). Must be a power of 2. Lower values will add less latency, at the cost of requiring more CPU power.
///
public class AKConvolution: AKNode, AKToggleable {

    // MARK: - Properties


    internal var internalAU: AKConvolutionAudioUnit?

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    private var impulseResponseFileURL: CFURL
    private var partitionLength: Int = 2048

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

        self.impulseResponseFileURL = impulseResponseFileURL
        self.partitionLength = partitionLength

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x636f6e76 /*'conv'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKConvolutionAudioUnit.self,
            as: description,
            name: "Local AKConvolution",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiate(with: description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitGenerator = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitGenerator
            self.internalAU = avAudioUnitGenerator.auAudioUnit as? AKConvolutionAudioUnit

            AudioKit.engine.attach(self.avAudioNode)
            input.addConnectionPoint(self)
            self.internalAU!.setPartitionLength(Int32(partitionLength))
        }
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        Exit: do {
            var err: OSStatus = noErr
            var theFileLengthInFrames: Int64 = 0
            var theFileFormat: AudioStreamBasicDescription = AudioStreamBasicDescription()
            var thePropertySize: UInt32 = UInt32(strideofValue(theFileFormat))
            var extRef: ExtAudioFileRef? = nil
            var theData: UnsafeMutablePointer<CChar>? = nil
            var theOutputFormat: AudioStreamBasicDescription = AudioStreamBasicDescription()

            err = ExtAudioFileOpenURL(self.impulseResponseFileURL, &extRef)
            if err != 0 { print("ExtAudioFileOpenURL FAILED, Error = \(err)"); break Exit }
            // Get the audio data format
            err = ExtAudioFileGetProperty(extRef!, kExtAudioFileProperty_FileDataFormat, &thePropertySize, &theFileFormat)
            if err != 0 { print("ExtAudioFileGetProperty(kExtAudioFileProperty_FileDataFormat) FAILED, Error = \(err)"); break Exit }
            if theFileFormat.mChannelsPerFrame > 2 { print("Unsupported Format, channel count is greater than stereo"); break Exit }

            theOutputFormat.mSampleRate = AKSettings.sampleRate
            theOutputFormat.mFormatID = kAudioFormatLinearPCM
            theOutputFormat.mFormatFlags = kLinearPCMFormatFlagIsFloat
            theOutputFormat.mBitsPerChannel = UInt32(strideof(Float)) * 8
            theOutputFormat.mChannelsPerFrame = 1; // Mono
            theOutputFormat.mBytesPerFrame = theOutputFormat.mChannelsPerFrame * UInt32(strideof(Float))
            theOutputFormat.mFramesPerPacket = 1
            theOutputFormat.mBytesPerPacket = theOutputFormat.mFramesPerPacket * theOutputFormat.mBytesPerFrame

            // Set the desired client (output) data format
            err = ExtAudioFileSetProperty(extRef!, kExtAudioFileProperty_ClientDataFormat, UInt32(strideofValue(theOutputFormat)), &theOutputFormat)
            if err != 0 { print("ExtAudioFileSetProperty(kExtAudioFileProperty_ClientDataFormat) FAILED, Error = \(err)"); break Exit }

            // Get the total frame count
            thePropertySize = UInt32(strideofValue(theFileLengthInFrames))
            err = ExtAudioFileGetProperty(extRef!, kExtAudioFileProperty_FileLengthFrames, &thePropertySize, &theFileLengthInFrames)
            if err != 0 { print("ExtAudioFileGetProperty(kExtAudioFileProperty_FileLengthFrames) FAILED, Error = \(err)"); break Exit }

            // Read all the data into memory
            let dataSize = UInt32(theFileLengthInFrames) * theOutputFormat.mBytesPerFrame
            theData = UnsafeMutablePointer.allocate(capacity: Int(dataSize))
            if theData != nil {
                var theDataBuffer: AudioBufferList = AudioBufferList()
                theDataBuffer.mNumberBuffers = 1
                theDataBuffer.mBuffers.mDataByteSize = dataSize
                theDataBuffer.mBuffers.mNumberChannels = theOutputFormat.mChannelsPerFrame
                theDataBuffer.mBuffers.mData = UnsafeMutablePointer(theData)

                // Read the data into an AudioBufferList
                var ioNumberFrames: UInt32 = UInt32(theFileLengthInFrames)
                err = ExtAudioFileRead(extRef!, &ioNumberFrames, &theDataBuffer)
                if err == noErr {
                    // success
                    let data = UnsafeMutablePointer<Float>(theDataBuffer.mBuffers.mData)
                    internalAU?.setupAudioFileTable(data, size: ioNumberFrames)
                    internalAU!.start()
                } else {
                    // failure
                    theData?.deallocate(capacity: Int(dataSize))
                    theData = nil // make sure to return NULL
                    print("Error = \(err)"); break Exit;
                }
            }
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        internalAU!.stop()
    }


}
