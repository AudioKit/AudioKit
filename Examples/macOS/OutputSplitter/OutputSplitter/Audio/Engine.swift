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
    var renderer: AKBooster!
    var sink: AKBooster!
    
    var ringBuffer: CARingBuffer<Float>!
    var firstInputTime: Double?

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
        
        // Setup Renderer (Unit that just pipes through the Audio but emits Render notification. Might be possible to go w/o it)
        renderer = AKBooster(player, gain: 1)
        
        let lastAVUnit = renderer.avAudioNode as! AVAudioUnit
        if let err = checkErr(AudioUnitAddRenderNotify(lastAVUnit.audioUnit,
                                                       inputRenderedNotification,
                                                       UnsafeMutableRawPointer(Unmanaged<Engine>.passUnretained(self).toOpaque()))) {
            print(err)
            return
        }
        
        // Setup Ring buffer to store the audio data
        ringBuffer = CARingBuffer<Float>(numberOfChannels: 2, capacityFrames: UInt32(4096 * 20))
        
        // Setup Audio Sink so that we don't pipe the audio through the default device (we will do that manually)
        sink = AKBooster(renderer, gain: 1)
        
        // Set output Node and start Engine
        AudioKit.output = sink
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
    }
}
