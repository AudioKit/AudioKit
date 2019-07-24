//
//  SequencerManager.swift
//  MIDIFileEditAndSync
//
//  Created by Jeff Holtzkener on 2018/04/15.
//  Copyright © 2018 Jeff Holtzkener. All rights reserved.
//

import AudioKit
import Foundation

class SequencerManager {
    var seq: AKAppleSequencer?
    let oscBank = AKFMOscillatorBank(waveform: AKTable(.triangle),
                                     attackDuration: 0.01,
                                     decayDuration: 0.03)
    let mixer = AKMixer()
    var node: AKMIDINode!

    let minLoopLength = AKDuration(beats: 4)

    init() {
        setUpSequencer()
        startAudioKit()
    }

    fileprivate func setUpSequencer() {
        seq = AKAppleSequencer(filename: "D_mixolydian_01")
        seq?.setLength(minLoopLength)
        seq?.enableLooping()
        node = AKMIDINode(node: oscBank)
        seq?.setGlobalMIDIOutput(node.midiIn)
        oscBank >>> mixer
        AudioKit.output = mixer
    }

    fileprivate func startAudioKit() {
        do {
            try AudioKit.start()
        } catch {
            AKLog("Couldn't start AudioKit")
        }
    }

    // MARK: - Interface
    func play() {
        seq?.rewind()
        seq?.play()
    }

    func stop() {
        seq?.stop()
    }

    func getURLwithMIDIFileData() -> URL? {
        guard let seq = seq,
            let data = seq.genData() else { return nil }
        let fileName = "ExportedMIDI.mid"
        do {
            let tempPath = URL(fileURLWithPath: NSTemporaryDirectory().appending(fileName))
            try data.write(to: tempPath as URL)
            return tempPath
        } catch {
            AKLog("couldn't write to URL")
        }
        return nil
    }

    func sequencerTracksChanged() {
        guard let seq = seq else { return }
        if seq.length < minLoopLength {
            seq.setLength(minLoopLength)
        }

        if seq.loopEnabled {
            seq.enableLooping()
        }

        seq.setGlobalMIDIOutput(node.midiIn)
    }

    // MARK: - MIDI editing
    // general helper to alter AKMIDINoteData arrays for selected tracks
    fileprivate func modifyNotesInSelectedTracks(_ selectedTracks: Set<Int>,
                                                 modification: (AKMIDINoteData) -> AKMIDINoteData) {
        guard let seq = seq else { return }
        for (i, track) in seq.tracks.enumerated() {
            if selectedTracks.contains(i) {
                var result = track.getMIDINoteData()
                for (j, note) in result.enumerated() {
                    result[j] = modification(note)
                }
                track.replaceMIDINoteData(with: result)
            }
        }
    }

    func filterNotes(_ selectedTracks: Set<Int>,
                     filterFunction: (AKMIDINoteData) -> AKMIDINoteData) {
        modifyNotesInSelectedTracks(selectedTracks, modification: filterFunction)
    }

    func doubleTrackLengths(_ selectedTracks: Set<Int>) {
        modifyNotesInSelectedTracks(selectedTracks) { note in
            var newNote = note
            newNote.position = AKDuration(beats: note.position.beats * 2)
            newNote.duration = AKDuration(beats: note.duration.beats * 2)
            return newNote
        }
    }

    func halveTrackLengths(_ selectedTracks: Set<Int>) {
        modifyNotesInSelectedTracks(selectedTracks) { note in
            var newNote = note
            newNote.position = AKDuration(beats: note.position.beats / 2)
            let newDuration = note.duration.beats / 2
            // very weird things happen when durations get shorter than the default PPQN of 24
            if newDuration >= 1 / 24 {
                newNote.duration = AKDuration(beats: newDuration)
            } else {
                AKLog("Note is already too short")
            }
            return newNote
        }
    }

    func shiftRight(_ selectedTracks: Set<Int>) {
        modifyNotesInSelectedTracks(selectedTracks) { note in
            var newNote = note
            newNote.position = AKDuration(beats: note.position.beats + 1)
            return newNote
        }
    }

    func shiftLeft(_ selectedTracks: Set<Int>) {
        modifyNotesInSelectedTracks(selectedTracks) { note in
            var newNote = note
            newNote.position = AKDuration(beats: note.position.beats - 1)
            return newNote
        }
    }

    func deleteSelectedTracks(_ selectedTracks: Set<Int>) {
        guard let seq = seq else { return }
        seq.stop()
        var trackIndices = selectedTracks.sorted()
        while trackIndices.isNotEmpty {
            let index = trackIndices[0]
            seq.deleteTrack(trackIndex: index)
            trackIndices.removeFirst()
            for i in 0 ..< trackIndices.count {
                trackIndices[i] -= 1
            }
        }
        seq.setGlobalMIDIOutput(node.midiIn)
    }
}
