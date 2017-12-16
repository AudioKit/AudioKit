//
//  AKMIDIPlayer.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

extension AVAudioSequencer : Collection {
    public typealias Element = AVMusicTrack
    public typealias Index = Int

    public var startIndex: Index {
        return 0
    }

    public var endIndex: Index {
        return count
    }

    public subscript(index: Index) -> Element {
        return tracks[index]
    }

    public func index(after index: Index) -> Index {
        return index + 1
    }

    /// Rewind the sequence
    public func rewind() {
        currentPositionInBeats = 0
    }
}

/// Simple MIDI Player based on Apple's AVAudioSequencer which has limited capabilities
public class AKMIDIPlayer: AVAudioSequencer {

    public var tempo: Double = 120.0

    /// Loop control
    public var loopEnabled: Bool = false

    /// Sequencer Initialization
    public override init() {
        super.init(audioEngine: AudioKit.engine)
    }

    /// Initialize the sequence with a MIDI file
    ///
    /// - parameter filename: Location of the MIDI File
    ///
    public init(filename: String) {
        super.init(audioEngine: AudioKit.engine)
        loadMIDIFile(filename)
    }

    /// Load a sequence from data
    ///
    /// - parameter data: data to create sequence from
    ///
    public func sequence(from data: Data) {
        do {
            try load(from: data, options: [])
        } catch {
            AKLog("cannot load from data \(error)")
            return
        }
    }

    /// Set loop functionality of entire sequence
    public func toggleLoop() {
        (loopEnabled ? disableLooping() : enableLooping())
    }

    /// Enable looping for all tracks - loops entire sequence
    public func enableLooping() {
        for track in tracks {
            track.isLoopingEnabled = true
            track.loopRange = AVMakeBeatRange(0, self.length.beats)
        }
        loopEnabled = true
    }

    /// Enable looping for all tracks with specified length
    ///
    /// - parameter loopLength: Loop length in beats
    ///
    public func enableLooping(_ loopLength: AKDuration) {
        for track in tracks {
            track.isLoopingEnabled = true
            track.loopRange = AVMakeBeatRange(0, loopLength.beats)
        }
        loopEnabled = true
    }

    /// Disable looping for all tracks
    public func disableLooping() {
        tracks.forEach { track in track.isLoopingEnabled = false }
        loopEnabled = false
    }

    /// Set length of all tracks
    ///
    /// - parameter length: Length of tracks in beats
    ///
    public func setLength(_ length: AKDuration) {
        for track in tracks {
            track.lengthInBeats = length.beats
            track.loopRange = AVMakeBeatRange(0, length.beats)
        }
    }

    /// Length of longest track in the sequence
    public var length: AKDuration {

        var length: MusicTimeStamp = 0
        var tmpLength: MusicTimeStamp = 0

        for track in tracks {
            tmpLength = track.lengthInBeats
            if tmpLength >= length { length = tmpLength }
        }
        return AKDuration(beats: length, tempo: tempo)
    }

    /// Play the sequence
    public func play() {
        do {
            try start()
        } catch _ {
            AKLog("Could not start the sequencer")
        }
    }

    /// Set the Audio Unit output for all tracks - on hold while technology is still unstable
    public func setGlobalAVAudioUnitOutput(_ audioUnit: AVAudioUnit) {
        for track in tracks {
            track.destinationAudioUnit = audioUnit
        }
    }

    /// Current Time
    public var currentPosition: AKDuration {
        return AKDuration(beats: currentPositionInBeats)
    }

    /// Current Time relative to sequencer length
    public var currentRelativePosition: AKDuration {
        return currentPosition % length //can switch to modTime func when/if % is removed
    }

    /// Load a MIDI file
    public func loadMIDIFile(_ filename: String) {
        guard let file = Bundle.main.path(forResource: filename, ofType: "mid") else {
            return
        }
        let fileURL = URL(fileURLWithPath: file)

        do {
            try load(from: fileURL, options: [])
        } catch _ {
            AKLog("failed to load MIDI into sequencer")
        }
    }

    /// Set the midi output for all tracks
    public func setGlobalMIDIOutput(_ midiEndpoint: MIDIEndpointRef) {
        for track in tracks {
            track.destinationMIDIEndpoint = midiEndpoint
        }
    }
}
