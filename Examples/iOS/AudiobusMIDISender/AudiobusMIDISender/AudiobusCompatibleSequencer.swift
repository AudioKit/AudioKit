//
//  AudiobusCompatibleSequencer.swift
//  AudiobusMIDISender
//
//  Created by Jeff Holtzkener on 2018/03/28.
//  Copyright © 2018 Jeff Holtzkener. All rights reserved.
//

import Foundation
import AudioKit

class AudiobusCompatibleSequencer {

    var mixer: AKMixer!
    var midi: AKMIDI!
    var seq: AKSequencer!

    let numTracks = 4
    var callbackInsts: [AKMIDICallbackInstrument]!
    var tracks: [AKMusicTrack]!
    var ports: [ABMIDISenderPort]!

    var coreMIDIIsActive = true
    var isPlaying: Bool = false
    var transportTrigger: ABTrigger!
    weak var displayDelegate: DisplayDelegate?

    init() {
        midi = AKMIDI()
        midi.createVirtualOutputPort(10_101, name: "my port")
        midi.openOutput()

        mixer = AKMixer()
        AudioKit.output = mixer

        seq = AKSequencer()
        createTracksAndCallBackInst()
        writeMIDIData()
        allowAudiobusToDisableCoreMIDI()
        addAudiobusTrigger()
        startAudioKit()
    }

    fileprivate func startAudioKit() {
        do {
            AKSettings.playbackWhileMuted = true
            try AudioKit.start()
        } catch {
            AKLog("Couldn't start Audiokit")
        }
    }

    // MARK: - Setting up Audiobus
    fileprivate func allowAudiobusToDisableCoreMIDI() {
        Audiobus.setUpEnableCoreMIDIBlock { [weak self] isEnabled in
            guard let this = self else { return }
            this.coreMIDIIsActive = isEnabled
            AKLog("CoreMIDI Send Enabled: \(isEnabled)")
        }
    }

    fileprivate func addAudiobusTrigger() {
        transportTrigger = ABTrigger(systemType: ABTriggerTypePlayToggle) { [weak self] _, _ in
            guard let this = self else { return }
            if this.isPlaying {
                this.stop()
            } else {
                this.play()
            }
        }
        Audiobus.addTrigger(transportTrigger)
    }

    // MARK: - Building Tracks, Callback Instruments, and ABMIDISendPorts
    fileprivate func createTracksAndCallBackInst() {
        tracks = [AKMusicTrack]()
        callbackInsts = [AKMIDICallbackInstrument]()
        ports = [ABMIDISenderPort]()
        Audiobus.start()
        for i in 0 ..< numTracks {
            if let port = ABMIDISenderPort(name: "MIDISend\(i)", title: "MIDI Send \(i)") {
                ports.append(port)
                Audiobus.addMIDISenderPort(port)
            }
            callbackInsts.append(setUpCallBackFunctions(channel: i))
            tracks.append(seq.newTrack()!)
            tracks[i].setMIDIOutput(callbackInsts[i].midiIn)
        }
    }

    // MARK: - Handling NoteOn and NoteOff Msgs
    fileprivate func setUpCallBackFunctions(channel: Int) -> AKMIDICallbackInstrument {
        return  AKMIDICallbackInstrument { [weak self] status, note, velocity in
            guard let this = self else { return }
            if let midiStatusType = AKMIDIStatusType(rawValue: Int(status >> 4)) {
                let midiStatus = AKMIDIStatus(type: midiStatusType, channel: MIDIChannel(channel))
                switch midiStatusType {
                case .noteOn:
                    this.noteOn(midiSendPort: this.ports[channel], status: midiStatus,
                                note: note, velocity: velocity, channel: MIDIChannel(channel))
                    this.displayDelegate?.flashNoteOnDisplay(index: channel, noteOn: true)
                case .noteOff:
                    this.noteOff(midiSendPort: this.ports[channel], status: midiStatus,
                                 note: note, velocity: velocity, channel: MIDIChannel(channel))
                    this.displayDelegate?.flashNoteOnDisplay(index: channel, noteOn: false)
                default:
                    AKLog("other MIDI status msg sent")
                }
            }
        }
    }

    fileprivate func noteOn(midiSendPort: ABMIDISenderPort, status: AKMIDIStatus, note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel = 0) {
        if coreMIDIIsActive {
            self.midi.sendNoteOnMessage(noteNumber: note, velocity: velocity, channel: channel)
        } else {
            Audiobus.sendNoteOnMessage(midiSendPort: midiSendPort, status: status, note: note, velocity: velocity)
        }
    }

    fileprivate func noteOff(midiSendPort: ABMIDISenderPort, status: AKMIDIStatus, note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel = 0) {
        if coreMIDIIsActive {
            self.midi.sendNoteOffMessage(noteNumber: note, velocity: velocity, channel: MIDIChannel(channel))
        } else {
            Audiobus.sendNoteOffMessage(midiSendPort: midiSendPort, status: status, note: note, velocity: velocity)
        }
    }

    // MARK: - Write data to the tracks
    fileprivate func writeMIDIData() {
        var midinote = 60
        let beats: Double = 4
        seq.setLength(AKDuration(beats: beats))
        seq.enableLooping()
        seq.setTempo(100)

        for i in 0 ..< numTracks {
            let interval = beats / Double(i + 1)
            for noteNum in 0 ..< (i + 1) {
                tracks[i].add(noteNumber: MIDINoteNumber(midinote),
                                      velocity: noteNum == 0 ? 100 : 60,
                                      position: AKDuration(beats: interval * Double(noteNum)),
                                      duration: AKDuration(beats: 0.3))
            }
            midinote += 7
        }
    }

    // MARK: - Handling Transport
    func play() {
        isPlaying = true
        transportTrigger.state = ABTriggerStateSelected
        seq.preroll()
        seq.play()
        displayDelegate?.showIsPlaying(true)
    }

    func stop() {
        isPlaying = false
        transportTrigger.state = ABTriggerStateNormal
        seq.stop()
        displayDelegate?.showIsPlaying(false)
    }
}
