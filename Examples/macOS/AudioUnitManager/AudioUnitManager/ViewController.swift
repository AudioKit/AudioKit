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
    
    @IBOutlet weak var effectsContainer: NSView!
    @IBOutlet weak var playButton: NSButton!
    @IBOutlet weak var loopButton: NSButton!
    @IBOutlet weak var instrumentPlayButton: NSButton!
    @IBOutlet weak var fileField: NSTextField!
    @IBOutlet weak var fmButton: NSButton!
    @IBOutlet weak var auInstrumentSelector: NSPopUpButton!
    @IBOutlet weak var midiDeviceSelector: NSPopUpButton!

    var openPanel: NSOpenPanel?
    var internalManager: AKAudioUnitManagerDev?
    var midiManager: AKMIDI?
    var player: AKAudioPlayer?
    var fm: AKFMOscillator?
    var mixer: AKMixer?
    var auInstrument: AKAudioUnitInstrument?
    var testPlayer: InstrumentPlayer?

    fileprivate var fmTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        
    }

    override func viewDidAppear() {
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
        
        AudioKit.start()
    }

    private func initMIDI() {
        midiManager = AKMIDI()
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
            //AKLog( "Response: \(response) \(self.openPanel!.url)" )
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
            // remove instrument
            return
        }

        internalManager!.createInstrument(name: auname, completionHandler: { audioUnit in
            guard let audioUnit = audioUnit else { return }

            AKLog("* \(audioUnit.name) : Audio Unit created")

            if self.auInstrument != nil {
                // dispose 

                self.midiManager!.clearListeners()
            }

            self.auInstrument = AKAudioUnitInstrument(audioUnit: audioUnit)

            if self.auInstrument == nil {
                return
            }
            self.internalManager?.connectEffects(firstNode: self.auInstrument, lastNode: self.mixer )
            self.showAudioUnit(audioUnit, identifier: 6)
            DispatchQueue.main.async {
                self.instrumentPlayButton.isEnabled = true
            }
            //self.midiManager!.addListener(self.auInstrument!)
        })
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
            handleInstrumentPlayButton(instrumentPlayButton)
        }

        if playButton.title == "⏹" {
            player.stop()
            playButton.title = "▶️"
            
            if !AudioKit.engine.isRunning {
                AudioKit.stop()
                internalManager?.reset()
            }
            
        } else {
            if !AudioKit.engine.isRunning {
                AudioKit.start()
            }
            player.play()
            playButton.title = "⏹"
        }
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

        if player != nil && player!.isStarted {
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

        if player != nil && player!.isStarted {
            handlePlayButton(playButton)
        }

        if auInstrument != nil {
            handleInstrumentPlayButton(instrumentPlayButton)
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
        playButton.state = .off
        playButton.title = "▶️"
    }

    @IBAction func handleLoopButton(_ sender: NSButton) {
        let state = sender.state == .on

        sender.title = state ? "🔁" : "🔄"

        if player != nil {
            player!.looping = state
        }
    }

    func open(url: URL) {
        guard internalManager != nil else { return }
        guard mixer != nil else { return }

        do {
            let file = try AKAudioFile(forReading: url)
            player = try AKAudioPlayer(file: file)
            player!.completionHandler = handleAudioComplete

            internalManager!.connectEffects(firstNode: player, lastNode: mixer)
            player!.looping = loopButton.state == .on

            playButton.isEnabled = true
            fileField.stringValue = "🔈 \(url.lastPathComponent)"
        } catch {

        }
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

        //let randInterval = Double(randomNumber(range: 10...100)) / 100
        fmTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(randomFM), userInfo: nil, repeats: true)

//        randomFM()
//        fm.start()
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

        if testPlayer == nil {
            testPlayer = InstrumentPlayer(audioUnit: auInstrument?.midiInstrument?.auAudioUnit)
        }

        if testPlayer == nil {
            AKLog("Failed creating the test player")
            return
        }

        if state {
            testPlayer?.play()
        } else {
            testPlayer?.stop()
        }
    }
    
    internal func updateInstrumentsUI( audioUnits: [AVAudioUnitComponent] ) {
        guard internalManager != nil else { return }
        
        auInstrumentSelector.removeAllItems()
        auInstrumentSelector.addItem(withTitle: "-")
        
        //AKLog("updateInstrumentsUI() \(audioUnits)")
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
        if auInstrument != nil {
            auInstrument!.play(noteNumber: noteNumber, velocity: velocity, channel: channel)

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
    }

    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        if auInstrument != nil {
            auInstrument!.stop(noteNumber: noteNumber, channel: channel)

        } else if fm != nil {
            if fm!.isStarted {
                //fm!.stop()
            }
        }
    }
}


/// Handle Window Events
extension ViewController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        
        Swift.print("windowWillClose: \(notification)")
        
        if let w = notification.object as? NSWindow {
            if w == view.window {
                internalManager?.reset()
                AudioKit.stop()
                exit(0)
            }
            
            if let wid = w.identifier?.rawValue {
                if let b = getEffectsButtonFromIdentifier(wid.toInt()) {
                    b.state = .off
                    return
                }
            }

        }
    }
}
