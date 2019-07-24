//
//  AKPhaseLockedVocoder.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// This is a phase locked vocoder. It has the ability to play back an audio
/// file loaded into an ftable like a sampler would. Unlike a typical sampler,
/// mincer allows time and pitch to be controlled separately.
///

open class AKPhaseLockedVocoder: AKNode, AKComponent {
    public typealias AKAudioUnitType = AKPhaseLockedVocoderAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "minc")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?

    fileprivate var positionParameter: AUParameter?
    fileprivate var amplitudeParameter: AUParameter?
    fileprivate var pitchRatioParameter: AUParameter?

    /// Lower and upper bounds for position
    public static let positionRange = 0.0 ... 1_000.0

    /// Initial value for position
    public static let defaultPosition = 0.0

    /// Lower and upper bounds for amplitude
    public static let amplitudeRange = 0.0 ... 1.0

    /// Initial value for amplitude
    public static let defaultAmplitude = 0.0

    /// Lower and upper bounds for pitch ratio
    public static let pitchRatioRange = 0.0 ... 1_000.0

    /// Initial value for pitch ratio
    public static let defaultPitchRatio = 1.0

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Position in time. When non-changing it will do a spectral freeze of a the current point in time.
    @objc open dynamic var position: Double = 0 {
        willSet {
            guard position != newValue else { return }
            if internalAU?.isSetUp == true {
                positionParameter?.value = AUValue(newValue)
            } else {
                internalAU?.position = newValue
            }
        }
    }

    /// Amplitude.
    @objc open dynamic var amplitude: Double = 1 {
        willSet {
            guard amplitude != newValue else { return }
            if internalAU?.isSetUp == true {
                amplitudeParameter?.value = AUValue(newValue)
            } else {
                internalAU?.amplitude = newValue
            }
        }
    }

    /// Pitch ratio. A value of 1 is normal, 2 is double speed, 0.5 is halfspeed, etc.
    @objc open dynamic var pitchRatio: Double = 1 {
        willSet {
            guard pitchRatio != newValue else { return }
            if internalAU?.isSetUp == true {
                pitchRatioParameter?.value = AUValue(newValue)
            } else {
                internalAU?.pitchRatio = newValue
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    fileprivate var avAudiofile: AVAudioFile

    // MARK: - Initialization

    /// Initialize this Phase-Locked Vocoder node
    ///
    /// - Parameters:
    ///   - file: Location of the audio file to use.
    ///   - position: Position in time. When non-changing it will do a spectral freeze of a the current point in time.
    ///   - amplitude: Amplitude.
    ///   - pitchRatio: Pitch ratio. A value of 1 is normal, 2 is double speed, 0.5 is halfspeed, etc.
    ///
    @objc public init(
        file: AVAudioFile,
        position: Double = 0,
        amplitude: Double = 1,
        pitchRatio: Double = 1) {

        self.position = position
        self.amplitude = amplitude
        self.pitchRatio = pitchRatio
        self.avAudiofile = file

        _Self.register()

        super.init()

        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioUnit = avAudioUnit
            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        positionParameter = tree["position"]
        amplitudeParameter = tree["amplitude"]
        pitchRatioParameter = tree["pitchRatio"]
        internalAU?.position = position
        internalAU?.amplitude = amplitude
        internalAU?.pitchRatio = pitchRatio
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        Exit: do {
            var err: OSStatus = noErr
            var theFileLengthInFrames: Int64 = 0
            var theFileFormat = AudioStreamBasicDescription()
            var thePropertySize: UInt32 = UInt32(MemoryLayout.stride(ofValue: theFileFormat))
            var extRef: ExtAudioFileRef?
            var theData: UnsafeMutablePointer<CChar>?
            var theOutputFormat = AudioStreamBasicDescription()

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
                    theData?.deallocate()
                    theData = nil // make sure to return NULL
                    AKLog("Error = \(err)"); break Exit
                }
            }
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        internalAU?.stop()
    }
}
