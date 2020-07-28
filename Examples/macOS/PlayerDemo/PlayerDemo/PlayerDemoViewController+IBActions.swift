//
//  PlayerDemoViewController+IBActions.swift
//  PlayerDemo
//
//  Created by Ryan Francesconi on 7/28/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Cocoa

/// IBActions
extension PlayerDemoViewController {
    @IBAction func resetAudio(_ sender: NSButton) {
        openPinkNoise()
    }

    @IBAction func handleChooseButton(_ sender: NSButton) {
        guard let window = view.window else { return }

        openPanel.beginSheetModal(for: window) { response in
            if response == .OK, let url = self.openPanel.url {
                self.open(url: url)
            }
        }
    }
    
    @IBAction func handleScheduledOffsetChange(_ sender: NSSlider) {
        startOffset = sender.doubleValue

        scheduleField?.stringValue = formatTimecode(seconds: sender.doubleValue, includeHours: false)
    }

    @IBAction func handleBounceFromChange(_ sender: NSSlider) {
        guard sender.doubleValue < bounceToSlider.doubleValue else {
            sender.doubleValue = bounceToSlider.doubleValue - 0.5
            return
        }

        inPoint = sender.doubleValue
        bounceFromField?.stringValue = formatTimecode(seconds: sender.doubleValue, includeHours: false)
    }

    @IBAction func handleBounceToChange(_ sender: NSSlider) {
        guard sender.doubleValue > bounceFromSlider.doubleValue else {
            sender.doubleValue = bounceFromSlider.doubleValue + 0.5
            return
        }

        outPoint = sender.doubleValue
        bounceToField?.stringValue = formatTimecode(seconds: sender.doubleValue, includeHours: false)
    }

    @IBAction func handlePlayButton(_ sender: NSButton) {
        let state = sender.state == .on
        state ? play() : stop()
    }

    @IBAction func handleRewindButton(_ sender: NSButton) {
        rewind()
    }

    @IBAction func handleFadeSliderChange(_ sender: NSSlider) {
        guard let player = player else { return }

        switch sender {
        case fadeInTimeSlider:
            player.fade.inTime = sender.doubleValue
            waveformView?.fadeInTime = player.fade.inTime
        case fadeOutTimeSlider:
            player.fade.outTime = sender.doubleValue
            waveformView?.fadeOutTime = player.fade.outTime

        case fadeInTaperSlider:
            player.fade.inTaper = sender.floatValue
        case fadeOutTaperSlider:
            player.fade.outTaper = sender.floatValue

        case fadeInSkewSlider:
            player.fade.inSkew = sender.floatValue
        case fadeOutSkewSlider:
            player.fade.outSkew = sender.floatValue
        default:
            break
        }
    }

    @IBAction func handleBounce(_ sender: Any) {
        guard let window = view.window else { return }

        stop()

        let bounceDuration = outPoint - inPoint
        currentTime = inPoint

        savePanel.beginSheetModal(for: window) { response in
            if response == .OK, let url = self.savePanel.url {
                self.bounce(to: url, duration: bounceDuration, prerender: {
                    self.play()
                })
            }
        }
    }
}
