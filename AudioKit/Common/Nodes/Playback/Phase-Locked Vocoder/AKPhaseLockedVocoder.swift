//
//  AKPhaseLockedVocoder.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// This is a phase locked vocoder. It has the ability to play back an audio
/// file loaded into an ftable like a sampler would. Unlike a typical sampler,
/// mincer allows time and pitch to be controlled separately.
///
open class AKPhaseLockedVocoder: AKNode, AKComponent {
    public typealias AKAudioUnitType = AKPhaseLockedVocoderAudioUnit
    public static let ComponentDescription = AudioComponentDescription(generator: "minc")

    // MARK: - Properties

    internal var internalAU: AKAudioUnitType?
    internal var token: AUParameterObserverToken?

    fileprivate var positionParameter: AUParameter?
    fileprivate var amplitudeParameter: AUParameter?
    fileprivate var pitchRatioParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Position in time. When non-changing it will do a spectral freeze of a the current point in time.
    open var position: Double = 0 {
        willSet {
            if position != newValue {
                if internalAU!.isSetUp() {
                    positionParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.position = Float(newValue)
                }
            }
        }
    }

    /// Amplitude.
    open var amplitude: Double = 1 {
        willSet {
            if amplitude != newValue {
                if internalAU!.isSetUp() {
                    amplitudeParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.amplitude = Float(newValue)
                }
            }
        }
    }

    /// Pitch ratio. A value of. 1  normal, 2 is double speed, 0.5 is halfspeed, etc.
    open var pitchRatio: Double = 1 {
        willSet {
            if pitchRatio != newValue {
                if internalAU!.isSetUp() {
                    pitchRatioParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.pitchRatio = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    fileprivate var avAudiofile: AVAudioFile

    // MARK: - Initialization

    /// Initialize this Phase-Locked Vocoder node
    ///
    /// - Parameters:
    ///   - audioFileURL: Location of the audio file to use.
    ///   - position: Position in time. When non-changing it will do a spectral freeze of a the current point in time.
    ///   - amplitude: Amplitude.
    ///   - pitchRatio: Pitch ratio. A value of. 1  normal, 2 is double speed, 0.5 is halfspeed, etc.
    ///
    public init(
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

        AVAudioUnit._instantiate(with: _Self.ComponentDescription) {
            avAudioUnit in

            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            AudioKit.engine.attach(self.avAudioNode)
        }

        guard let tree = internalAU?.parameterTree else { return }

        positionParameter   = tree["position"]
        amplitudeParameter  = tree["amplitude"]
        pitchRatioParameter = tree["pitchRatio"]

        token = tree.token(byAddingParameterObserver: {
            address, value in

            DispatchQueue.main.async {
                if address == self.positionParameter!.address {
                    self.position = Double(value)
                } else if address == self.amplitudeParameter!.address {
                    self.amplitude = Double(value)
                } else if address == self.pitchRatioParameter!.address {
                    self.pitchRatio = Double(value)
                }
            }
        })
        internalAU?.position = Float(position)
        internalAU?.amplitude = Float(amplitude)
        internalAU?.pitchRatio = Float(pitchRatio)
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

            err = ExtAudioFileOpenURL(self.avAudiofile.url as CFURL, &extRef)
            if err != 0 { print("ExtAudioFileOpenURL FAILED, Error = \(err)"); break Exit }
            // Get the audio data format
            err = ExtAudioFileGetProperty(extRef!, kExtAudioFileProperty_FileDataFormat, &thePropertySize, &theFileFormat)
            if err != 0 { print("ExtAudioFileGetProperty(kExtAudioFileProperty_FileDataFormat) FAILED, Error = \(err)"); break Exit }
            if theFileFormat.mChannelsPerFrame > 2 { print("Unsupported Format, channel count is greater than stereo"); break Exit }

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
            if err != 0 { print("ExtAudioFileSetProperty(kExtAudioFileProperty_ClientDataFormat) FAILED, Error = \(err)"); break Exit }

            // Get the total frame count
            thePropertySize = UInt32(MemoryLayout.stride(ofValue: theFileLengthInFrames))
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
                    print("Error = \(err)"); break Exit;
                }
            }
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        internalAU!.stop()
    }
}
