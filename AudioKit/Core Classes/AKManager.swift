//
//  AKManager.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

typealias Sample = Float

/** A class to manage AudioKit */
@objc class AKManager : NSObject {
    
    /** Pointer for reference to this instance in CoreAudio */
    private var selfPtr: AKManager?
    
    /** Internal reference to SoundPipe */
    var data: UnsafeMutablePointer<sp_data> = nil

    /** Singleton to handle all AudioKit internal operations */
    static let sharedManager = AKManager()
    
    /** The collection of instruments */
    var instruments: [AKInstrument] = []
    
    /** Start up SoundPipe and CoreAudio */
    override init() {
        super.init()
        selfPtr = self
        sp_createn(&data, 2)
    }
    
    /** Release memory */
    func teardown() {
        sp_destroy(&data)
    }
    
    /** Set up CoreAudio functionality */
    func setupAudioUnit() {
        var outputComponent: AudioComponent
        var acd: AudioComponentDescription
        var audiokitComponent: AudioComponentInstance = nil
        var asbd: AudioStreamBasicDescription
        var rcs: AURenderCallbackStruct
        var status: OSStatus
        
        asbd = AudioStreamBasicDescription(
            mSampleRate: 44100,
            mFormatID: AudioFormatID(kAudioFormatLinearPCM),
            mFormatFlags: AudioFormatFlags(kAudioFormatFlagIsFloat
                | kAudioFormatFlagsNativeEndian
                | kAudioFormatFlagIsPacked
                | kAudioFormatFlagIsNonInterleaved),
            mBytesPerPacket: UInt32(sizeof(Sample)),
            mFramesPerPacket: 1,
            mBytesPerFrame: UInt32(sizeof(Sample)),
            mChannelsPerFrame: 2,
            mBitsPerChannel: UInt32(sizeof(Sample) * 8),
            mReserved:0
        )
        
        acd = AudioComponentDescription(
            componentType: OSType(kAudioUnitType_Output),
            componentSubType: OSType(kAudioUnitSubType_DefaultOutput),
            componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
            componentFlags: 0,
            componentFlagsMask: 0
        )
        
        outputComponent = AudioComponentFindNext(nil, &acd)
        assert(outputComponent != nil)
        
        status = AudioComponentInstanceNew(outputComponent, &audiokitComponent)
        assert(status == noErr)
        
        status = AudioUnitSetProperty(
            audiokitComponent,
            AudioUnitPropertyID(kAudioUnitProperty_StreamFormat),
            AudioUnitScope(kAudioUnitScope_Input),
            0,
            &asbd,
            UInt32(sizeof(AudioStreamBasicDescription))
        )
        assert(status == noErr)
        
        rcs = AURenderCallbackStruct(
            inputProc: audioKitAudioUnitRenderCallback_ptr(),
            inputProcRefCon: &selfPtr
        )
        
        status = AudioUnitSetProperty(
            audiokitComponent,
            AudioUnitPropertyID(kAudioUnitProperty_SetRenderCallback),
            AudioUnitScope(kAudioUnitScope_Global),
            0,
            &rcs,
            UInt32(sizeof(AURenderCallbackStruct))
        )
        assert(status == noErr)
        
        status = AudioUnitInitialize(audiokitComponent)
        assert(status == noErr)
        
        status = AudioOutputUnitStart(audiokitComponent)
        assert(status == noErr)
    }
    
    /** The render proc */
    func render(
        actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
        timeStamp: UnsafePointer<AudioTimeStamp>,
        busNumber: UInt32,
        frameCount: UInt32,
        data: UnsafeMutablePointer<AudioBufferList>) -> OSStatus {
            let buffer = unsafeBitCast(data.memory.mBuffers, AudioBuffer.self)
            let bufferData = unsafeBitCast(buffer.mData, UnsafeMutablePointer<Sample>.self)
            for i in 0 ..< Int(frameCount) {
                bufferData[i] = 0
                bufferData[i+Int(frameCount)] = 0
                for instrument in AKManager.sharedManager.instruments {
                    for operation in instrument.operations {
                        operation.compute()
                    }
                    bufferData[i] += Sample(AKManager.sharedManager.data.memory.out[0])
                    bufferData[i+Int(frameCount)] += Sample(AKManager.sharedManager.data.memory.out[1])
                }
            }
            
            return noErr
    }

    
}