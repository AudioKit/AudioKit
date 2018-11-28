//
//  Output.swift
//  OutputSplitter
//
//  Created by Romans Kisils on 28/11/2018.
//  Copyright © 2018 Roman Kisil. All rights reserved.
//

import Foundation
import AudioKit

class Output {
    var outputEngine: AVAudioEngine!
    var deviceId: AudioDeviceID!
    var engine: Engine!
    
    var firstOutputTime: Double?
    var inToOutSampleOffset: Double = 0
    
    init(deviceId: AudioDeviceID, engine: Engine) {
        self.deviceId = deviceId
        self.engine = engine
        
        outputEngine = AVAudioEngine()
        
        outputEngine.connect(outputEngine.mainMixerNode, to: outputEngine.outputNode)
        
        var renderCallbackStruct = AURenderCallbackStruct(
            inputProc: outputRenderCallback,
            inputProcRefCon: UnsafeMutableRawPointer(Unmanaged<Output>.passUnretained(self).toOpaque())
        );
        
        checkErr(AudioUnitSetProperty(outputEngine.outputNode.audioUnit!, kAudioUnitProperty_SetRenderCallback,
                                      kAudioUnitScope_Global, 0, &renderCallbackStruct,
                                      UInt32(MemoryLayout<AURenderCallbackStruct>.size)))
        
        
        
        outputEngine.prepare()
        
        var id = deviceId
        checkErr(AudioUnitSetProperty(outputEngine.outputNode.audioUnit!,
                                      kAudioOutputUnitProperty_CurrentDevice,
                                      kAudioUnitScope_Global, 0,
                                      &id,
                                      UInt32(MemoryLayout<AudioDeviceID>.size)))
        
        do {
            try outputEngine.start()
        } catch {
            print("Error starting the output engine")
        }
    }
    
    deinit {
        outputEngine.stop()
    }
}
