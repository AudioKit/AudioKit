//
//  SongProcessor.swift
//  SongProcessor
//
//  Created by Aurelius Prochazka on 6/22/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit
import AudioKit
import AVFoundation
import MediaPlayer

class SongProcessor {
    
    static let sharedInstance = SongProcessor()
    
    var audioFile: AKAudioFile?
    var audioFilePlayer: AKAudioPlayer?
    var variableDelay: AKVariableDelay?
    var delayMixer: AKDryWetMixer?
    var moogLadder: AKMoogLadder?
    var filterMixer: AKDryWetMixer?
    var reverb: AKCostelloReverb?
    var reverbMixer: AKDryWetMixer?
    var playerBooster: AKBooster?
    
    var currentSong: MPMediaItem?
    var isPlaying: Bool?
    
    init() {
        audioFile = try? AKAudioFile(readFileName: "mixloop.wav",
                                     baseDir: .resources)
        audioFilePlayer = try? AKAudioPlayer(file: audioFile!)
        audioFilePlayer?.looping = true
        variableDelay = AKVariableDelay(audioFilePlayer!)
        variableDelay?.rampTime = 0.2
        delayMixer = AKDryWetMixer(audioFilePlayer!, variableDelay!, balance: 0)
        moogLadder = AKMoogLadder(delayMixer!)
        filterMixer = AKDryWetMixer(delayMixer!, moogLadder!, balance: 0)
        reverb = AKCostelloReverb(filterMixer!)
        reverbMixer = AKDryWetMixer(filterMixer!, reverb!, balance: 0)
        playerBooster = AKBooster(reverbMixer!, gain: 0.5)
        AudioKit.output = playerBooster
        AudioKit.start()
    }
    
}
