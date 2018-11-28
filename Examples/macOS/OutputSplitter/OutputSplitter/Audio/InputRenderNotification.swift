//
//  InputRenderCallback.swift
//  OutputSplitter
//
//  Created by Romans Kisils on 26/11/2018.
//  Copyright © 2018 Roman Kisil. All rights reserved.
//

import Foundation
import AudioToolbox

let inputRenderedNotification: AURenderCallback = {
    (inRefCon: UnsafeMutableRawPointer,
    ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
    inTimeStamp:  UnsafePointer<AudioTimeStamp>,
    inBusNumber: UInt32,
    inNumberFrames: UInt32,
    ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus in
    
    if ioActionFlags.pointee == AudioUnitRenderActionFlags.unitRenderAction_PostRender {
        let engine = Unmanaged<Engine>.fromOpaque(inRefCon).takeUnretainedValue()
        
        let sampleTime = inTimeStamp.pointee.mSampleTime
        if engine.firstInputTime == nil {
            engine.firstInputTime = sampleTime
        }
        
        if let err = checkErr(engine.ringBuffer.store(ioData!, framesToWrite: inNumberFrames, startWrite: sampleTime.int64Value).rawValue) {
            return err
        }
    }
    
    return noErr;
}
