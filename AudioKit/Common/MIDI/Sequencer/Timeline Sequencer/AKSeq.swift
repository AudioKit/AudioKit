//
//  AKSeq.swift
//  AudioKit
//
//  Created by Jeff Cooper on 10/17/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

open class AKSeq {

    var timeline = AKTimeline()
    public var tracks = [AKSequencerTrack]()

    public var lengthInBeats: Double = 1.0 {
        didSet {
            for track in tracks { track.lengthInBeats = lengthInBeats }
        }
    }

    public var tempo: Double = 120.0 {
        didSet {
            for track in tracks { track.tempo = tempo }
        }
    }

    public var loopEnabled: Bool = true{
        didSet {
            for track in tracks { track.loopEnabled = loopEnabled }
        }
    }

    public init(_ nodes: AKNode...) {
        for (index, node) in nodes.enumerated() {
            tracks.append(AKSequencerTrack(node, index: index))
        }
    }

    public func getTrackFor(node: AKNode) -> AKSequencerTrack? {
        return tracks.first(where: { $0.targetNode == node })
    }

    public func play() {
        for track in tracks {
            track.engine.setBeatTime(0, at: nil)
            track.play()
        }
    }

    public func stop() {
        for track in tracks { track.stop() }
    }

    public func seek(to beat: Double, at time: AVAudioTime) {
        for track in tracks { track.seek(to: beat, at: time) }
    }

    public func stopAllNotes() {
        for track in tracks { track.stopAllNotes() }
    }

    @discardableResult public func add(node: AKNode) -> Int {
        let id = tracks.count
        tracks.append(AKSequencerTrack(node, index: id))
        return id
    }

    @discardableResult public func add(midiPort: MIDIPortRef, midiEndpoint: MIDIEndpointRef, node: AKNode) -> Int {
        let id = tracks.count
        tracks.append(AKSequencerTrack(midiPort: midiPort, midiEndpoint: midiEndpoint, node: node, index: tracks.count))
        return id
    }

    public func loadMIDIFile(path: String) -> [AKMIDIEvent]? {
        print("loadind file at \(path)")
        let url = URL(fileURLWithPath: path)
        let headerSize = 6 //don't know why
        let offset = 0
        if let midiData = try? Data(contentsOf: url) {
            print("got data \(midiData.count)")
            let dataSize = midiData.count
            if dataSize < headerSize + offset {
                AKLog("size of MIDI file is too small - is your file valid?")
                return nil
            }
            let typeLength = 4
            var typeIndex = 0
            let sizeLength = 4
            var sizeIndex = 0
            var dataLength = 0
            var dataIndex = 0
            var chunks = [AKMIDIFileChunk]()
            var currentTypeChunk: [UInt8] = Array(repeating: 0, count: 4)
            var currentLengthChunk: [UInt8] = Array(repeating: 0, count: 4)
            var currentDataChunk: [UInt8] = []
            var newChunk = true
            var isParsingType = false
            var isParsingLength = false
            var isParsingHeader = true
            for i in 0..<dataSize {
                if newChunk {
                    isParsingType = true
                    isParsingLength = false
                    newChunk = false
                    currentTypeChunk = Array(repeating: 0, count: 4)
                    currentLengthChunk = Array(repeating: 0, count: 4)
                    currentDataChunk = []
                }
                if isParsingType { //get chunk type
                    currentTypeChunk[typeIndex] = midiData[i]
                    typeIndex += 1
                    if typeIndex == typeLength {
                        isParsingType = false
                        isParsingLength = true
                        typeIndex = 0
                    }
                } else if isParsingLength { //get chunk length
                    currentLengthChunk[sizeIndex] = midiData[i]
                    sizeIndex += 1
                    if sizeIndex == sizeLength {
                        isParsingLength = false
                        sizeIndex = 0
                        dataLength = Int(currentLengthChunk.map(String.init).joined()) ?? 0
                    }
                } else { //get chunk data
                    var tempChunk: AKMIDIFileChunk
                    currentDataChunk.append(midiData[i])
                    if UInt8(currentDataChunk.count) == dataLength {
                        if isParsingHeader {
                            tempChunk = MIDIFileHeaderChunk(typeData: currentTypeChunk,
                                                            lengthData: currentLengthChunk, data: currentDataChunk)
                        } else {
                            tempChunk = MIDIFileTrackChunk(typeData: currentTypeChunk,
                                                           lengthData: currentLengthChunk, data: currentDataChunk)
                        }
                        newChunk = true
                        isParsingHeader = false
                        chunks.append(tempChunk)
                    }
                }
            }
            for chunk in chunks {
                if let trackChunk = chunk as? MIDIFileTrackChunk {
                    let events = trackChunk.events
                    print("track chunk w \(events.count) events")
                } else {
                    print("header chunk")
                }
            }
        }
        return nil
    }
}

/* functions from aksequencer to implement

 public convenience init(fromURL fileURL: URL) {
 open func enableLooping(_ loopLength: AKDuration) {
 open func setLoopInfo(_ duration: AKDuration, numberOfLoops: Int) {
 open func setLength(_ length: AKDuration) {
 open var length: AKDuration {
 open func setRate(_ rate: Double) {
 open func setTempo(_ bpm: Double) {
 open func addTempoEventAt(tempo bpm: Double, position: AKDuration) {
 open var tempo: Double {
 open func getTempo(at position: MusicTimeStamp) -> Double {
 func clearTempoEvents(_ track: MusicTrack) {
 open func duration(seconds: Double) -> AKDuration {
 open func seconds(duration: AKDuration) -> Double {
 open func rewind() {
 open var isPlaying: Bool {
 open var currentPosition: AKDuration {
 open var currentRelativePosition: AKDuration {
 open var trackCount: Int {
 open func loadMIDIFile(_ filename: String) {
 open func loadMIDIFile(fromURL fileURL: URL) {
 open func addMIDIFileTracks(_ filename: String, useExistingSequencerLength: Bool = true) {
 open func addMIDIFileTracks(_ url: URL, useExistingSequencerLength: Bool = true) {
 open func newTrack(_ name: String = "Unnamed") -> AKMusicTrack? {
 open func deleteTrack(trackIndex: Int) {
 open func clearRange(start: AKDuration, duration: AKDuration) {
 open func setTime(_ time: MusicTimeStamp) {
 open func genData() -> Data? {
 open func debug() {
 open func setGlobalMIDIOutput(_ midiEndpoint: MIDIEndpointRef) {
 open func nearestQuantizedPosition(quantizationInBeats: Double) -> AKDuration {
 open func previousQuantizedPosition(quantizationInBeats: Double) -> AKDuration {
 open func nextQuantizedPosition(quantizationInBeats: Double) -> AKDuration {
 func getQuantizationPositions(quantizationInBeats: Double) -> [AKDuration] {

 */
