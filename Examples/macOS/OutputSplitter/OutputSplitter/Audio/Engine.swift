//
//  Engine.swift
//  OutputSplitter
//
//  Created by Romans Kisils on 26/11/2018.
//  Copyright © 2018 Roman Kisil. All rights reserved.
//

import Foundation
import AudioKit

class Engine {
    var file: AKAudioFile!
    var player: AKPlayer!
    var renderer: AKBooster! // Node which we will hook into to capture audio
    var sink: AKBooster! // Node that Sinks the Audio Data so we don't play it through default selected device

    var ringBuffer: RingBuffer<Float>! // Stores all the Audio Data in a circular fashion
    var latestSampleTime: Int64? // Reference of the latest available Audio Sample time

    // This is the callback we get every time the Renderer Node has some data available
    let inputRenderedNotification: AURenderCallback = {
        (inRefCon: UnsafeMutableRawPointer,
        ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
        inTimeStamp: UnsafePointer<AudioTimeStamp>,
        inBusNumber: UInt32,
        inNumberFrames: UInt32,
        ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus in

        if ioActionFlags.pointee == AudioUnitRenderActionFlags.unitRenderAction_PostRender {
            // Get Refs
            let engine = Unmanaged<Engine>.fromOpaque(inRefCon).takeUnretainedValue()
            let buffer = UnsafeMutableAudioBufferListPointer(ioData)

            // Get the current Sample Time
            let sampleTime = inTimeStamp.pointee.mSampleTime.int64Value
            engine.latestSampleTime = sampleTime

            // Write to RingBuffer
            if let err = checkErr(engine.ringBuffer.store(ioData!, framesToWrite: inNumberFrames, startWrite: sampleTime).rawValue) {
                makeBufferSilent(buffer!)
                return err
            }

        }

        return noErr
    }

    init () {
        // Get File
        let fileUrl = Bundle.main.url(forResource: "mixloop", withExtension: "wav")

        do {
            file = try AKAudioFile(forReading: fileUrl!)
        } catch {
            AKLog("mixloop file is missing")
            return
        }

        // Setup Player
        player = AKPlayer(audioFile: file)
        player.isLooping = true
        player.volume = 1

        // Setup Renderer (Unit that just pipes through the Audio but emits Render notification.
        // Might be possible to go w/o it if you listen to a PreRender Action on the Sink, haven't tried that
        renderer = AKBooster(player, gain: 1)

        // Setup Render Notification
        if let _ = checkErr(
            AudioUnitAddRenderNotify(
                (renderer.avAudioNode as! AVAudioUnit).audioUnit,
                inputRenderedNotification,
                UnsafeMutableRawPointer(Unmanaged<Engine>.passUnretained(self).toOpaque())
            )
        ) {
            return
        }

        // Setup Ring buffer to store the audio data
        ringBuffer = RingBuffer<Float>(numberOfChannels: 2, capacityFrames: UInt32(4_096 * 20))

        // Setup Audio Sink so that we don't pipe the audio through the default device (we will do that manually)
        sink = AKBooster(renderer, gain: 0)

        // Set output Node and start Engine
        AudioKit.output = sink
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
    }

}
