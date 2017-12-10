//
//  AudioUnitManager+MIDI.swift
//  AudioUnitManager
//
//  Created by Ryan Francesconi on 12/9/17.
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

        if devices.count > 0 {
            midiDeviceSelector.removeAllItems()
            midiManager?.openInput(devices[0])

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

    internal func initFM() {
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
