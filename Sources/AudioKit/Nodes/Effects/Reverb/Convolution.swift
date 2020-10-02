// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// This module will perform partitioned convolution on an input signal using an
/// ftable as an impulse response.
///
public class Convolution: Node, AudioUnitContainer, Tappable, Toggleable {

    /// Unique four-letter identifier "conv"
    public static let ComponentDescription = AudioComponentDescription(effect: "conv")

    /// Internal type of audio unit for this node
    public typealias AudioUnitType = InternalAU

    /// Internal audio unit
    public private(set) var internalAU: AudioUnitType?

    // MARK: - Parameters

    fileprivate var impulseResponseFileURL: CFURL
    fileprivate var partitionLength: Int = 2_048

    // MARK: - Audio Unit

    /// Internal audio unit for convolution
    public class InternalAU: AudioUnitBase {

        /// Create the DSP Refence for this node
        /// - Returns: DSP Reference
        public override func createDSP() -> DSPRef {
            akCreateDSP("ConvolutionDSP")
        }

        /// Set Partition Length
        /// - Parameter length: Length of partition
        public func setPartitionLength(_ length: Int) {
            akConvolutionSetPartitionLength(dsp, Int32(length))
        }

    }

    // MARK: - Initialization

    /// Initialize this convolution node
    ///
    /// - Parameters:
    ///   - partitionLength: Partition length (in samples). Must be a power of 2.
    ///     Lower values will add less latency, at the cost of requiring more CPU power.
    ///
    public init(_ input: Node,
                impulseResponseFileURL: URL,
                partitionLength: Int = 2_048
    ) {
        self.impulseResponseFileURL = impulseResponseFileURL as CFURL
        self.partitionLength = partitionLength

        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AudioUnitType

            self.internalAU?.setPartitionLength(partitionLength)
            self.readAudioFile()
            self.internalAU?.start()
        }

        connections.append(input)
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
            if err != 0 { Log("ExtAudioFileOpenURL FAILED, Error = \(err)"); break Exit }

            guard let externalAudioFileRef = extRef else {
                break Exit
            }

            // Get the audio data format
            err = ExtAudioFileGetProperty(externalAudioFileRef,
                                          kExtAudioFileProperty_FileDataFormat,
                                          &thePropertySize,
                                          &theFileFormat)
            if err != 0 {
                Log("ExtAudioFileGetProperty(kExtAudioFileProperty_FileDataFormat) FAILED, Error = \(err)")
                break Exit
            }
            if theFileFormat.mChannelsPerFrame > 2 {
                Log("Unsupported Format, channel count is greater than stereo")
                break Exit
            }

            theOutputFormat.mSampleRate = Settings.sampleRate
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
                Log("ExtAudioFileSetProperty(kExtAudioFileProperty_ClientDataFormat) FAILED, Error = \(err)")
                break Exit
            }

            // Get the total frame count
            thePropertySize = UInt32(MemoryLayout.stride(ofValue: theFileLengthInFrames))
            err = ExtAudioFileGetProperty(externalAudioFileRef,
                                          kExtAudioFileProperty_FileLengthFrames,
                                          &thePropertySize,
                                          &theFileLengthInFrames)
            if err != 0 {
                Log("ExtAudioFileGetProperty(kExtAudioFileProperty_FileLengthFrames) FAILED, Error = \(err)")
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
                    internalAU?.setWavetable(data: data, size: Int(ioNumberFrames))
                } else {
                    // failure
                    theData?.deallocate()
                    theData = nil // make sure to return NULL
                    Log("Error = \(err)"); break Exit
                }
            }
        }
    }
}
