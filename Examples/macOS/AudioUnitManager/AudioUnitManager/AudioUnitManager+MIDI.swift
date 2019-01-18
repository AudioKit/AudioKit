//
//  AudioUnitManager+MIDI.swift
//  AudioUnitManager
//
//  Created by Ryan Francesconi, revision history on Githbub.
//  Copyright © 2017 Ryan Francesconi. All rights reserved.
//

import AudioKit

extension AudioUnitManager: AKMIDIListener {
    internal func initMIDI() {
        midiManager = AudioKit.midi
        midiManager?.addListener(self)
        initMIDIDevices()
    }

    internal func initMIDIDevices() {
        guard let devices = midiManager?.inputNames else { return }

        if !devices.isEmpty {
            midiDeviceSelector.removeAllItems()
            midiManager?.openInput(index: 0)

            for device in devices {
                AKLog("MIDI Device: \(device)")
                midiDeviceSelector.addItem(withTitle: device)
            }
        }
    }

    /// MIDI Setup has changed
    public func receivedMIDISetupChange() {
        initMIDIDevices()
    }

    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        let currentTime: Int = Int(mach_absolute_time())

        // AKMIDI is sending duplicate noteOn messages??, don't let them be sent too quickly
        let sinceLastEvent = currentTime - lastMIDIEvent
        let isDupe = sinceLastEvent < 300_000

        if let auInstrument = auInstrument {
            if !isDupe {
                auInstrument.play(noteNumber: noteNumber, velocity: velocity, channel: channel)
            } else {
                // AKLog("Duplicate noteOn message sent")
            }
        } else {
            if !fmOscillator.isStarted {
                fmOscillator.start()
            }

            if fmTimer?.isValid ?? false {
                fmTimer?.invalidate()
            }
            let frequency = AKPolyphonicNode.tuningTable.frequency(forNoteNumber: noteNumber)
            fmOscillator.baseFrequency = frequency
        }
        lastMIDIEvent = currentTime
    }

    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        if let auInstrument = auInstrument {
            auInstrument.stop(noteNumber: noteNumber, channel: channel)

        } else if fmOscillator.isStarted {
            fmOscillator.stop()
        }
    }

    internal func playFM(state: Bool) {
        AKLog("playFM() \(state)")

        fmButton.state = state ? .on : .off

        if fmTimer?.isValid ?? false {
            fmTimer?.invalidate()
        }

        if state {
            if player?.isPlaying ?? false {
                handlePlay(state: false)
            }
            internalManager.connectEffects(firstNode: fmOscillator, lastNode: mixer)

            startEngine(completionHandler: {
                self.fmOscillator.start()
                self.fmTimer = Timer.scheduledTimer(timeInterval: 0.2,
                                                    target: self,
                                                    selector: #selector(self.randomFM),
                                                    userInfo: nil,
                                                    repeats: true)
            })
        } else {
            fmOscillator.stop()
        }
    }

    @objc func randomFM() {
        let noteNumber = randomNumber(range: 0...127)
        let frequency = AKPolyphonicNode.tuningTable.frequency(forNoteNumber: MIDINoteNumber(noteNumber))
        fmOscillator.baseFrequency = Double(frequency)
        fmOscillator.carrierMultiplier = Double(randomNumber(range: 10...100)) / 100
        fmOscillator.amplitude = Double(randomNumber(range: 10...100)) / 100
    }

    func randomNumber(range: ClosedRange<Int> = 100...500) -> Int {
        let min = range.lowerBound
        let max = range.upperBound
        return Int(arc4random_uniform(UInt32(1 + max - min))) + min
    }

    open func testAUInstrument(state: Bool) {
        AKLog("\(state)")
        guard let auInstrument = auInstrument else { return }

        instrumentPlayButton.state = state ? .on : .off

        if state {
            if player?.isPlaying ?? false {
                handlePlay(state: false)
            }
            internalManager.connectEffects(firstNode: auInstrument, lastNode: mixer)
            testPlayer = InstrumentPlayer(audioUnit: auInstrument.midiInstrument?.auAudioUnit)
            testPlayer?.play()
        } else {
            testPlayer?.stop()
        }
    }

    internal func updateInstrumentsUI(audioUnits: [AVAudioUnitComponent]) {
        auInstrumentSelector.removeAllItems()
        auInstrumentSelector.addItem(withTitle: "-")

        for component in audioUnits where component.name != "" {
            auInstrumentSelector.addItem(withTitle: component.name)
        }
    }
}
