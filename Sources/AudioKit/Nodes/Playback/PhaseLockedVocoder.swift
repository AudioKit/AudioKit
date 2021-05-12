// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// This is a phase locked vocoder. It has the ability to play back an audio
/// file loaded into an ftable like a sampler would. Unlike a typical sampler,
/// mincer allows time and pitch to be controlled separately.
///
public class PhaseLockedVocoder: Node {
    
    /// Connected nodes
    public var connections: [Node] { [] }

    /// Underlying AVAudioNode
    public var avAudioNode = instantiate(instrument: "minc")
    
    /// Specification for position
    public static let positionDef = NodeParameterDef(
        identifier: "position",
        name: "Position in time. When non-changing it will do a spectral freeze of a the current point in time.",
        address: akGetParameterAddress("PhaseLockedVocoderParameterPosition"),
        defaultValue: 0,
        range: 0 ... 100_000,
        unit: .generic)

    /// Position in time. When non-changing it will do a spectral freeze of a the current point in time.
    @Parameter(positionDef) public var position: AUValue

    /// Specification for amplitude
    public static let amplitudeDef = NodeParameterDef(
        identifier: "amplitude",
        name: "Amplitude.",
        address: akGetParameterAddress("PhaseLockedVocoderParameterAmplitude"),
        defaultValue: 1,
        range: 0 ... 1,
        unit: .generic)

    /// Amplitude.
    @Parameter(amplitudeDef) public var amplitude: AUValue

    /// Specification for pitch ratio
    public static let pitchRatioDef = NodeParameterDef(
        identifier: "pitchRatio",
        name: "Pitch ratio. A value of. 1  normal, 2 is double speed, 0.5 is halfspeed, etc.",
        address: akGetParameterAddress("PhaseLockedVocoderParameterPitchRatio"),
        defaultValue: 1,
        range: 0 ... 1_000,
        unit: .hertz)

    /// Pitch ratio. A value of. 1  normal, 2 is double speed, 0.5 is halfspeed, etc.
    @Parameter(pitchRatioDef) public var pitchRatio: AUValue

    // MARK: - Initialization

    /// Initialize this vocoder node
    ///
    /// - Parameters:
    ///   - file: AVAudioFile to load into memory
    ///   - position: Position in time. When non-changing it will do a spectral freeze of a the current point in time.
    ///   - amplitude: Amplitude.
    ///   - pitchRatio: Pitch ratio. A value of. 1  normal, 2 is double speed, 0.5 is halfspeed, etc.
    ///
    public init(
        file: AVAudioFile,
        position: AUValue = positionDef.defaultValue,
        amplitude: AUValue = amplitudeDef.defaultValue,
        pitchRatio: AUValue = pitchRatioDef.defaultValue
    ) {
        setupParameters()
        
        loadFile(file)
        
        self.position = position
        self.amplitude = amplitude
        self.pitchRatio = pitchRatio
    }

    internal func loadFile(_ avAudioFile: AVAudioFile) {
        Exit: do {
            var err: OSStatus = noErr
            var theFileLengthInFrames: Int64 = 0
            var theFileFormat = AudioStreamBasicDescription()
            var thePropertySize: UInt32 = UInt32(MemoryLayout.stride(ofValue: theFileFormat))
            var extRef: ExtAudioFileRef?
            var theData: UnsafeMutablePointer<CChar>?
            var theOutputFormat = AudioStreamBasicDescription()

            err = ExtAudioFileOpenURL(avAudioFile.url as CFURL, &extRef)
            if err != 0 { Log("ExtAudioFileOpenURL FAILED, Error = \(err)"); break Exit }
            // Get the audio data format
            guard let externalAudioFileRef = extRef else {
                break Exit
            }
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
                    au.setWavetable(data: data, size: Int(ioNumberFrames))
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
