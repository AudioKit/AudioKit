// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)

import AVFoundation

extension MIDIPlayer: Collection {
    /// This is a collection of AVMusicTracks, so we define element as such
    public typealias Element = AVMusicTrack

    /// Index by an integer
    public typealias Index = Int

    /// Start Index
    public var startIndex: Index {
        return 0
    }

    /// Ending index
    public var endIndex: Index {
        return count
    }

    /// Look up by subscript
    public subscript(index: Index) -> Element {
        return tracks[index]
    }

    /// Next index
    /// - Parameter index: Current Index
    /// - Returns: Next index
    public func index(after index: Index) -> Index {
        return index + 1
    }

    /// Rewind the sequence
    public func rewind() {
        currentPositionInBeats = 0
    }
}

/// Simple MIDI Player based on Apple's AVAudioSequencer which has limited capabilities
public class MIDIPlayer: AVAudioSequencer {

    /// Tempo in beats per minute
    public var tempo: Double = 120.0

    /// Loop control
    public var loopEnabled: Bool = false

    /// Initialize the sequence with a MIDI file
    ///
    /// - parameter filename: Location of the MIDI File
    /// - parameter audioEngine: AVAudioEngine to associate with
    ///
    public init(audioEngine: AVAudioEngine, filename: String) {
        super.init(audioEngine: audioEngine)
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
            Log("cannot load from data \(error)")
            return
        }
    }

    /// Set loop functionality of entire sequence
    public func toggleLoop() {
        (loopEnabled ? disableLooping() : enableLooping())
    }

    /// Enable looping for all tracks - loops entire sequence
    public func enableLooping() {
        enableLooping(length)
    }

    /// Enable looping for all tracks with specified length
    ///
    /// - parameter loopLength: Loop length in beats
    ///
    public func enableLooping(_ loopLength: Duration) {
        for track in self {
            track.isLoopingEnabled = true
            track.loopRange = AVMakeBeatRange(0, loopLength.beats)
        }
        loopEnabled = true
    }

    /// Disable looping for all tracks
    public func disableLooping() {
        for track in self { track.isLoopingEnabled = false }
        loopEnabled = false
    }

    /// Length of longest track in the sequence
    public var length: Duration {
        get {
            let l = lazy.map { $0.lengthInBeats }.max() ?? 0
            return Duration(beats: l, tempo: tempo)
        }
        set {
            for track in self {
                track.lengthInBeats = newValue.beats
                track.loopRange = AVMakeBeatRange(0, newValue.beats)
            }
        }
    }

    /// Play the sequence
    public func play() {
        do {
            try start()
        } catch _ {
            Log("Could not start the sequencer")
        }
    }

    /// Set the Audio Unit output for all tracks - on hold while technology is still unstable
    public func setGlobalAVAudioUnitOutput(_ audioUnit: AVAudioUnit) {
        for track in self { track.destinationAudioUnit = audioUnit }
    }

    /// Current Time
    public var currentPosition: Duration {
        return Duration(beats: currentPositionInBeats)
    }

    /// Current Time relative to sequencer length
    public var currentRelativePosition: Duration {
        return currentPosition % length //can switch to modTime func when/if % is removed
    }

    /// Load a MIDI file
    /// - Parameter filename: MIDI FIle name
    public func loadMIDIFile(_ filename: String) {
        guard let file = Bundle.main.path(forResource: filename, ofType: "mid") else {
            return
        }
        let fileURL = URL(fileURLWithPath: file)

        do {
            try load(from: fileURL, options: [])
        } catch _ {
            Log("failed to load MIDI into sequencer")
        }
    }

    /// Set the midi output for all tracks
    /// - Parameter midiEndpoint: MIDI Endpoint
    public func setGlobalMIDIOutput(_ midiEndpoint: MIDIEndpointRef) {
        for track in self { track.destinationMIDIEndpoint = midiEndpoint }
    }
}
#endif
