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
        guard let audioTime = audioTime else { return }

        // AKLog(fade, faderNode?.rampDuration, faderNode?.gain, audioTime, hostTime)

        guard fade.inTime != 0 || fade.outTime != 0 else {
            return
        }

//        guard let hostTime = hostTime, var triggerTime = audioTime?.toSeconds(hostTime: hostTime) else {
//            startFade()
//            return
//        }

        var triggerTimeInSamples: AUEventSampleTime = 0

        if audioTime.isHostTimeValid, let hostTime = hostTime {
            triggerTimeInSamples = AUEventSampleTime(audioTime.toSeconds(hostTime: hostTime) * sampleRate)

        } else if audioTime.isSampleTimeValid {
            triggerTimeInSamples = audioTime.sampleTime
        }

        var triggerTime = Double(triggerTimeInSamples) / sampleRate

        triggerTime /= _rate

         AKLog("starting fade IN, in", triggerTime, "seconds")

        // Note: that the timers are a hack until parameter scheduling is added into AudioKit
        DispatchQueue.main.async {
            self.faderTimer?.invalidate()
            self.faderTimer = Timer.scheduledTimer(timeInterval: triggerTime,
                                                   target: self,
                                                   selector: #selector(self.startFade),
                                                   userInfo: nil,
                                                   repeats: false)
        }

        //triggerTimeInSamples /= AUEventSampleTime(_rate)

       // triggerTimeInSamples = 0

//        let inTime = fade.inTime - fade.inTimeOffset
//        if inTime > 0 {
//            //faderNode.gain = Fade.minimumGain // set to 0
//            //faderNode.rampDuration = inTime / _rate
//
//            let value = fade.maximumGain
//            let rampSamples = AUAudioFrameCount(fade.inTime * sampleRate)
//
//            AKLog("Scheduling fade IN to value:", value, "at triggerTimeInSamples", triggerTimeInSamples, "rampDuration", rampSamples)
//            //AUEventSampleTimeImmediate
//
//            faderNode.scheduleParameter(value: Fade.minimumGain, at: triggerTimeInSamples, rampDuration: 0)
//            faderNode.scheduleParameter(value: value, at: triggerTimeInSamples, rampDuration: rampSamples)
//
//        }

//        let outTime = fade.outTime
//        if outTime > 0 {
//
//            let when = (duration - startTime) - (duration - endTime) - fade.outTime
//
//            let sampleTime = AUEventSampleTime(when * sampleRate)
//            let outRamp = AUAudioFrameCount(fade.outTime * sampleRate)
//            let value = Fade.minimumGain
//
//            AKLog("Scheduling fade out (\(when)sec) to value:", value, "at sampleTime", sampleTime, "rampDuration", outRamp)
//            faderNode.scheduleParameter(value: value, at: sampleTime, rampDuration: outRamp)
//        }


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
        faderTimer?.invalidate()
        
        guard let faderNode = faderNode else { return }

        AKLog("Fading in to", fade.maximumGain, ", shape:", fade.inRampType.rawValue)

        let inTime = fade.inTime - fade.inTimeOffset
        if inTime > 0 {
            //faderNode.gain = Fade.minimumGain // set to 0
            //faderNode.rampDuration = inTime / _rate

            let value = fade.maximumGain
            let rampSamples = AUAudioFrameCount((inTime / _rate) * sampleRate)

            AKLog("Scheduling fade IN to value:", value, "rampSamples", rampSamples)
            //AUEventSampleTimeImmediate

            faderNode.scheduleParameter(value: Fade.minimumGain, at: AUEventSampleTimeImmediate, rampDuration: 0)
            faderNode.scheduleParameter(value: value, at: AUEventSampleTimeImmediate, rampDuration: rampSamples)

        }

//        faderNode.rampDuration = AKSettings.rampDuration
//
//        if inTime > 0 {
//            faderNode.gain = Fade.minimumGain
//            faderNode.rampDuration = inTime / _rate
//        }
//        // set target gain and begin ramping
//        faderNode.gain = fade.maximumGain
//        faderTimer?.invalidate()

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

            // Note: that the timers are a hack until parameter scheduling is added into AudioKit
            DispatchQueue.main.async {
                self.faderTimer?.invalidate()
                self.faderTimer = Timer.scheduledTimer(timeInterval: when,
                                                       target: self,
                                                       selector: #selector(self.fadeOut),
                                                       userInfo: nil,
                                                       repeats: false)
            }

//            let sampleTime = AUEventSampleTime(when * sampleRate)
//            let outRamp = AUAudioFrameCount(fade.outTime * sampleRate)
//            let value = Fade.minimumGain
//
//            AKLog("Scheduling fade out (\(when)sec) to value:", value, "at sampleTime", sampleTime, "rampDuration", outRamp)
//            faderNode.scheduleParameter(value: value, at: sampleTime, rampDuration: outRamp)
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
//            faderNode.rampDuration = time / _rate
//            faderNode.gain = Fade.minimumGain

            // AKLog("Fading out over", time, "seconds, shape:", fade.outRampType.rawValue)

            //let sampleTime = AUEventSampleTime(when * sampleRate)
            let rampSamples = AUAudioFrameCount((time / _rate) * sampleRate) //AUAudioFrameCount(fade.outTime * sampleRate)
            let value = Fade.minimumGain

            AKLog("Scheduling fade out (\(time)sec) to value:", value, "rampSamples", rampSamples)
            faderNode.scheduleParameter(value: value, at: AUEventSampleTimeImmediate, rampDuration: rampSamples)
        }
    }
}
