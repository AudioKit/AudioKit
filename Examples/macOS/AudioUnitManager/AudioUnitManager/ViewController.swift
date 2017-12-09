//
//  ViewController.swift
//  AudioUnitManager
//
//  Created by Ryan Francesconi on 7/14/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Cocoa
import AVFoundation
import AudioKit

/// An Example of how to create an AudioUnit Host application
class ViewController: NSViewController {

    let akInternals = "AudioKit ★"
    let windowPrefix = "FX"

    @IBOutlet weak var effectsContainer: NSView!
    @IBOutlet weak var waveformContainer: NSView!
    @IBOutlet weak var playButton: NSButton!
    @IBOutlet weak var loopButton: NSButton!
    @IBOutlet weak var instrumentPlayButton: NSButton!
    @IBOutlet weak var fileField: NSTextField!
    @IBOutlet weak var fmButton: NSButton!
    @IBOutlet weak var auInstrumentSelector: NSPopUpButton!
    @IBOutlet weak var midiDeviceSelector: NSPopUpButton!

    fileprivate var _lastMIDIEvent: Int = 0
    fileprivate var audioTimer: Timer?
    fileprivate var audioPlaying: Bool = false
    
    var openPanel: NSOpenPanel?
    var internalManager: AKAudioUnitManager?
    var midiManager: AKMIDI?
    var player: AKPlayer?
    var waveform: AKWaveform?
    var fm: AKFMOscillator?
    var mixer: AKMixer?
    var auInstrument: AKAudioUnitInstrument? {
        didSet {
            guard auInstrument != nil else { return }
        }
    }

    var testPlayer: InstrumentPlayer?

    fileprivate var fmTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }

    @objc func handleApplicationInit() {
        view.window?.delegate = self
    }

    func initialize() {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handleApplicationInit), name: Notification.Name("AudioUnitManager.handleApplicationInit"), object: nil)

        fm = AKFMOscillator()
        mixer = AKMixer()
        let mainOutput = AKMixer()
        mixer?.connect(to: mainOutput)
        AudioKit.output = mainOutput

        initManager()
        initMIDI()
        initUI()

        AudioKit.start()
    }

    private func initMIDI() {
        midiManager = AudioKit.midi
        midiManager?.addListener(self)
        initMIDIDevices()
    }

    fileprivate func initMIDIDevices() {
        let devices = midiManager!.inputNames

        if devices.count > 0 {
            midiDeviceSelector.removeAllItems()

            midiManager?.openInput(devices[0])

            for device in devices {
                AKLog("MIDI Device: \(device)")
                midiDeviceSelector.addItem(withTitle: device)
            }
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

    @IBAction func handlePlayButton(_ sender: Any) {
        guard let player = player else { return }

        if fm != nil && fm!.isStarted {
            fmButton!.state = .off
            fm!.stop()
        }

        if auInstrument != nil {
            instrumentPlayButton.title = "▶️"
        }

        if playButton.title == "⏹" {
            player.stop()
            playButton.title = "▶️"

            if AudioKit.engine.isRunning {
                AudioKit.stop()
                internalManager?.reset()
            }
            
            stopAudioTimer()

        } else {
            if !AudioKit.engine.isRunning {
                AudioKit.start()
            }

            if internalManager?.input != player {
                internalManager!.connectEffects(firstNode: player, lastNode: mixer)
            }
            player.volume = 1
            player.play(from: waveform?.position ?? 0)
            playButton.title = "⏹"
            startAudioTimer()
            
        }
    }
    
    // this just moves the Timeline bar in the waveform
    private func startAudioTimer() {
        audioTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(ViewController.updateWaveformDisplay), userInfo: nil, repeats: true)
    }
    
    private func stopAudioTimer() {
        audioTimer?.invalidate()
    }
    
    @objc private func updateWaveformDisplay() {
        guard player != nil else { return }
        waveform?.position = player!.currentTime
    }

    @IBAction func handleInstrumentPlayButton(_ sender: NSButton) {
        guard auInstrument != nil else { return }

        if !AudioKit.engine.isRunning {
            AudioKit.start()
        }

        if fm != nil && fm!.isStarted {
            fmButton!.state = .off
            fm!.stop()
        }

        if player?.isPlaying ?? false {
            handlePlayButton(playButton)
        }

        if sender.title == "⏹" {
            testAUInstrument(state: false)
            sender.title = "▶️"
        } else {
            testAUInstrument(state: true)
            sender.title = "⏹"
        }
    }

    @IBAction func handleFMButton(_ sender: NSButton) {
        guard let fm = fm else { return }

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

    func handleAudioComplete() {
        if player?.isLooping ?? false {
            return
        }
 
        playButton.state = .off
        playButton.title = "▶️"
    }

    @IBAction func handleLoopButton(_ sender: NSButton) {
        let state = sender.state == .on
        sender.title = state ? "🔁" : "🔄"
        player?.isLooping = state
        
    }

    /// open an audio URL for playing
    func open(url: URL) {
        guard internalManager != nil else { return }
        guard mixer != nil else { return }

        player = AKPlayer(url: url)
        guard player != nil else { return }
        player!.completionHandler = handleAudioComplete

        internalManager!.connectEffects(firstNode: player, lastNode: mixer)
        player!.isLooping = loopButton.state == .on

        playButton.isEnabled = true
        fileField.stringValue = "🔈 \(url.lastPathComponent)"
        
        if waveform != nil {
            waveform!.dispose()
        }
        
        // get the waveform
        let darkRed = NSColor(calibratedRed: 0.79, green: 0.128, blue: 0.06, alpha: 1)
        waveform = AKWaveform(url: url, color: darkRed)
        guard waveform != nil else { return }

        waveformContainer.addSubview(waveform!)
        waveform?.frame = waveformContainer.frame
        waveform?.fitToFrame()
        waveform?.delegate = self
    }

    func initFM() {
        guard internalManager != nil else { return }
        guard mixer != nil else { return }
        guard let fm = fm else { return }

        AKLog("initFM()")

        internalManager!.connectEffects(firstNode: fm, lastNode: mixer)

        if fmTimer != nil && fmTimer!.isValid {
            fmTimer!.invalidate()
        }

        if !AudioKit.engine.isRunning {
            AudioKit.start()
        }
        fm.start()
        fmTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(randomFM), userInfo: nil, repeats: true)
    }

    @objc func randomFM() {
        let noteNumber = randomNumber(range: 0...127)
        let frequency = AKPolyphonicNode.tuningTable.frequency(forNoteNumber: MIDINoteNumber(noteNumber))
        fm!.baseFrequency = Double(frequency)
        fm!.carrierMultiplier = Double(randomNumber(range: 10...100)) / 100
        fm!.amplitude = Double(randomNumber(range: 10...100)) / 100
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

        for component in audioUnits {
            if component.name != "" {
                auInstrumentSelector.addItem(withTitle: component.name)
            }
        }
    }
}

extension ViewController: AKMIDIListener {
    /// MIDI Setup has changed
    public func receivedMIDISetupChange() {
        initMIDIDevices()
    }

    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        let currentTime: Int = Int(mach_absolute_time())

        // AKMIDI is sending duplicate noteOn messages??, don't let them be sent too quickly
        let sinceLastEvent = currentTime - _lastMIDIEvent
        let isDupe = sinceLastEvent < 300_000

        if auInstrument != nil {
            if !isDupe {
                auInstrument!.play(noteNumber: noteNumber, velocity: velocity, channel: channel)
            } else {
                //AKLog("Duplicate noteOn message sent")
            }
        } else if fm != nil {
            if !fm!.isStarted {
                fm!.start()
            }

            if fmTimer != nil && fmTimer!.isValid {
                fmTimer?.invalidate()
            }
            let frequency = AKPolyphonicNode.tuningTable.frequency(forNoteNumber: noteNumber)
            fm!.baseFrequency = frequency
        }
        _lastMIDIEvent = currentTime
    }

    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        if auInstrument != nil {
            auInstrument!.stop(noteNumber: noteNumber, channel: channel)

        } else if fm != nil {
            if fm!.isStarted {
                fm!.stop()
            }
        }
    }
}

extension ViewController: AKWaveformDelegate {
    func waveformScrubbed(source: AKWaveform, at time: Double) {
        //player?.startTime = time
    }
    
    func waveformScrubComplete(source: AKWaveform, at time: Double) {

        if audioPlaying {
            startAudioTimer()
            player?.play(from: time)
        }
        
    }
    
    func waveformSelected(source: AKWaveform, at time: Double) {
        audioPlaying = player?.isPlaying ?? false
        stopAudioTimer()
        player?.stop()
        player?.startTime = time
        
        
    }
    
    
}


/// Handle Window Events
extension ViewController: NSWindowDelegate {
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
