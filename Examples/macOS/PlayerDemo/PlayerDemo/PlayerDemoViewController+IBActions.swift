//
//  PlayerDemoViewController+IBActions.swift
//  PlayerDemo
//
//  Created by Ryan Francesconi on 7/28/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import AudioKit
import Cocoa

/// IBActions
extension PlayerDemoViewController {
    @IBAction func openDocument(_ sender: AnyObject) {
        handleChooseButton()
    }

    // since this are non linear edits, still need to implement the buffer edits
//    @IBAction func delete(_ sender: AnyObject) {
//        guard let selection = waveformView?.selection else { return }
//        AKLog("TODO", selection)
//    }
//
//    @IBAction func cut(_ sender: AnyObject) {
//        guard let selection = waveformView?.selection else { return }
//        AKLog("TODO", selection)
//    }
//
//    @IBAction func copy(_ sender: AnyObject) {
//        guard let selection = waveformView?.selection else { return }
//        AKLog("TODO", selection)
//    }
//
//    @IBAction func paste(_ sender: AnyObject) {
//        guard let selection = waveformView?.selection else { return }
//        AKLog("TODO", selection)
//    }

    @IBAction func crop(_ sender: AnyObject) {
        guard let tempFile = tempFile,
            let audioFile = audioFile,
            let selection = waveformView?.selection else { return }

        if FileManager.default.fileExists(atPath: tempFile.path) {
            try? FileManager.default.removeItem(at: tempFile)
        }

        guard let croppedFile = audioFile.extract(to: tempFile,
                                                  from: selection.startTime,
                                                  to: selection.endTime) else {
            AKLog("Error cropping file to", tempFile)
            return
        }
        AKLog("Cropped to", selection)

        registerUndoEdit()
        open(audioFile: croppedFile)
    }

    @IBAction override func selectAll(_ sender: Any?) {
        inPoint = 0
        outPoint = timelineDuration
        currentTime = 0
    }
}

// Undo handlers will go in here.
extension PlayerDemoViewController {
    func registerUndoEdit() {
        guard let um = view.window?.undoManager,
            let url = audioFile?.url else { return }
        let target = um.prepare(withInvocationTarget: self) as AnyObject

        target.undoEdit(url: url)
        um.setActionName("Edit")
    }

    @objc func undoEdit(url: URL) {
        registerUndoEdit()

        open(url: url)
    }
}

extension PlayerDemoViewController {
    @IBAction func resetAudio(_ sender: NSButton) {
        openPinkNoise()
    }

    @IBAction func handleChooseButton(_ sender: NSButton? = nil) {
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

        initSavePanel(name: "Bounced", pathExtension: "caf", message: "Bounce your selection")

        savePanel.beginSheetModal(for: window) { response in
            if response == .OK, let url = self.savePanel.url {
                self.bounce(to: url, duration: bounceDuration, prerender: {
                    self.play()
                })
            }
        }
    }

    @IBAction func handleExtract(_ sender: Any) {
        guard let window = view.window else { return }

        stop()

        initSavePanel(name: "Extracted", message: "Extract your selection")

        savePanel.beginSheetModal(for: window) { response in
            if response == .OK, let url = self.savePanel.url {
                self.extractSelection(to: url)
            }
        }
    }

    private func initSavePanel(name: String, pathExtension: String? = nil, message: String? = nil) {
        guard let url = audioFile?.url else { return }

        let pathExtension = pathExtension ?? url.pathExtension
        let directory = url.deletingLastPathComponent()
        let filename = url.deletingPathExtension().lastPathComponent
        savePanel.nameFieldStringValue = filename + " \(name)." + pathExtension
        savePanel.directoryURL = directory
        savePanel.message = message ?? ""
    }

    @IBAction func terminate(_ sender: Any? = nil) {
        deleteTempFile()
        exit(0)
    }

    private func deleteTempFile() {
        guard let tempFile = tempFile,
            FileManager.default.fileExists(atPath: tempFile.path) else {
            AKLog("No temp file found to delete.")
            return
        }

        try? FileManager.default.removeItem(at: tempFile)
    }
}
