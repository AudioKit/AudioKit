//
//  OutputRenderCallback.swift
//  OutputSplitter
//
//  Created by Romans Kisils on 26/11/2018.
//  Copyright © 2018 Roman Kisil. All rights reserved.
//

import Foundation
import AudioToolbox

let outputRenderCallback: AURenderCallback = {
    (inRefCon: UnsafeMutableRawPointer,
    ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
    inTimeStamp:  UnsafePointer<AudioTimeStamp>,
    inBusNumber: UInt32,
    inNumberFrames: UInt32,
    ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus in
    
    let abl = UnsafeMutableAudioBufferListPointer(ioData)
    let outputDevice = Unmanaged<Output>.fromOpaque(inRefCon).takeUnretainedValue()
    let engine: Engine! = outputDevice.engine!
    
    if engine.firstInputTime == nil {
        makeBufferSilent(abl!)
        return noErr
    }
    
    let sampleTime = inTimeStamp.pointee.mSampleTime
    if outputDevice.firstOutputTime == nil {
        outputDevice.firstOutputTime = sampleTime
        let delta = (engine.firstInputTime ?? 0) - (outputDevice.firstOutputTime ?? 0)
        let offset = 0//computeThruOffset(inputDevice: (engine.inputDevice)!, outputDevice: outputDevice.device)
        
        outputDevice.inToOutSampleOffset = (offset).doubleValue
        if delta < 0 {
            outputDevice.inToOutSampleOffset -= delta
        } else {
            outputDevice.inToOutSampleOffset = -delta + outputDevice.inToOutSampleOffset
        }
        
        makeBufferSilent(abl!)
        return noErr
    }
    
    let startFetch = sampleTime - outputDevice.inToOutSampleOffset
    
    if let err = checkErr(engine.ringBuffer.fetch(ioData!, framesToRead: inNumberFrames, startRead: startFetch.int64Value).rawValue) {
        makeBufferSilent(abl!)
        var bufferStartTime: SampleTime = 0
        var bufferEndTime: SampleTime = 0
        _ = engine.ringBuffer.getTimeBounds(startTime: &bufferStartTime, endTime: &bufferEndTime)
        outputDevice.inToOutSampleOffset = sampleTime - bufferStartTime.doubleValue
        return noErr
    }
    
    return noErr;
}
