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

    @IBOutlet weak var effectsContainer: NSView!
    @IBOutlet weak var playButton: NSButton!
    @IBOutlet weak var loopButton: NSButton!
    @IBOutlet weak var instrumentPlayButton: NSButton!
    @IBOutlet weak var fileField: NSTextField!
    @IBOutlet weak var fmButton: NSButton!
    @IBOutlet weak var auInstrumentSelector: NSPopUpButton!
    @IBOutlet weak var midiDeviceSelector: NSPopUpButton!

    var openPanel: NSOpenPanel?
    var auManager: AKAudioUnitManager?
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
        if let w = view.window {
            w.delegate = self
        }
    }

    func initialize() {
        fm = AKFMOscillator()
        mixer = AKMixer()
        AudioKit.output = mixer
        AudioKit.start()

        auManager = AKAudioUnitManager()
        auManager?.delegate = self

        auManager?.requestEffects(completionHandler: { audioUnits in
            self.updateEffectsUI(audioUnits: audioUnits)
        })

        auManager?.requestInstruments(completionHandler: { audioUnits in
            self.updateInstrumentsUI(audioUnits: audioUnits)
        })

        initMIDI()
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

    fileprivate func updateEffectsUI( audioUnits: [AVAudioUnitComponent] ) {
        guard auManager != nil else { return }

        // fill all the menus with the same list
        for sv in effectsContainer.subviews {
            if sv.isKind(of: NSPopUpButton.self) {
                let b = sv as! NSPopUpButton
                b.removeAllItems()
                b.addItem(withTitle: "-")

                for component in audioUnits {
                    if component.name != "" {
                        b.addItem(withTitle: component.name)
                    }
                }
            }
        }
    }

    fileprivate func updateInstrumentsUI( audioUnits: [AVAudioUnitComponent] ) {
        guard auManager != nil else { return }

        auInstrumentSelector.removeAllItems()
        auInstrumentSelector.addItem(withTitle: "-")

        //AKLog("updateInstrumentsUI() \(audioUnits)")
        for component in audioUnits {
            if component.name != "" {
                auInstrumentSelector.addItem(withTitle: component.name)
            }
        }

    }

    fileprivate func getMenuFromIdentifier(_ id: Int ) -> NSPopUpButton? {
        guard effectsContainer != nil else { return nil }

        for sv in effectsContainer.subviews {
            if sv.isKind(of: NSPopUpButton.self) {
                let b = sv as! NSPopUpButton
                if b.tag == id {
                    return b
                }
            }
        }
        return nil
    }

    private func getWindowFromIndentifier(_ id: String ) -> NSWindow? {

        guard let windows = self.view.window?.childWindows else { return nil }

        for w in windows {
            if w.identifier?.rawValue == id {
                return w
            }
        }

        return nil
    }

    fileprivate func getEffectsButtonFromIdentifier(_ id: Int ) -> NSButton? {
        guard effectsContainer != nil else { return nil }

        for sv in effectsContainer.subviews {
            if sv.isKind(of: NSButton.self) && !sv.isKind(of: NSPopUpButton.self) {
                let b = sv as! NSButton
                if b.tag == id {
                    return b
                }
            }
        }
        return nil
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

    @IBAction func handleEffectSelected(_ sender: NSPopUpButton) {
        guard auManager != nil else { return }
        guard let auname = sender.titleOfSelectedItem else { return }
        let identifier = sender.tag

        AKLog("handleEffectSelected() \(identifier) \(auname)")

        if auname == "-" {
            if let button = getEffectsButtonFromIdentifier(identifier) {
                button.state = .off
            }
            if let win = getWindowFromIndentifier(String(identifier)) {
                win.close()
            }
            auManager!.removeEffect(at: identifier)

            return
        }
        auManager!.insertAudioUnit(name: auname, at: identifier)
    }

    @IBAction func handleMidiDeviceSelected(_ sender: NSPopUpButton) {
        if let device = sender.titleOfSelectedItem {
            midiManager?.openInput(device)
        }
    }

    @IBAction func handleInstrumentSelected(_ sender: NSPopUpButton) {
        guard auManager != nil else { return }
        guard let auname = sender.titleOfSelectedItem else { return }

        if auname == "-" {
            // remove instrument
            return
        }

        auManager!.createInstrument(name: auname, completionHandler: { audioUnit in
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
            self.auManager?.connectEffects(firstNode: self.auInstrument, lastNode: self.mixer )
            self.showAudioUnit(audioUnit, identifier: 6)
            self.instrumentPlayButton.isEnabled = true

            //self.midiManager!.addListener(self.auInstrument!)
        })
    }

    func showEffect( at auIndex: Int, state: Bool ) {
        if auIndex > auManager!.effectsChain.count - 1 {
            return
        }

        if state {
            // get audio unit
            if let au = auManager!.effectsChain[auIndex] {
                showAudioUnit(au, identifier: auIndex)

            } else {
                AKLog("Nothing at this index")
            }

        } else {
            if let w = getWindowFromIndentifier(String(auIndex)) {
                w.close()
            }
        }
    }

    @IBAction func handleShowAudioUnit(_ sender: NSButton) {
        guard auManager != nil else { return }
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
        } else {
            player.play()
            playButton.title = "⏹"
        }
    }

    @IBAction func handleInstrumentPlayButton(_ sender: NSButton) {
        guard auInstrument != nil else { return }

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
        guard auManager != nil else { return }
        guard mixer != nil else { return }

        //_ = ViewController.getAudioFileMarkers(url)

        do {
            let file = try AKAudioFile(forReading: url)
            player = try AKAudioPlayer(file: file)
            player!.completionHandler = handleAudioComplete

            auManager!.connectEffects(firstNode: player, lastNode: mixer)

            player!.looping = loopButton.state == .on

            playButton.isEnabled = true
            fileField.stringValue = "🔈 \(url.lastPathComponent)"
        } catch {

        }
    }

    func initFM() {
        guard auManager != nil else { return }
        guard mixer != nil else { return }
        guard let fm = fm else { return }

        AKLog("initFM()")

        auManager!.connectEffects(firstNode: fm, lastNode: mixer)

        if fmTimer != nil && fmTimer!.isValid {
            fmTimer!.invalidate()
        }

        //let randInterval = Double(randomNumber(range: 10...100)) / 100
        fmTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(randomFM), userInfo: nil, repeats: true)

        randomFM()
        fm.start()
    }

    @objc func randomFM() {
        let noteNumber = randomNumber(range: 0...127)
        let frequency = AKPolyphonicNode.tuningTable.frequency(forNoteNumber: MIDINoteNumber(noteNumber))
        fm!.baseFrequency = Double(frequency)
        fm!.carrierMultiplier = Double(randomNumber(range: 10...100)) / 100
        fm!.amplitude = Double(randomNumber(range: 10...100)) / 100
        //AKLog("randomFM() \(fm!.baseFrequency)")
    }

    func randomNumber(range: ClosedRange<Int> = 100...500) -> Int {
        let min = range.lowerBound
        let max = range.upperBound
        return Int(arc4random_uniform(UInt32(1 + max - min))) + min
    }

    open func testAUInstrument(state: Bool) {
        AKLog("testAUInstrument()")

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

    public func showAudioUnit(_ audioUnit: AVAudioUnit, identifier: Int ) {

        audioUnit.auAudioUnit.requestViewController { [weak self] viewController in
            var ui = viewController
            guard let strongSelf = self else { return }

            if ui == nil {
                AKLog("No ViewController for \(audioUnit.name )")
                ui = NSViewController()
                ui!.view = AudioUnitGenericView(au: audioUnit)
            }

            AKLog("Audio Unit incoming frame: \(ui!.view.frame)")

            guard let selfWindow = strongSelf.view.window else { return }

            DispatchQueue.main.async {
                let unitWindow = NSWindow(contentViewController: ui!)
                unitWindow.title = "\(audioUnit.name)"
                unitWindow.delegate = self
                unitWindow.identifier = NSUserInterfaceItemIdentifier(String(identifier))

                if ui!.view.isKind(of: AudioUnitGenericView.self) {
                    if let gauv = ui?.view as? AudioUnitGenericView {

                        let gauvLoc = unitWindow.frame.origin
                        let f = NSMakeRect(gauvLoc.x, gauvLoc.y, 400, gauv.preferredHeight)
                        unitWindow.setFrame(f, display: true)
                    }
                }

                if let w = strongSelf.getWindowFromIndentifier(String(identifier)) {
                    unitWindow.setFrameOrigin( w.frame.origin )
                    w.close()
                }

                selfWindow.addChildWindow(unitWindow, ordered: NSWindow.OrderingMode.above)
                unitWindow.setFrameOrigin(NSPoint(x:selfWindow.frame.origin.x, y:selfWindow.frame.origin.y - unitWindow.frame.height))

                if let button = strongSelf.getEffectsButtonFromIdentifier( identifier ) {
                    button.state = .on
                }
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

extension ViewController:  AKAudioUnitManagerDelegate {
    func handleAudioUnitNotification(type: AKAudioUnitManager.Notification, object: Any?) {
        guard auManager != nil else { return }

        if type == AKAudioUnitManager.Notification.changed {
            updateEffectsUI( audioUnits: auManager!.availableEffects )
        }
    }

    func handleEffectAdded( at auIndex: Int ) {
        guard auManager != nil else { return }

        showEffect(at: auIndex, state: true)

        guard mixer != nil else { return }

        // is FM playing?
        if fm != nil && fm!.isStarted {
            auManager!.connectEffects(firstNode: fm, lastNode: mixer)
            return
        }

        guard player != nil else { return }

        let playing = player!.isStarted

        if playing {
            player!.stop()
        }

        auManager!.connectEffects(firstNode: player, lastNode: mixer)

        if playing {
            player!.start()
        }
    }
}

/// Handle Window Events
extension ViewController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let obj = notification.object {
            if let w = obj as? NSWindow {

                if let id = w.identifier?.rawValue.toInt() {
                    if let b = getEffectsButtonFromIdentifier(id) {
                        b.state = .off
                        return
                    }
                }

                // QUIT
                if w == self.view.window {
                    exit(0)
                }
            }
        }
    }
}
