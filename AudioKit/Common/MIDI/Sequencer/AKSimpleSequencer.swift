//
//  AKSimpleSequencer.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Sequencer based on the AV Audio Engine Sequencer
open class AKSimpleSequencer {

    open var avSequencer = AVAudioSequencer()
    open var tempo: Double = 120.0
    
    /// Array of AudioKit Music Tracks
    open var tracks: [AVMusicTrack] {
        return avSequencer.tracks
    }

    /// Loop control
    public var loopEnabled: Bool = false

    /// Sequencer Initialization
    public init() {
        avSequencer = AVAudioSequencer(audioEngine: AudioKit.engine)
    }

    /// Initialize the sequence with a MIDI file
    ///
    /// - parameter filename: Location of the MIDI File
    ///
    public convenience init(filename: String) {
        self.init()
        avSequencer = AVAudioSequencer(audioEngine: AudioKit.engine)
        loadMIDIFile(filename)
    }

    /// Load a sequence from data
    ///
    /// - parameter data: data to create sequence from
    ///
    open func sequenceFromData(_ data: Data) {
        let options = AVMusicSequenceLoadOptions()

        do {
            try avSequencer.load(from: data, options: options)
        } catch {
            AKLog("cannot load from data \(error)")
            return
        }
    }

    /// Set loop functionality of entire sequence
    open func toggleLoop() {
        (loopEnabled ? disableLooping() : enableLooping())
    }

    /// Enable looping for all tracks - loops entire sequence
    open func enableLooping() {
        for track in avSequencer.tracks {
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
        for track in avSequencer.tracks {
            track.isLoopingEnabled = true
            track.loopRange = AVMakeBeatRange(0, self.length.beats)
        }
        loopEnabled = true
    }

    /// Disable looping for all tracks
    open func disableLooping() {
        avSequencer.tracks.forEach { track in track.isLoopingEnabled = false }
        loopEnabled = false
    }

    /// Set length of all tracks
    ///
    /// - parameter length: Length of tracks in beats
    ///
    open func setLength(_ length: AKDuration) {
        for track in avSequencer.tracks {
            track.lengthInBeats = length.beats
            track.loopRange = AVMakeBeatRange(0, length.beats)
        }
    }

    /// Length of longest track in the sequence
    open var length: AKDuration {

        var length: MusicTimeStamp = 0
        var tmpLength: MusicTimeStamp = 0

        for track in avSequencer.tracks {
            tmpLength = track.lengthInBeats
            if tmpLength >= length { length = tmpLength }
        }
        return  AKDuration(beats: length, tempo: tempo)
    }

    /// Set the rate of the sequencer
    /// 
    /// - parameter rate: Set the rate relative to the tempo of the track
    ///
    open func setRate(_ rate: Double) {
        avSequencer.rate = Float(rate)
    }

    /// Rate relative to the default tempo (BPM) of the track
    open var rate: Double {
        return Double(avSequencer.rate)
    }

    /// Play the sequence
    open func play() {
        do {
            try avSequencer.start()
        } catch _ {
            AKLog("Could not start the sequencer")
        }
    }

    /// Stop the sequence
    open func stop() {
        avSequencer.stop()
    }

    /// Rewind the sequence
    open func rewind() {
        avSequencer.currentPositionInBeats = 0
    }

    /// Set the Audio Unit output for all tracks - on hold while technology is still unstable
    open func setGlobalAVAudioUnitOutput(_ audioUnit: AVAudioUnit) {
        for track in avSequencer.tracks {
            track.destinationAudioUnit = audioUnit
        }
    }

    /// Wheter or not the sequencer is currently playing
    open var isPlaying: Bool {
        return avSequencer.isPlaying
    }

    /// Current Time
    open var currentPosition: AKDuration {
        return AKDuration(beats: avSequencer.currentPositionInBeats)
    }
    
    /// Current Time relative to sequencer length
    open var currentRelativePosition: AKDuration {
        return currentPosition % length //can switch to modTime func when/if % is removed
    }

    /// Track count
    open var trackCount: Int {
        return avSequencer.tracks.count
    }

    /// Load a MIDI file
    open func loadMIDIFile(_ filename: String) {
        let bundle = Bundle.main
        guard let file = bundle.path(forResource: filename, ofType: "mid") else {
            return
        }
        let fileURL = URL(fileURLWithPath: file)
        
        do {
            try avSequencer.load(from: fileURL, options: AVMusicSequenceLoadOptions())
        } catch _ {
            AKLog("failed to load MIDI into AVSequencer")
        }
    }

    /// Set the midi output for all tracks
    open func setGlobalMIDIOutput(_ midiEndpoint: MIDIEndpointRef) {
        for track in avSequencer.tracks {
            track.destinationMIDIEndpoint = midiEndpoint
        }
    }

    /// Nearest time of quantized beat
    open func nearestQuantizedPosition(quantizationInBeats: Double) -> AKDuration {
        let noteOnTimeRel = currentRelativePosition.beats
        let quantizationPositions = getQuantizationPositions(quantizationInBeats: quantizationInBeats)
        let lastSpot = quantizationPositions[0]
        let nextSpot = quantizationPositions[1]
        let diffToLastSpot = AKDuration(beats: noteOnTimeRel) - lastSpot
        let diffToNextSpot = nextSpot - AKDuration(beats: noteOnTimeRel)
        let optimizedQuantTime = (diffToLastSpot < diffToNextSpot ? lastSpot : nextSpot)
        return optimizedQuantTime
    }

    /// The last quantized beat
    open func previousQuantizedPosition(quantizationInBeats: Double) -> AKDuration {
        return getQuantizationPositions(quantizationInBeats: quantizationInBeats)[0]
    }

    /// Next quantized beat
    open func nextQuantizedPosition(quantizationInBeats: Double) -> AKDuration {
        return getQuantizationPositions(quantizationInBeats: quantizationInBeats)[1]
    }

    /// An array of all quantization points
    func getQuantizationPositions(quantizationInBeats: Double) -> [AKDuration] {
        let noteOnTimeRel = currentRelativePosition.beats
        let lastSpot = AKDuration(beats:
            modTime(noteOnTimeRel - (noteOnTimeRel.truncatingRemainder(dividingBy: quantizationInBeats))))
        let nextSpot = AKDuration(beats: modTime(lastSpot.beats + quantizationInBeats))
        return [lastSpot, nextSpot]
    }

    /// Time modulus
    func modTime(_ time: Double) -> Double {
        return time.truncatingRemainder(dividingBy: length.beats)
    }
}
