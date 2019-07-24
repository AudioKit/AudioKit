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
    var outputEngine: AVAudioEngine! // Every Output gets it own AudioEngine
    var device: EZAudioDevice!
    var engine: Engine!

    let outputRenderCallback: AURenderCallback = {
        (inRefCon: UnsafeMutableRawPointer,
        ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
        inTimeStamp: UnsafePointer<AudioTimeStamp>,
        inBusNumber: UInt32,
        inNumberFrames: UInt32,
        ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus in

        // Get Refs
        let buffer = UnsafeMutableAudioBufferListPointer(ioData)
        let output = Unmanaged<Output>.fromOpaque(inRefCon).takeUnretainedValue()
        let engine: Engine! = output.engine!

        // If Engine hasn't saved any data yet just output silence
        if (engine.latestSampleTime == nil) {
            makeBufferSilent(buffer!)
            return noErr
        }

        // Read the latest available Sample
        let sampleTime = engine.latestSampleTime
        if let err = checkErr(engine.ringBuffer.fetch(ioData!, framesToRead: inNumberFrames, startRead: sampleTime!).rawValue) {
            makeBufferSilent(buffer!)
            return err
        }

        return noErr
    }

    init(device: EZAudioDevice, engine: Engine) {
        self.device = device
        self.engine = engine

        outputEngine = AVAudioEngine()

        // Connect the main mixer straight to the output node to start audio pipeline
        outputEngine.connect(outputEngine.mainMixerNode, to: outputEngine.outputNode)

        // Set Output Nodes output device
        var id = device.deviceID
        checkErr(AudioUnitSetProperty(outputEngine.outputNode.audioUnit!,
                                      kAudioOutputUnitProperty_CurrentDevice,
                                      kAudioUnitScope_Global, 0,
                                      &id,
                                      UInt32(MemoryLayout<AudioDeviceID>.size)))

        // Setup Output Render Callback
        var renderCallbackStruct = AURenderCallbackStruct(
            inputProc: outputRenderCallback,
            inputProcRefCon: UnsafeMutableRawPointer(Unmanaged<Output>.passUnretained(self).toOpaque())
        )
        if let _ = checkErr(
            AudioUnitSetProperty(
                outputEngine.outputNode.audioUnit!,
                kAudioUnitProperty_SetRenderCallback,
                kAudioUnitScope_Global,
                0,
                &renderCallbackStruct,
                UInt32(MemoryLayout<AURenderCallbackStruct>.size)
            )
            ) {
            return
        }

        outputEngine.prepare()

        // TODO: Detect when device is ready to be used. This doesn't work in every case...
//        while (!device.isRunningSomewhere) {
//            print("Waiting for device to start running")
//        }

        // Delay playback for a couple Milliseconds to give time for device to start... (No ideal solution)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            do {
                try self.outputEngine.start()
            } catch {
                print("Error starting the output engine")
            }
        }

    }

    deinit {
        outputEngine.stop()
        outputEngine = nil
    }
}
