//
//  PlayerDemoViewController.swift
//  PlayerDemo
//
//  Created by Ryan Francesconi on 7/26/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import AudioKit
import AudioKitUI
import Cocoa

class PlayerDemoViewController: NSViewController {
    @IBOutlet var playButton: NSButton!
    @IBOutlet var bounceButton: NSButton!
    @IBOutlet var timeField: NSTextField!

    @IBOutlet var scheduleField: NSTextField!
    @IBOutlet var bounceFromField: NSTextField!
    @IBOutlet var bounceToField: NSTextField!

    @IBOutlet var scheduleOffsetSlider: NSSlider!
    @IBOutlet var bounceFromSlider: NSSlider!
    @IBOutlet var bounceToSlider: NSSlider!

    @IBOutlet var pathControl: NSPathControl!
    @IBOutlet var waveformView: WaveformView!

    @IBOutlet var fadeInTimeSlider: NSSlider!
    @IBOutlet var fadeInTaperSlider: NSSlider!
    @IBOutlet var fadeInSkewSlider: NSSlider!

    @IBOutlet var fadeOutTimeSlider: NSSlider!
    @IBOutlet var fadeOutTaperSlider: NSSlider!
    @IBOutlet var fadeOutSkewSlider: NSSlider!

    private var fadeSliders: [NSSlider] {
        [fadeInTimeSlider, fadeInTaperSlider, fadeInSkewSlider,
         fadeOutTimeSlider, fadeOutTaperSlider, fadeOutSkewSlider]
    }

    var player: AKDynamicPlayer?
    lazy var mixer = AKMixer()

    var mainTimer = TimerFactory.createTimer(type: .displayLink)
    var startTime = AVAudioTime.now()

    var currentTime: TimeInterval {
        waveformView.time
    }

    var startOffset: TimeInterval {
        scheduleOffsetSlider.doubleValue
    }

    var inPoint: TimeInterval {
        bounceFromSlider.doubleValue
    }

    var outPoint: TimeInterval {
        bounceToSlider.doubleValue
    }

    lazy var openPanel: NSOpenPanel = {
        let panel = NSOpenPanel()
        panel.appearance = view.window?.appearance
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedFileTypes = ["aac", "caf", "aif", "aiff",
                                  "aifc", "m4v", "mov", "mp3",
                                  "mp4", "m4a", "snd", "au",
                                  "sd2", "wav"]
        return panel
    }()

    lazy var savePanel: NSSavePanel = {
        let panel = NSSavePanel()
        panel.appearance = view.window?.appearance
        panel.allowedFileTypes = ["caf"]
        return panel
    }()

    public convenience init() {
        self.init(nibName: "PlayerDemoViewController", bundle: Bundle.main)

        mainTimer.eventHandler = updateTime

        AKSettings.sampleRate = 48000 // arbritary, but PinkNoise is 48k

        // setup signal chain
        AKManager.output = mixer

        do {
            try AKManager.start()
        } catch let error as NSError {
            AKLog(error.localizedDescription, type: .error)
            return
        }

        AKLog(AKSettings.audioFormat)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = Bundle.main.resourceURL?.appendingPathComponent("PinkNoise.wav") {
            open(url: url)
        }

        scheduleOffsetSlider?.toolTip = "Schedule the start of playback in the future..."
    }

    func open(url: URL) {
        pathControl?.url = url

        if player != nil {
            player?.disconnectOutput()
            player?.detach()
            player = nil
        }

        guard let audioFile = try? AVAudioFile(forReading: url) else {
            AKLog("Failed to open", url, type: .error)
            return
        }

        scheduleOffsetSlider?.doubleValue = 0
        handleScheduledOffsetChange(scheduleOffsetSlider)

        bounceFromSlider?.doubleValue = 0
        handleBounceFromChange(bounceFromSlider)

        bounceToSlider?.minValue = 0
        bounceToSlider?.maxValue = audioFile.duration
        bounceToSlider?.doubleValue = audioFile.duration
        handleBounceToChange(bounceToSlider)

        let player = AKDynamicPlayer(audioFile: audioFile)
        player.connect(to: mixer)
        player.completionHandler = handleAudioComplete
        self.player = player

        waveformView?.open(audioFile: audioFile)

        initFades()

        // handleScheduledOffsetChange(scheduleOffsetSlider)
    }

    func play() {
        if !AKManager.engine.isRunning {
            try? AKManager.start()

            // the engine doesn't really like starting and playing right away
            delayed(by: 1, closure: {
                self.handlePlay()
            })
            return
        }

        handlePlay()
    }

    private func handlePlay() {
        AKLog("▶️")
        startTime = AVAudioTime.now().offset(seconds: -waveformView.time)

        // where in the file playback is starting
        player?.offsetTime = waveformView.time

        player?.play(from: currentTime,
                     to: 0,
                     when: startOffset,
                     hostTime: nil)

        mainTimer.resume()
    }

    private func initFades() {
        for slider in fadeSliders {
            handleFadeSliderChange(slider)
        }
    }

    private func handleAudioComplete() {
        rewind()
    }

    func rewind() {
        stop()
        waveformView.time = 0
    }

    func stop() {
        AKLog("⏹")
        player?.stop()
        mainTimer.suspend()

        DispatchQueue.main.async {
            self.playButton?.state = .off
        }
    }

    internal func bounce(to url: URL, duration: Double, prerender: (() -> Void)?) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                if let file = try? AVAudioFile(forWriting: url, settings: AKSettings.audioFormat.settings) {
                    try AKManager.renderToFile(file, duration: duration, prerender: {
                        prerender?()
                    })

                    AKLog("Bounced to", url)
                }
                DispatchQueue.main.async {
                    self.rewind()
                }

            } catch let err as NSError {
                AKLog("ERROR:", err, type: .error)
            }
        }
    }
}

/// IBActions
extension PlayerDemoViewController {
    @IBAction func handleScheduledOffsetChange(_ sender: NSSlider) {
        waveformView?.startOffset = sender.doubleValue
        scheduleField?.stringValue = formatTimecode(seconds: sender.doubleValue, includeHours: false)
    }

    @IBAction func handleBounceFromChange(_ sender: NSSlider) {
        waveformView?.inPoint = sender.doubleValue
        bounceFromField?.stringValue = formatTimecode(seconds: sender.doubleValue, includeHours: false)
    }

    @IBAction func handleBounceToChange(_ sender: NSSlider) {
        waveformView?.outPoint = sender.doubleValue
        bounceToField?.stringValue = formatTimecode(seconds: sender.doubleValue, includeHours: false)
    }

    @IBAction func handleChooseButton(_ sender: NSButton) {
        guard let window = view.window else { return }

        openPanel.beginSheetModal(for: window) { response in
            if response == .OK, let url = self.openPanel.url {
                self.open(url: url)
            }
        }
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
        guard let window = view.window, var duration = player?.duration else { return }

        duration += startOffset
        rewind()

        savePanel.beginSheetModal(for: window) { response in
            if response == .OK, let url = self.savePanel.url {
                self.bounce(to: url, duration: duration, prerender: {
                    self.play()
                })
            }
        }
    }
}

// Timer stuff
extension PlayerDemoViewController {
    func updateTime() {
        let currentTime = AVAudioTime.now()

        // Find the difference between current time and start time.
        guard let elapsedTime = currentTime.timeIntervalSince(otherTime: startTime) else {
            // Log.debug("Invalid time interval")
            return
        }
        DispatchQueue.main.async {
            self.waveformView.time = elapsedTime
            self.timeField?.stringValue = self.formatTimecode(seconds: elapsedTime)
        }
    }

    public func formatTimecode(seconds: TimeInterval,
                               frameRate: Float = 100,
                               offset: TimeInterval = 0,
                               includeHours: Bool = false,
                               includeFraction: Bool = true,
                               fractionalDelimiter: String = ".") -> String {
        let sign = seconds < 0 || offset < 0 ? "-" : ""
        var value = abs(seconds + offset)

        let hours = Int(value / 3600)
        value -= (TimeInterval(hours) * 3600)

        // calculate the minutes in elapsed time.
        let minutes = Int(value / 60.0)
        value -= (TimeInterval(minutes) * 60)

        // calculate the seconds in elapsed time.
        let secondsLeft = Int(value)
        value -= TimeInterval(secondsLeft)

        // find out the fraction of milliseconds to be displayed.
        let fraction = Int(value * frameRate)

        let strHours = includeHours ? String(format: "%02d", hours) + ":" : ""
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", secondsLeft)
        let strFraction = includeFraction ? fractionalDelimiter + String(format: "%02d", fraction) : ""
        return sign + strHours + strMinutes + ":" + strSeconds + strFraction
    }
}

func delayed(by delay: Double, closure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        closure()
    }
}
