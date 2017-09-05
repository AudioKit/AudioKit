//
//  AKMIDIPlayer.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

/// Simple MIDI Player based on Apple's AVAudioSequencer which has limited capabilities
public class AKMIDIPlayer {
    public var sequencer = AVAudioSequencer()
    public var tempo: Double = 120.0

    /// Array of AudioKit Music Tracks
    public var tracks: [AVMusicTrack] {
        return sequencer.tracks
    }

    /// Loop control
    public var loopEnabled: Bool = false

    /// Sequencer Initialization
    public init() {
        sequencer = AVAudioSequencer(audioEngine: AudioKit.engine)
    }

    /// Initialize the sequence with a MIDI file
    ///
    /// - parameter filename: Location of the MIDI File
    ///
    public convenience init(filename: String) {
        self.init()
        sequencer = AVAudioSequencer(audioEngine: AudioKit.engine)
        loadMIDIFile(filename)
    }

    /// Load a sequence from data
    ///
    /// - parameter data: data to create sequence from
    ///
    public func sequenceFromData(_ data: Data) {
        let options = AVMusicSequenceLoadOptions()

        do {
            try sequencer.load(from: data, options: options)
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
        for track in sequencer.tracks {
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
        for track in sequencer.tracks {
            track.isLoopingEnabled = true
            track.loopRange = AVMakeBeatRange(0, self.length.beats)
        }
        loopEnabled = true
    }

    /// Disable looping for all tracks
    public func disableLooping() {
        sequencer.tracks.forEach { track in track.isLoopingEnabled = false }
        loopEnabled = false
    }

    /// Set length of all tracks
    ///
    /// - parameter length: Length of tracks in beats
    ///
    public func setLength(_ length: AKDuration) {
        for track in sequencer.tracks {
            track.lengthInBeats = length.beats
            track.loopRange = AVMakeBeatRange(0, length.beats)
        }
    }

    /// Length of longest track in the sequence
    public var length: AKDuration {

        var length: MusicTimeStamp = 0
        var tmpLength: MusicTimeStamp = 0

        for track in sequencer.tracks {
            tmpLength = track.lengthInBeats
            if tmpLength >= length { length = tmpLength }
        }
        return  AKDuration(beats: length, tempo: tempo)
    }

    /// Rate relative to the default tempo (BPM) of the track
    public var rate: Double {
        set {
            sequencer.rate = Float(rate)
        }
        get {
            return Double(sequencer.rate)
        }
    }

    /// Play the sequence
    public func play() {
        do {
            try sequencer.start()
        } catch _ {
            AKLog("Could not start the sequencer")
        }
    }

    /// Stop the sequence
    public func stop() {
        sequencer.stop()
    }

    /// Rewind the sequence
    public func rewind() {
        sequencer.currentPositionInBeats = 0
    }

    /// Set the Audio Unit output for all tracks - on hold while technology is still unstable
    public func setGlobalAVAudioUnitOutput(_ audioUnit: AVAudioUnit) {
        for track in sequencer.tracks {
            track.destinationAudioUnit = audioUnit
        }
    }

    /// Wheter or not the sequencer is currently playing
    public var isPlaying: Bool {
        return sequencer.isPlaying
    }

    /// Current Time
    public var currentPosition: AKDuration {
        return AKDuration(beats: sequencer.currentPositionInBeats)
    }

    /// Current Time relative to sequencer length
    public var currentRelativePosition: AKDuration {
        return currentPosition % length //can switch to modTime func when/if % is removed
    }

    /// Track count
    public var trackCount: Int {
        return sequencer.tracks.count
    }

    /// Load a MIDI file
    public func loadMIDIFile(_ filename: String) {
        let bundle = Bundle.main
        guard let file = bundle.path(forResource: filename, ofType: "mid") else {
            return
        }
        let fileURL = URL(fileURLWithPath: file)

        do {
            try sequencer.load(from: fileURL, options: AVMusicSequenceLoadOptions())
        } catch _ {
            AKLog("failed to load MIDI into sequencer")
        }
    }

    /// Set the midi output for all tracks
    public func setGlobalMIDIOutput(_ midiEndpoint: MIDIEndpointRef) {
        for track in sequencer.tracks {
            track.destinationMIDIEndpoint = midiEndpoint
        }
    }
}
