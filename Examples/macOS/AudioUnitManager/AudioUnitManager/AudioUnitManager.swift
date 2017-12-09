//
//  AudioUnitManager
//
//  Created by Ryan Francesconi on 7/14/17.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Cocoa
import AVFoundation
import AudioKit

/// An Example of how to create an AudioUnit Host application.
/// This is also a demo for how to use AKPlayer.
class AudioUnitManager: NSViewController {

    let akInternals = "AudioKit ★"
    let windowPrefix = "FX"

    @IBOutlet weak var effectsContainer: NSView!
    @IBOutlet weak var waveformContainer: NSView!
    @IBOutlet weak var timeField: NSTextField!
    @IBOutlet weak var playButton: NSButton!
    @IBOutlet weak var rewindButton: NSButton!
    @IBOutlet weak var loopButton: NSButton!
    @IBOutlet weak var audioBufferedButton: NSButton!
    @IBOutlet weak var audioReversedButton: NSButton!
    @IBOutlet weak var instrumentPlayButton: NSButton!
    @IBOutlet weak var fileField: NSTextField!
    @IBOutlet weak var fmButton: NSButton!
    @IBOutlet weak var auInstrumentSelector: NSPopUpButton!
    @IBOutlet weak var midiDeviceSelector: NSPopUpButton!

    fileprivate var lastMIDIEvent: Int = 0

    internal var audioTimer: Timer?
    internal var audioPlaying: Bool = false
    internal var openPanel: NSOpenPanel?
    internal var internalManager: AKAudioUnitManager?
    internal var midiManager: AKMIDI?
    internal var player: AKPlayer?
    internal var waveform: AKWaveform?
    internal var fmOscillator: AKFMOscillator?
    internal var mixer: AKMixer?
    internal var auInstrument: AKAudioUnitInstrument? {
        didSet {
            guard auInstrument != nil else { return }
        }
    }

    var testPlayer: InstrumentPlayer?

    fileprivate var fmTimer: Timer?

    public var audioEnabled: Bool = false {
        didSet {
            audioBufferedButton.isEnabled = audioEnabled
            audioReversedButton.isEnabled = audioEnabled
            playButton.isEnabled = audioEnabled
            rewindButton.isEnabled = audioEnabled
            loopButton.isEnabled = audioEnabled
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }

    @objc func handleApplicationInit() {
        view.window?.delegate = self
    }

    func initialize() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AudioUnitManager.handleApplicationInit),
                                               name: Notification.Name("AudioUnitManager.handleApplicationInit"),
                                               object: nil)
        fmOscillator = AKFMOscillator()
        mixer = AKMixer()
        let mainOutput = AKMixer()
        mixer?.connect(to: mainOutput)
        AudioKit.output = mainOutput

        initManager()
        initMIDI()
        initUI()
        audioEnabled = false
    }

    private func initMIDI() {
        midiManager = AudioKit.midi
        midiManager?.addListener(self)
        initMIDIDevices()
    }

    fileprivate func initMIDIDevices() {
        guard let devices = midiManager?.inputNames else { return }

        if devices.count > 0 {
            midiDeviceSelector.removeAllItems()
            midiManager?.openInput(devices[0])

            for device in devices {
                AKLog("MIDI Device: \(device)")
                midiDeviceSelector.addItem(withTitle: device)
            }
        }
    }

    internal func startEngine(completionHandler: AKCallback? = nil) {
        AKLog("engine.isRunning: \(AudioKit.engine.isRunning)")
        if !AudioKit.engine.isRunning {
            AudioKit.start()

//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                completionHandler?()
//            }
//            return
        }
        completionHandler?()
    }

    @IBAction func openDocument(_ sender: AnyObject) {
        chooseAudio(sender)
    }

    @IBAction func closeDocument(_ sender: AnyObject) {
        close()
    }

    @IBAction func handleLoopButton(_ sender: NSButton) {
        let state = sender.state == .on
        sender.title = state ? "🔄" : "➡️"
        player?.isLooping = state
        waveform?.isLooping = state
    }

    @IBAction func handleBufferedButton(_ sender: NSButton) {
        player?.buffering = sender.state == .on ? .always : .dynamic
    }

    @IBAction func handleReversedButton(_ sender: NSButton) {
        guard player != nil else { return }
        guard waveform != nil else { return }
        let wasPlaying = player!.isPlaying
        if wasPlaying {
            handlePlayButton(playButton)
        }
        player!.isReversed = sender.state == .on
        waveform!.isReversed = sender.state == .on
        audioBufferedButton.isEnabled = !waveform!.isReversed

        if wasPlaying {
            handlePlayButton(playButton)
        }
    }

    //
    @IBAction func handleRewindButton(_ sender: Any) {
        player?.startTime = 0
        waveform?.position = 0
    }

    @IBAction func handlePlayButton(_ sender: NSButton) {
        guard let player = player else { return }

        if fmOscillator != nil && fmOscillator!.isStarted {
            fmButton!.state = .off
            fmOscillator!.stop()
        }

        if auInstrument != nil {
            instrumentPlayButton.title = "▶️"
        }

        if playButton.title == "⏹" {
            player.stop()
            sender.title = "▶️"

            if AudioKit.engine.isRunning {
                //AudioKit.stop()
                internalManager?.reset()
            }

            stopAudioTimer()

        } else {
            if internalManager?.input != player {
                internalManager!.connectEffects(firstNode: player, lastNode: mixer)
            }
            startEngine(completionHandler: {
                player.volume = 1
                player.play(from: self.waveform?.position ?? 0)
                sender.title = "⏹"
                self.startAudioTimer()
            })
        }
    }

    @IBAction func chooseAudio(_ sender: Any) {
        guard let window = view.window else { return }
        AKLog("chooseAudio()")
        if openPanel == nil {
            openPanel = NSOpenPanel()
            openPanel!.message = "Open Audio File"
            openPanel!.allowedFileTypes = EZAudioFile.supportedAudioFileTypes() as? [String]
        }
        openPanel!.beginSheetModal( for: window, completionHandler: { response in
            if response.rawValue == NSFileHandlingPanelOKButton {
                if let url = self.openPanel?.url {
                    self.open(url: url)
                }
            }
        })
    }


    @IBAction func handleMidiDeviceSelected(_ sender: NSPopUpButton) {
        if let device = sender.titleOfSelectedItem {
            midiManager?.openInput(device)
        }
    }

    @IBAction func handleInstrumentSelected(_ sender: NSPopUpButton) {
        guard internalManager != nil else { return }
        guard let auname = sender.titleOfSelectedItem else { return }

        if auname == "-" {
            // dispose the old one?
            removeInstrument()
            return
        }

        internalManager!.createInstrument(name: auname, completionHandler: { audioUnit in
            guard let audioUnit = audioUnit else { return }

            AKLog("* \(audioUnit.name) : Audio Unit created")

            self.auInstrument = AKAudioUnitInstrument(audioUnit: audioUnit)

            if self.auInstrument == nil {
                return
            }
            self.internalManager?.connectEffects(firstNode: self.auInstrument, lastNode: self.mixer )
            self.showAudioUnit(audioUnit, identifier: 6)
            DispatchQueue.main.async {
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
        guard internalManager != nil else { return }
        let auIndex = sender.tag
        AKLog("handleShowAudioUnit() \(auIndex)")
        let state = sender.state == .on
        showEffect(at: auIndex, state: state)
    }

    @IBAction func handleInstrumentPlayButton(_ sender: NSButton) {
        guard auInstrument != nil else { return }

        startEngine(completionHandler: {
            if self.fmOscillator != nil && self.fmOscillator!.isStarted {
                self.fmButton!.state = .off
                self.fmOscillator!.stop()
            }

            if self.player?.isPlaying ?? false {
                self.handlePlayButton(self.playButton)
            }

            if sender.title == "⏹" {
                self.testAUInstrument(state: false)
                sender.title = "▶️"
            } else {
                self.testAUInstrument(state: true)
                sender.title = "⏹"
            }

        })
    }

    @IBAction func handleFMButton(_ sender: NSButton) {
        guard let fm = fmOscillator else { return }

        if player?.isPlaying ?? false {
            handlePlayButton(playButton)
        }

        if auInstrument != nil {
            instrumentPlayButton.title = "▶️"
        }

        if sender.state == .on {
            initFM()

        } else if fm.isStarted {
            fm.stop()

            if fmTimer != nil && fmTimer!.isValid {
                fmTimer!.invalidate()
            }
        }
    }

    func initFM() {
        guard internalManager != nil else { return }
        guard mixer != nil else { return }
        guard let fm = fmOscillator else { return }

        AKLog("initFM()")

        internalManager!.connectEffects(firstNode: fm, lastNode: mixer)

        if fmTimer != nil && fmTimer!.isValid {
            fmTimer!.invalidate()
        }

        startEngine(completionHandler: {
            fm.start()
            self.fmTimer = Timer.scheduledTimer(timeInterval: 0.2,
                                                target: self,
                                                selector: #selector(self.randomFM),
                                                userInfo: nil,
                                                repeats: true)
        })
    }

    @objc func randomFM() {
        let noteNumber = randomNumber(range: 0...127)
        let frequency = AKPolyphonicNode.tuningTable.frequency(forNoteNumber: MIDINoteNumber(noteNumber))
        fmOscillator!.baseFrequency = Double(frequency)
        fmOscillator!.carrierMultiplier = Double(randomNumber(range: 10...100)) / 100
        fmOscillator!.amplitude = Double(randomNumber(range: 10...100)) / 100
        //AKLog("\(fm!.baseFrequency)")
    }

    func randomNumber(range: ClosedRange<Int> = 100...500) -> Int {
        let min = range.lowerBound
        let max = range.upperBound
        return Int(arc4random_uniform(UInt32(1 + max - min))) + min
    }

    open func testAUInstrument(state: Bool) {
        AKLog("\(state)")
        guard auInstrument != nil else { return }

        if state {
            internalManager!.connectEffects(firstNode: auInstrument!, lastNode: mixer)
            testPlayer = InstrumentPlayer(audioUnit: auInstrument!.midiInstrument?.auAudioUnit)
            testPlayer?.play()
        } else {
            testPlayer?.stop()
        }
    }

    internal func updateInstrumentsUI( audioUnits: [AVAudioUnitComponent] ) {
        guard internalManager != nil else { return }

        auInstrumentSelector.removeAllItems()
        auInstrumentSelector.addItem(withTitle: "-")

        for component in audioUnits where component.name != "" {
            auInstrumentSelector.addItem(withTitle: component.name)
        }
    }

}

extension AudioUnitManager: AKMIDIListener {
    /// MIDI Setup has changed
    public func receivedMIDISetupChange() {
        initMIDIDevices()
    }

    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        let currentTime: Int = Int(mach_absolute_time())

        // AKMIDI is sending duplicate noteOn messages??, don't let them be sent too quickly
        let sinceLastEvent = currentTime - lastMIDIEvent
        let isDupe = sinceLastEvent < 300_000

        if auInstrument != nil {
            if !isDupe {
                auInstrument!.play(noteNumber: noteNumber, velocity: velocity, channel: channel)
            } else {
                //AKLog("Duplicate noteOn message sent")
            }
        } else if fmOscillator != nil {
            if !fmOscillator!.isStarted {
                fmOscillator!.start()
            }

            if fmTimer != nil && fmTimer!.isValid {
                fmTimer?.invalidate()
            }
            let frequency = AKPolyphonicNode.tuningTable.frequency(forNoteNumber: noteNumber)
            fmOscillator!.baseFrequency = frequency
        }
        lastMIDIEvent = currentTime
    }

    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        if auInstrument != nil {
            auInstrument!.stop(noteNumber: noteNumber, channel: channel)

        } else if fmOscillator != nil {
            if fmOscillator!.isStarted {
                fmOscillator!.stop()
            }
        }
    }
}

/// Handle Window Events
extension AudioUnitManager: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let w = notification.object as? NSWindow {
            if w == view.window {
                internalManager?.reset()
                AudioKit.stop()
                exit(0)
            }

            if var wid = w.identifier?.rawValue {
                wid = wid.replacingOccurrences(of: windowPrefix, with: "")
                if let b = getEffectsButtonFromIdentifier(wid.toInt()) {
                    b.state = .off
                    return
                }
            }

        }
    }
}
