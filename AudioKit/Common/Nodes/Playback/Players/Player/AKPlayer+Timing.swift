//
//  AKPlayer+Timing.swift
//  AudioKit
//
//  Created by Ryan Francesconi on 6/12/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

@objc extension AKPlayer: AKTiming {
    @objc public func start(at audioTime: AVAudioTime?) {
        play(at: audioTime)
    }

    @objc public var isStarted: Bool {
        return isPlaying
    }

    @objc public func setPosition(_ position: Double) {
        startTime = position
        if isPlaying {
            stop()
            play()
        }
    }

    @objc public func position(at audioTime: AVAudioTime?) -> Double {
        guard let playerTime = playerNode.playerTime(forNodeTime: audioTime ?? AVAudioTime.now()) else {
            return startTime
        }
        return startTime + Double(playerTime.sampleTime) / playerTime.sampleRate
    }

    @objc public func audioTime(at position: Double) -> AVAudioTime? {
        let sampleRate = playerNode.outputFormat(forBus: 0).sampleRate
        let sampleTime = (position - startTime) * sampleRate
        let playerTime = AVAudioTime(sampleTime: AVAudioFramePosition(sampleTime), atRate: sampleRate)
        return playerNode.nodeTime(forPlayerTime: playerTime)
    }

    @objc open func prepare() {
        preroll(from: startTime, to: endTime)
    }
}
