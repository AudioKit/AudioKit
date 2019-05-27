//
//  AKPlayer+Fader.swift
//  AudioKit
//
//  Created by Ryan Francesconi on 6/12/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// The Fader is also used for the gain stage of the player
extension AKPlayer {
    internal func createFader() {
        guard faderNode == nil else { return }

        // AKLog("Creating fader")
        faderNode = AKBooster()
        faderNode?.gain = gain
        faderNode?.rampType = rampType
        initialize()
    }

    internal func initFader(at audioTime: AVAudioTime?, hostTime: UInt64?) {
        guard faderNode != nil else { return }

        // AKLog(fade, faderNode?.rampDuration, faderNode?.gain, audioTime, hostTime)

        guard fade.inTime != 0 || fade.outTime != 0 else {
            return
        }

        guard let hostTime = hostTime, var triggerTime = audioTime?.toSeconds(hostTime: hostTime) else {
            startFade()
            return
        }
        triggerTime /= _rate
        // AKLog("starting fade in", triggerTime, "seconds")

        DispatchQueue.main.async {
            self.faderTimer?.invalidate()
            self.faderTimer = Timer.scheduledTimer(timeInterval: triggerTime,
                                                   target: self,
                                                   selector: #selector(self.startFade),
                                                   userInfo: nil,
                                                   repeats: false)
        }
    }

    internal func resetFader(_ state: Bool) {
        guard let faderNode = faderNode else { return }
        var state = state
        if fade.inTime == 0 {
            state = true
        }
        faderNode.rampType = fade.inRampType
        faderNode.rampDuration = AKSettings.rampDuration
        faderNode.gain = state ? fade.maximumGain : Fade.minimumGain
    }

    @objc private func startFade() {
        guard let faderNode = faderNode else { return }

        let inTime = fade.inTime - fade.inTimeOffset

        // AKLog("Fading in to", fade.maximumGain, ", shape:", fade.inRampType.rawValue)

        faderNode.rampDuration = AKSettings.rampDuration

        if inTime > 0 {
            faderNode.gain = Fade.minimumGain
            faderNode.rampDuration = inTime / _rate
        }
        // set target gain and begin ramping
        faderNode.gain = fade.maximumGain
        faderTimer?.invalidate()

        guard fade.outTime > 0 else { return }

        if fade.outTimeOffset > 0 {
            // just fade now the remainder of the segment
            var midFadeDuration = duration - startTime
            if endTime < duration {
                midFadeDuration -= (duration - endTime)
            }
            fadeOutWithTime(midFadeDuration)
        } else {
            var when = (duration - startTime) - (duration - endTime) - fade.outTime
            when /= _rate

            DispatchQueue.main.async {
                self.faderTimer?.invalidate()
                self.faderTimer = Timer.scheduledTimer(timeInterval: when,
                                                       target: self,
                                                       selector: #selector(self.fadeOut),
                                                       userInfo: nil,
                                                       repeats: false)
            }
        }
    }

    @objc private func fadeOut() {
        if fade.outTime > 0 {
            fadeOutWithTime(fade.outTime)
        }
    }

    @objc internal func fadeOutWithTime(_ time: Double) {
        guard let faderNode = faderNode else { return }

        if time > 0 {
            // at this point init the faderNode with the correct settings for fade out
            faderNode.rampType = fade.outRampType
            faderNode.rampDuration = time / _rate
            faderNode.gain = Fade.minimumGain

            // AKLog("Fading out over", time, "seconds, shape:", fade.outRampType.rawValue)
        }
    }
}
