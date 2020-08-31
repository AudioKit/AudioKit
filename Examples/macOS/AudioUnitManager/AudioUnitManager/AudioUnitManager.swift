//
//  AudioUnitManager
//
//  Created by Ryan Francesconi, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import AVFoundation
import Cocoa

/// An Example of how to create an AudioUnit Host application.
/// This is also a demo for how to use AKPlayer.
class AudioUnitManager: NSViewController {
    public static var appearance: NSAppearance? {
        if #available(macOS 10.14, *) {
            return NSAppearance(named: .darkAqua)
        } else {
            return NSAppearance(named: .vibrantDark)
        }
    }

    let akInternals = "AudioKit ★"
    let windowPrefix = "FX"

    @IBOutlet var effectsContainer: NSView!
    @IBOutlet var waveformContainer: NSView!
    @IBOutlet var timeField: NSTextField!
    @IBOutlet var playButton: NSButton!
    @IBOutlet var rewindButton: NSButton!
    @IBOutlet var loopButton: NSButton!
    @IBOutlet var audioBufferedButton: NSButton!
    @IBOutlet var audioReversedButton: NSButton!
    @IBOutlet var audioNormalizedButton: NSButton!
    @IBOutlet var instrumentPlayButton: NSButton!
    @IBOutlet var fileField: NSTextField!
    @IBOutlet var fmButton: NSButton!
    @IBOutlet var auInstrumentSelector: NSPopUpButton!
    @IBOutlet var midiDeviceSelector: NSPopUpButton!

    internal var lastMIDIEvent: Int = 0
    internal var audioTimer: Timer?
    internal var audioPlaying: Bool = false
    internal var openPanel: NSOpenPanel?
    internal var internalManager = AKAudioUnitManager(inserts: 6)
    internal var windowControllers = [AudioUnitGenericWindow?](repeating: nil, count: 6)
    internal var midiManager: AKMIDI?
    internal var player: AKPlayer?
    internal var waveform: WaveformView?
    internal var fmOscillator = AKFMOscillator()
    internal var mixer = AKMixer()
    internal var testPlayer: InstrumentPlayer?
    internal var fmTimer: Timer?
    internal var auInstrument: AKAudioUnitInstrument?
    internal var windowPositions = [String: NSPoint]()

    internal var peak: AVAudioPCMBuffer.Peak?

    public var isLooping: Bool {
        return loopButton.state == .on
    }

    public var isBuffered: Bool {
        return audioBufferedButton.state == .on
    }

    public var isNormalized: Bool {
        return audioNormalizedButton.state == .on
    }

    public var audioEnabled: Bool = false {
        didSet {
            audioReversedButton.isEnabled = audioEnabled
            playButton.isEnabled = audioEnabled
            rewindButton.isEnabled = audioEnabled
            loopButton.isEnabled = audioEnabled
            audioBufferedButton.isEnabled = audioEnabled
            audioNormalizedButton.isEnabled = audioEnabled
        }
    }

    // MARK: - init

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }

    @objc func handleApplicationInit() {
        view.window?.delegate = self
        view.window?.appearance = AudioUnitManager.appearance
        view.appearance = AudioUnitManager.appearance
    }

    func initialize() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AudioUnitManager.handleApplicationInit),
                                               name: Notification.Name("AudioUnitManager.handleApplicationInit"),
                                               object: nil)
        let mainOutput = AKMixer()
        mixer.connect(to: mainOutput)
        engine.output = mainOutput

        initManager()
        initMIDI()
        audioEnabled = false
    }

    internal func startEngine(completionHandler: AKCallback? = nil) {
        AKLog("* engine.isRunning: \(engine.isRunning)")

        if !engine.isRunning {
            do {
                try engine.start()
            } catch {
                AKLog("AudioKit did not start!")
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                AKLog("Firing completionHandler...")
                completionHandler?()
            }
            return
        }
        completionHandler?()
    }

    // MARK: - Event Handlers

    @IBAction func openDocument(_ sender: AnyObject) {
        chooseAudio(sender)
    }

    @IBAction func closeDocument(_ sender: AnyObject) {
        close()
    }

    @IBAction func handleLoopButton(_ sender: NSButton) {
        let state = sender.state == .on
        guard let player = player else { return }
        guard let waveform = waveform else { return }

        let wasPlaying = player.isPlaying

        if wasPlaying {
            handlePlay(state: false)
        }

        player.isLooping = state
        waveform.isLooping = state
        audioBufferedButton.state = player.isBuffered ? .on : .off

        if !state {
            player.startTime = 0
            player.endTime = player.duration
        }

        if wasPlaying {
            DispatchQueue.main.async {
                self.handlePlay(state: true)
            }
        }
    }

    @IBAction func handleNormalizedButton(_ sender: NSButton) {
        guard let player = player else { return }

        player.buffering = sender.state == .on ? .always : .dynamic
        audioBufferedButton.state = sender.state
        player.isNormalized = sender.state == .on
    }

    @IBAction func handleBufferedButton(_ sender: NSButton) {
        player?.buffering = sender.state == .on ? .always : .dynamic
    }

    @IBAction func handleReversedButton(_ sender: NSButton) {
        guard let player = player else { return }
        guard let waveform = waveform else { return }

        AKLog("handleReversedButton() \(sender.state == .on)")
        let wasPlaying = player.isPlaying
        if wasPlaying {
            handlePlay(state: false)
        }
        player.isReversed = sender.state == .on
        waveform.isReversed = sender.state == .on
        audioBufferedButton.state = player.isBuffered ? .on : .off

        if wasPlaying {
            handlePlay(state: true)
        }
    }

    @IBAction func handleRewindButton(_ sender: NSButton) {
        handleRewind()
    }

    @IBAction func handlePlayButton(_ sender: NSButton) {
        handlePlay(state: sender.state == .on)
    }

    @IBAction func chooseAudio(_ sender: Any) {
        guard let window = view.window else { return }
        AKLog("chooseAudio()")
        if openPanel == nil {
            openPanel = NSOpenPanel()
            openPanel?.appearance = view.appearance
            openPanel?.message = "Open Audio File"
            openPanel?.allowedFileTypes = EZAudioFile.supportedAudioFileTypes() as? [String]
        }
        openPanel?.beginSheetModal(for: window, completionHandler: { response in
            if response == NSApplication.ModalResponse.OK {
                if let url = self.openPanel?.url {
                    self.open(url: url)
                }
            }
        })
    }

    @IBAction func handleMidiDeviceSelected(_ sender: NSPopUpButton) {
        midiManager?.openInput(index: sender.indexOfSelectedItem)
    }

    @IBAction func handleInstrumentSelected(_ sender: NSPopUpButton) {
        guard let auname = sender.titleOfSelectedItem else { return }

        if auname == "-" {
            // dispose the old one?
            removeInstrument()
            return
        }

        internalManager.createInstrument(name: auname, completionHandler: { audioUnit in
            guard let audioUnit = audioUnit else { return }

            AKLog("* \(audioUnit.name) : Audio Unit created")

            self.auInstrument = AKAudioUnitInstrument(audioUnit: audioUnit)

            if self.auInstrument == nil {
                return
            }
            self.internalManager.connectEffects(firstNode: self.auInstrument, lastNode: self.mixer)
            DispatchQueue.main.async {
                self.showAudioUnit(audioUnit, identifier: 6)
                self.instrumentPlayButton.isEnabled = true
            }
        })
    }

    fileprivate func removeInstrument() {
        auInstrument?.detach()
        auInstrument = nil
        instrumentPlayButton.isEnabled = false
        getWindowFromIndentifier(6)?.close()
    }

    @IBAction func handleShowAudioUnit(_ sender: NSButton) {
        let auIndex = sender.tag
        AKLog("handleShowAudioUnit() \(auIndex)")
        let state = sender.state == .on
        showEffect(at: auIndex, state: state)
    }

    @IBAction func handleInstrumentPlayButton(_ sender: NSButton) {
        guard auInstrument != nil else { return }

        startEngine {
            if self.fmOscillator.isStarted {
                self.fmButton.state = .off
                self.fmOscillator.stop()
            }

            if self.player?.isPlaying ?? false {
                self.handlePlay(state: false)
            }

            if sender.state == .off {
                self.testAUInstrument(state: false)
            } else {
                self.testAUInstrument(state: true)
            }
        }
    }

    @IBAction func handleFMButton(_ sender: NSButton) {
        if player?.isPlaying ?? false {
            handlePlay(state: false)
        }

        if auInstrument != nil {
            instrumentPlayButton.state = .off
        }

        playFM(state: sender.state == .on)
    }
}

/// Handle Window Events
extension AudioUnitManager: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let w = notification.object as? NSWindow {
            if w == view.window {
                internalManager.reset()
                do {
                    try engine.stop()
                } catch {
                    AKLog("AudioKit did not stop!")
                }
                exit(0)
            }

            if let winId = w.identifier?.rawValue {
                // store the location of this window so can reshow at same location
                windowPositions[winId] = w.frame.origin
                AKLog("\(winId) : Plug in window closing")

                if let tag = Int(winId.replacingOccurrences(of: windowPrefix, with: "")) {
                    if let b = getEffectsButtonFromIdentifier(tag) {
                        b.state = .off
                    }
                }
            }
        }
    }
}
