// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)

import AVFoundation

extension AVAudioSequencer: Collection {
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

    /// Initialize the sequence with a MIDI file
    ///
    /// - parameter filename: Location of the MIDI File
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
        enableLooping(length)
    }

    /// Enable looping for all tracks with specified length
    ///
    /// - parameter loopLength: Loop length in beats
    ///
    public func enableLooping(_ loopLength: AKDuration) {
        forEach {
            $0.isLoopingEnabled = true
            $0.loopRange = AVMakeBeatRange(0, loopLength.beats)
        }
        loopEnabled = true
    }

    /// Disable looping for all tracks
    public func disableLooping() {
        forEach { $0.isLoopingEnabled = false }
        loopEnabled = false
    }

    /// Length of longest track in the sequence
    public var length: AKDuration {
        get {
            let l = lazy.map { $0.lengthInBeats }.max() ?? 0
            return AKDuration(beats: l, tempo: tempo)
        }
        set {
            forEach {
                $0.lengthInBeats = newValue.beats
                $0.loopRange = AVMakeBeatRange(0, newValue.beats)
            }
        }
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
        forEach {
            $0.destinationAudioUnit = audioUnit
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
        forEach {
            $0.destinationMIDIEndpoint = midiEndpoint
        }
    }
}
#endif

