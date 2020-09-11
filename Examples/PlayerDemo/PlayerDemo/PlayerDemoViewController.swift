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

    var audioFile: AVAudioFile? {
        player?.audioFile
    }

    var tempFile: URL?

    var isPlaying: Bool = false
    var wasPlaying: Bool = false

    lazy var mixer = AKMixer()

    var mainTimer = TimerFactory.createTimer(type: .displayLink)
    var startTime = AVAudioTime.now()

    // the space before the file and the file itself
    var timelineDuration: TimeInterval {
        waveformView.timelineDuration
    }

    private var _currentTime: TimeInterval = 0

    var currentTime: TimeInterval {
        get { _currentTime }
        set {
            _currentTime = newValue
            waveformView.time = _currentTime
            timeField?.stringValue = formatTimecode(seconds: _currentTime)
        }
    }

    var startOffset: TimeInterval = 0 {
        didSet {
            scheduleOffsetSlider?.doubleValue = startOffset
            waveformView?.startOffset = startOffset
            initInOutSliders()
        }
    }

    var inPoint: TimeInterval = 0 {
        didSet {
            bounceFromSlider?.doubleValue = inPoint
            waveformView?.inPoint = inPoint
        }
    }

    var outPoint: TimeInterval = 0 {
        didSet {
            bounceToSlider?.doubleValue = outPoint
            waveformView?.outPoint = outPoint
        }
    }

    lazy var openPanel: NSOpenPanel = {
        let panel = NSOpenPanel()
        panel.appearance = view.window?.appearance
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedFileTypes = AKConverter.inputFormats
        return panel
    }()

    lazy var savePanel: NSSavePanel = {
        let panel = NSSavePanel()
        panel.appearance = view.window?.appearance
        panel.allowedFileTypes = AKConverter.outputFormats
        return panel
    }()

    public convenience init() {
        self.init(nibName: "PlayerDemoViewController", bundle: Bundle.main)

        mainTimer.eventHandler = updateTime

        AKSettings.sampleRate = 48000 // arbritary, but PinkNoise is 48k

        // setup signal chain
        engine.output = mixer

        do {
            try engine.start()
        } catch let error as NSError {
            AKLog(error.localizedDescription, type: .error)
            return
        }

        AKLog(AKSettings.audioFormat)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        waveformView?.delegate = self

        // openPinkNoise()
        open(url: URL(fileURLWithPath: "/Users/rf/Desktop/ADD Files/_Audio/12345/12345.wav"))
    }

    private func initSliders() {
        guard let duration = player?.duration else { return }

        fadeInTimeSlider?.minValue = 0
        fadeInTimeSlider?.maxValue = duration / 2
        fadeInTimeSlider?.doubleValue = 0

        fadeOutTimeSlider?.minValue = 0
        fadeOutTimeSlider?.maxValue = duration / 2
        fadeOutTimeSlider?.doubleValue = 0

        for slider in fadeSliders {
            handleFadeSliderChange(slider)
        }

        initInOutSliders()

        scheduleOffsetSlider?.doubleValue = 0
        handleScheduledOffsetChange(scheduleOffsetSlider)
    }

    private func initInOutSliders() {
        guard let duration = player?.duration else { return }

        bounceToSlider?.minValue = 0
        bounceToSlider?.maxValue = duration + startOffset
        bounceToSlider?.doubleValue = duration + startOffset
        handleBounceToChange(bounceToSlider)

        bounceFromSlider?.minValue = 0
        bounceFromSlider?.maxValue = duration + startOffset
        bounceFromSlider?.doubleValue = 0
        handleBounceFromChange(bounceFromSlider)
    }

    func openPinkNoise() {
        guard let url = Bundle.main.resourceURL?.appendingPathComponent("PinkNoise.wav") else { return }
        open(url: url)
    }

    func open(url: URL) {
        AKLog("Opening", url)

        guard let audioFile = try? AVAudioFile(forReading: url) else {
            AKLog("Failed to open", url, type: .error)
            return
        }
        open(audioFile: audioFile)
    }

    func open(audioFile: AVAudioFile) {
        if player != nil {
            player?.disconnectOutput()
            player?.detach()
            player = nil
        }
        pathControl?.url = audioFile.url
        let filename = audioFile.url.deletingPathExtension().lastPathComponent

        view.window?.title = filename

        if tempFile == nil {
            tempFile = audioFile.url.deletingLastPathComponent()
                .appendingPathComponent(filename + "_TEMP.caf")
        }

        let player = AKDynamicPlayer(audioFile: audioFile)
        player.connect(to: mixer)
        self.player = player

        waveformView?.open(url: audioFile.url)

        DispatchQueue.main.async {
            self.currentTime = 0
            self.initSliders()
        }
    }

    func play() {
        if !engine.isRunning {
            try? engine.start()

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
        isPlaying = true
        startTime = AVAudioTime.now().offset(seconds: -currentTime)

        let playTime: Double = startOffset - currentTime

        AKLog("playTime", playTime)

        // the start point is inside the region or at zero, so play immediately from the present location
        if playTime < 0 {
            player?.offsetTime = -playTime

            player?.play(from: -playTime,
                         to: 0,
                         when: 0,
                         hostTime: nil)

        } else {
            player?.offsetTime = 0

            player?.play(from: 0,
                         to: 0,
                         when: playTime,
                         hostTime: nil)
        }

        mainTimer.resume()
    }

    func rewind() {
        stop()
        DispatchQueue.main.async {
            self.currentTime = self.inPoint
        }
    }

    func stop() {
        AKLog("⏹")
        isPlaying = false
        player?.stop()
        mainTimer.suspend()

        DispatchQueue.main.async {
            self.playButton?.state = .off
        }
    }

    func bounce(to url: URL, duration: Double, prerender: (() -> Void)?) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                if let file = try? AVAudioFile(forWriting: url, settings: AKSettings.audioFormat.settings) {
                    try engine.renderToFile(file, duration: duration, prerender: {
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

    func extractSelection(to url: URL) {
        guard let audioFile = audioFile,
            let selection = waveformView?.selection else { return }

        audioFile.extract(to: url,
                          from: selection.startTime,
                          to: selection.endTime,
                          fadeInTime: 0.01,
                          fadeOutTime: 0.01,
                          options: nil) { error in

            if let error = error {
                AKLog(error, type: .error)
            } else {
                AKLog("Extracted", selection, "to", url)
            }
        }
    }
}

// Timer stuff
extension PlayerDemoViewController {
    func updateTime() {
        guard isPlaying else { return }

        let currentTime = AVAudioTime.now()

        // Find the difference between current time and start time.
        guard let elapsedTime = currentTime.timeIntervalSince(otherTime: startTime) else {
            // Log.debug("Invalid time interval")
            return
        }
        DispatchQueue.main.async {
            if elapsedTime > self.timelineDuration {
                self.rewind()
                return
            }
            self.currentTime = elapsedTime
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

    func updateSlidersFromWaveform(source: WaveformView) {
        bounceFromSlider?.doubleValue = source.selection.startTime
        bounceToSlider?.doubleValue = source.selection.endTime

        handleBounceToChange(bounceToSlider)
        handleBounceFromChange(bounceFromSlider)
    }
}

extension PlayerDemoViewController: WaveformViewDelegate {
    func waveformSelected(source: WaveformView, at time: Double) {
        wasPlaying = isPlaying
        stop()
        currentTime = time
    }

    func waveformScrubbed(source: WaveformView, at time: Double) {
        currentTime = time
    }

    func waveformScrubComplete(source: WaveformView, at time: Double) {
        updateSlidersFromWaveform(source: source)
        currentTime = inPoint

        if wasPlaying {
            play()
        }
    }
}

func delayed(by delay: Double, closure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        closure()
    }
}
