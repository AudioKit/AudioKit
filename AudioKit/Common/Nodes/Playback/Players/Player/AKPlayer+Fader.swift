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
        // only do this once when needed
        guard faderNode == nil else { return }

        AKLog("Creating fader")
        faderNode = AKBooster()
        faderNode?.gain = gain
        faderNode?.rampType = rampType

        initialize()
    }

    internal func initFader(at audioTime: AVAudioTime?, hostTime: UInt64?) {
        guard let audioTime = audioTime, let faderNode = faderNode else { return }

        // AKLog(fade, faderNode?.rampDuration, faderNode?.gain, audioTime, hostTime)

        // reset automation
        faderNode.stopAutomation()

        // 1 render cycle in the future
        let inTimeInSamples: AUEventSampleTime = 512

        var inTime = fade.inTime
        if inTime > 0 {
            let value = fade.maximumGain
            var fadeFrom = Fade.minimumGain

            if fade.inTimeOffset > 0 && fade.inTimeOffset < inTime {
                let ratio = fade.inTimeOffset / inTime
                fadeFrom = value * ratio
                inTime -= fade.inTimeOffset

                AKLog("In middle of a fade IN... adjusted inTime to", inTime)
            }

            let rampSamples = AUAudioFrameCount(inTime * sampleRate)

            AKLog("Scheduling fade IN to value:", value, "at inTimeInSamples", inTimeInSamples, "rampDuration", rampSamples, "fadeFrom", fadeFrom, "fade.inTimeOffset", fade.inTimeOffset)

            //inTimeInSamples
            faderNode.addAutomationPoint(value: fadeFrom, at: AUEventSampleTimeImmediate, anchorTime: audioTime.sampleTime, rampDuration: AUAudioFrameCount(0), rampType: fade.inRampType)

            // then fade it in
            faderNode.addAutomationPoint(value: value, at: inTimeInSamples, anchorTime: audioTime.sampleTime, rampDuration: rampSamples, rampType: fade.inRampType)
        }

        var outTime = fade.outTime
        if outTime > 0 {
            // when the start of the fade out should occur
            let timeToFade = (duration - startTime) - (duration - endTime) - outTime
            var outTimeInSamples = inTimeInSamples + AUEventSampleTime(timeToFade * sampleRate)
            var outOffset: AUEventSampleTime = 0

            if fade.outTimeOffset > 0, fade.outTimeOffset > duration - outTime {
                // just fade now the remainder of the segment
                var newOutTime = duration - startTime
                if endTime < duration {
                    newOutTime -= (duration - endTime)
                }

                AKLog("In middle of a fade out... adjusted outTime to", newOutTime)

                outTimeInSamples = 0

                let ratio = newOutTime / outTime
                let fadeFrom = fade.maximumGain * ratio
                faderNode.addAutomationPoint(value: fadeFrom, at: outTimeInSamples, anchorTime: audioTime.sampleTime, rampDuration: AUAudioFrameCount(0), rampType: fade.inRampType)

                outTime = newOutTime
                outOffset = 512

            } else if inTime == 0 {
                AKLog("reset to ", fade.maximumGain, "if there is no fade in or are past it")
                //inTimeInSamples
                faderNode.addAutomationPoint(value: fade.maximumGain, at: AUEventSampleTimeImmediate, anchorTime: audioTime.sampleTime, rampDuration: AUAudioFrameCount(0), rampType: fade.inRampType)
            }
            let fadeLengthInSamples = AUAudioFrameCount(outTime * sampleRate)
            let value = Fade.minimumGain

            AKLog("Scheduling fade OUT (\(outTime) sec) to value:", value, "at outTimeInSamples", outTimeInSamples, "fadeLengthInSamples", fadeLengthInSamples)
            faderNode.addAutomationPoint(value: value, at: outTimeInSamples + outOffset, anchorTime: audioTime.sampleTime, rampDuration: fadeLengthInSamples, rampType: fade.outRampType)
        }


    }

//    internal func resetFader(_ state: Bool) {
//        guard let faderNode = faderNode else { return }
//        var state = state
//        if fade.inTime == 0 {
//            state = true
//        }
//        faderNode.rampType = fade.inRampType
//        faderNode.rampDuration = AKSettings.rampDuration
//        faderNode.gain = state ? fade.maximumGain : Fade.minimumGain
//
//        //faderNode.automationEnabled = false
//    }

    /*
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

            faderNode.addAutomationPoint(value: Fade.minimumGain, at: AUEventSampleTimeImmediate, rampDuration: 0)
            faderNode.addAutomationPoint(value: value, at: AUEventSampleTimeImmediate, rampDuration: rampSamples)

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
            faderNode.addAutomationPoint(value: value, at: AUEventSampleTimeImmediate, rampDuration: rampSamples)
        }
    }
    */
}
