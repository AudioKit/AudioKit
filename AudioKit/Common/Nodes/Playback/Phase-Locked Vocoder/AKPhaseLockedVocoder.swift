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
/// - parameter audioFileURL: Location of the audio file to use.
/// - parameter position: Position in time. When non-changing it will do a spectral freeze of a the current point in time.
/// - parameter amplitude: Amplitude.
/// - parameter pitchRatio: Pitch ratio. A value of. 1  normal, 2 is double speed, 0.5 is halfspeed, etc.
///
public class AKPhaseLockedVocoder: AKNode {

    // MARK: - Properties

    internal var internalAU: AKPhaseLockedVocoderAudioUnit?
    internal var token: AUParameterObserverToken?

    private var positionParameter: AUParameter?
    private var amplitudeParameter: AUParameter?
    private var pitchRatioParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    public var rampTime: Double = AKSettings.rampTime {
        willSet {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }
    
    /// Position in time. When non-changing it will do a spectral freeze of a the current point in time.
    public var position: Double = 0 {
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
    public var amplitude: Double = 1 {
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
    public var pitchRatio: Double = 1 {
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
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    private var audioFileURL: CFURL
    
    // MARK: - Initialization

    /// Initialize this Phase-Locked Vocoder node
    ///
    /// - parameter audioFileURL: Location of the audio file to use.
    /// - parameter position: Position in time. When non-changing it will do a spectral freeze of a the current point in time.
    /// - parameter amplitude: Amplitude.
    /// - parameter pitchRatio: Pitch ratio. A value of. 1  normal, 2 is double speed, 0.5 is halfspeed, etc.
    ///
    public init(
        audioFileURL: URL,
        position: Double = 0,
        amplitude: Double = 1,
        pitchRatio: Double = 1) {

        self.position = position
        self.amplitude = amplitude
        self.pitchRatio = pitchRatio
        self.audioFileURL = audioFileURL
        
        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Generator
        description.componentSubType      = 0x6d696e63 /*'minc'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0
        
        AUAudioUnit.registerSubclass(
            AKPhaseLockedVocoderAudioUnit.self,
            as: description,
            name: "Local AKPhaseLockedVocoder",
            version: UInt32.max)
        
        super.init()
        
        AVAudioUnit.instantiate(with: description, options: []) {
            avAudioUnit, error in
            
            guard let avAudioUnitGenerator = avAudioUnit else { return }
            
            self.avAudioNode = avAudioUnitGenerator
            self.internalAU = avAudioUnitGenerator.auAudioUnit as? AKPhaseLockedVocoderAudioUnit
            
            AudioKit.engine.attach(self.avAudioNode)
        }
        
        guard let tree = internalAU?.parameterTree else { return }
        
        positionParameter   = tree.value(forKey: "position")   as? AUParameter
        amplitudeParameter  = tree.value(forKey: "amplitude")  as? AUParameter
        pitchRatioParameter = tree.value(forKey: "pitchRatio") as? AUParameter
        
        let observer: AUParameterObserver = {
            address, value in
            
            let executionBlock = {
                if address == self.positionParameter!.address {
                    self.position = Double(value)
                } else if address == self.amplitudeParameter!.address {
                    self.amplitude = Double(value)
                } else if address == self.pitchRatioParameter!.address {
                    self.pitchRatio = Double(value)
                }
            }
            
            DispatchQueue.main.async(execute: executionBlock)
        }
        
        token = tree.token(byAddingParameterObserver: observer)
        internalAU?.position = Float(position)
        internalAU?.amplitude = Float(amplitude)
        internalAU?.pitchRatio = Float(pitchRatio)
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

            err = ExtAudioFileOpenURL(self.audioFileURL, &extRef)
            if err != 0 { print("ExtAudioFileOpenURL FAILED, Error = \(err)"); break Exit }
            // Get the audio data format
            err = ExtAudioFileGetProperty(extRef!, kExtAudioFileProperty_FileDataFormat, &thePropertySize, &theFileFormat)
            if err != 0 { print("ExtAudioFileGetProperty(kExtAudioFileProperty_FileDataFormat) FAILED, Error = \(err)"); break Exit }
            if theFileFormat.mChannelsPerFrame > 2 { print("Unsupported Format, channel count is greater than stereo"); break Exit }

            theOutputFormat.mSampleRate = AKSettings.sampleRate
            theOutputFormat.mFormatID = kAudioFormatLinearPCM
            theOutputFormat.mFormatFlags = kLinearPCMFormatFlagIsFloat
            theOutputFormat.mBitsPerChannel = UInt32(strideof(Float.self)) * 8
            theOutputFormat.mChannelsPerFrame = 1; // Mono
            theOutputFormat.mBytesPerFrame = theOutputFormat.mChannelsPerFrame * UInt32(strideof(Float.self))
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
            theData = UnsafeMutablePointer(allocatingCapacity: Int(dataSize))
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
                    let data=UnsafeMutablePointer<Float>(theDataBuffer.mBuffers.mData)
                    internalAU?.setupAudioFileTable(data, size: ioNumberFrames)
                    internalAU!.start()
                } else {
                    // failure
                    theData?.deallocateCapacity(Int(dataSize))
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
