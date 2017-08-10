//
//  SongProcessor.swift
//  SongProcessor
//
//  Created by Aurelius Prochazka on 6/22/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit
import AudioKit
import MediaPlayer

class SongProcessor {

    static let sharedInstance = SongProcessor()

    var audioFile: AKAudioFile!
    var audioFilePlayer: AKAudioPlayer!
    var variableDelay: AKVariableDelay!
    var delayMixer: AKDryWetMixer!
    var moogLadder: AKMoogLadder!
    var filterMixer: AKDryWetMixer!
    var reverb: AKCostelloReverb!
    var reverbMixer: AKDryWetMixer!
    var pitchShifter: AKPitchShifter!
    var pitchMixer: AKDryWetMixer!
    var bitCrusher: AKBitCrusher!
    var bitCrushMixer: AKDryWetMixer!
    var playerBooster: AKBooster!

    var currentSong: MPMediaItem?
    var isPlaying: Bool?
    var loopsPlaying: Bool {
        set{
            if newValue {
                guard let firtPlayer = players.values.first else { return }
                if !firtPlayer.isPlaying { playLoops() }
            } else {
                stopLoops()
            }
        }
        get{
            return players.values.first?.isPlaying ?? false
        }
    }
    
    var players = [String:AKAudioPlayer]()
    var playerMixer = AKMixer()
    
    init() {
        audioFile = try? AKAudioFile(readFileName: "mixloop.wav",
                                     baseDir: .resources)
        audioFilePlayer = try? AKAudioPlayer(file: audioFile)
        audioFilePlayer?.looping = true
        playerMixer.connect(audioFilePlayer)
        
        for name in ["bass","drum","guitar","lead"]{
            do{
                let audioFile = try AKAudioFile(readFileName: name+"loop.wav", baseDir: .resources)
                players[name] = try AKAudioPlayer(file: audioFile,looping: true)
                playerMixer.connect(players[name])
            } catch {
                fatalError(String(describing: error))
            }
        }

        
        startVariableDelay()
        startMoogLadder()
        startCostelloReverb()
        startPitchShifting()
        startBitCrushing()

        //Booster for Volume
        playerBooster = AKBooster(bitCrushMixer, gain: 0.5)

        AudioKit.output = playerBooster
        AudioKit.start()
    }

    func startVariableDelay() {
        variableDelay = AKVariableDelay(playerMixer)
        variableDelay?.rampTime = 0.2
        delayMixer = AKDryWetMixer(playerMixer, variableDelay, balance: 0)
    }

    func startMoogLadder() {
        moogLadder = AKMoogLadder(delayMixer)
        filterMixer = AKDryWetMixer(delayMixer, moogLadder, balance: 0)

    }

    func startCostelloReverb() {
        reverb = AKCostelloReverb(filterMixer)
        reverbMixer = AKDryWetMixer(filterMixer, reverb, balance: 0)
    }

    func startPitchShifting() {
        pitchShifter = AKPitchShifter(reverbMixer)
        pitchMixer = AKDryWetMixer(reverbMixer, pitchShifter, balance: 0)
    }

    func startBitCrushing() {
        bitCrusher = AKBitCrusher(pitchMixer)
        bitCrusher?.bitDepth = 16
        bitCrusher?.sampleRate = 3_333
        bitCrushMixer = AKDryWetMixer(pitchMixer, bitCrusher, balance: 0)
    }
    func rewindLoops(){
        playersDo{ $0.schedule(from: 0, to: $0.duration, avTime: nil)}
    }
    func playLoops(at when: AVAudioTime? = nil) {
        let startTime = when ?? SongProcessor.twoRendersFromNow()
        playersDo{ $0.play(at: startTime) }
    }
    func stopLoops(){
        playersDo{ $0.stop() }
    }
    func playersDo(_ action: @escaping (AKAudioPlayer) -> Void){
        for player in players.values { action(player) }
    }
    private class func twoRendersFromNow() -> AVAudioTime {
        let twoRenders = AVAudioTime.hostTime(forSeconds: AKSettings.bufferLength.duration * 2)
        return AVAudioTime.init(hostTime: mach_absolute_time() + twoRenders)
    }
}
