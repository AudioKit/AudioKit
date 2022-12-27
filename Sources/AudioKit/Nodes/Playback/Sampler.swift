// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AudioUnit
import AVFoundation

extension AudioBuffer {
    func clear() {
        bzero(mData, Int(mDataByteSize))
    }

    var frameCapacity: AVAudioFrameCount {
        mDataByteSize / UInt32(MemoryLayout<Float>.size)
    }
}

enum SamplerCommand {

    /// Play a sample immediately
    case playSample(UnsafeMutablePointer<SampleHolder>?)

    /// Assign a sample to a midi note number.
    case assignSample(UnsafeMutablePointer<SampleHolder>?, UInt8)

    /// Stop all playback
    case stop
}

/// Renders contents of a file
class SamplerAudioUnit: AUAudioUnit {

    private var inputBusArray: AUAudioUnitBusArray!
    private var outputBusArray: AUAudioUnitBusArray!

    let inputChannelCount: NSNumber = 2
    let outputChannelCount: NSNumber = 2

    var cachedMIDIBlock: AUScheduleMIDIEventBlock?

    /// Returns an available voice. Audio thread ONLY.
    func getVoice() -> Int? {

        // Linear search to find a voice. This could be better
        // using a free list but we're lazy.
        for index in 0..<voices.count {
            if !voices[index].inUse {
                voices[index].inUse = true
                return index
            }
        }

        // No voices available.
        return nil
    }

    /// Associate a midi note with a sample.
    func setSample(_ sample: AVAudioPCMBuffer, midiNote: UInt8) {
        let holder = UnsafeMutablePointer<SampleHolder>.allocate(capacity: 1)

        holder.initialize(to: SampleHolder(pcmBuffer: sample,
                                           bufferList: .init(sample.mutableAudioBufferList)))

        let command: SamplerCommand = .assignSample(holder, midiNote)
        let sysex = encodeSysex(command)

        if cachedMIDIBlock == nil {
            cachedMIDIBlock = scheduleMIDIEventBlock
            assert(cachedMIDIBlock != nil)
        }

        if let block = cachedMIDIBlock {
            block(.zero, 0, sysex.count, sysex)
        }

    }

    func stop() {

        let command: SamplerCommand = .stop
        let sysex = encodeSysex(command)

        if cachedMIDIBlock == nil {
            cachedMIDIBlock = scheduleMIDIEventBlock
            assert(cachedMIDIBlock != nil)
        }

        if let block = cachedMIDIBlock {
            block(.zero, 0, sysex.count, sysex)
        }
    }

    /// Play a sample immediately.
    func play(_ sample: AVAudioPCMBuffer) {

        let holder = UnsafeMutablePointer<SampleHolder>.allocate(capacity: 1)

        holder.initialize(to: SampleHolder(pcmBuffer: sample,
                                           bufferList: .init(sample.mutableAudioBufferList)))

        let command: SamplerCommand = .playSample(holder)
        let sysex = encodeSysex(command)

        if cachedMIDIBlock == nil {
            cachedMIDIBlock = scheduleMIDIEventBlock
            assert(cachedMIDIBlock != nil)
        }

        if let block = cachedMIDIBlock {
            block(.zero, 0, sysex.count, sysex)
        }

    }

    func playMIDINote(_ noteNumber: UInt8) {
        if cachedMIDIBlock == nil {
            cachedMIDIBlock = scheduleMIDIEventBlock
            assert(cachedMIDIBlock != nil)
        }

        if let block = cachedMIDIBlock {
            block(.zero, 0, 3, [0x90, noteNumber, 127])
        }
    }

    /// Free buffers which have been played.
    func collect() {
//        for index in 0..<voices.count {
//            if voices[index].state.load(ordering: .relaxed) == .done {
//                voices[index].pcmBuffer = nil
//                voices[index].data = nil
//                voices[index].playhead = 0
//                voices[index].state.store(.free, ordering: .relaxed)
//            }
//        }
    }

    /// A potential sample for every MIDI note.
    private var samples = [AVAudioPCMBuffer?](repeating: nil, count: 128)

    /// Voices for playing back samples.
    private var voices = [SamplerVoice](repeating: SamplerVoice(), count: 1024)

    override public var channelCapabilities: [NSNumber]? {
        return [inputChannelCount, outputChannelCount]
    }

    /// Initialize with component description and options
    /// - Parameters:
    ///   - componentDescription: Audio Component Description
    ///   - options: Audio Component Instantiation Options
    /// - Throws: error
    override public init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {

        try super.init(componentDescription: componentDescription, options: options)

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
        inputBusArray = AUAudioUnitBusArray(audioUnit: self, busType: .input, busses: [])
        outputBusArray = AUAudioUnitBusArray(audioUnit: self, busType: .output, busses: [try AUAudioUnitBus(format: format)])

        parameterTree = AUParameterTree.createTree(withChildren: [])
    }

    override var inputBusses: AUAudioUnitBusArray {
        inputBusArray
    }

    override var outputBusses: AUAudioUnitBusArray {
        outputBusArray
    }

    override func allocateRenderResources() throws {

    }

    override func deallocateRenderResources() {

    }

    override var internalRenderBlock: AUInternalRenderBlock {
        { (actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
           timeStamp: UnsafePointer<AudioTimeStamp>,
           frameCount: AUAudioFrameCount,
           outputBusNumber: Int,
           outputBufferList: UnsafeMutablePointer<AudioBufferList>,
           renderEvents: UnsafePointer<AURenderEvent>?,
           inputBlock: AURenderPullInputBlock?) in

            var events = renderEvents
            while let event = events {

                switch event.pointee.head.eventType {
                case .MIDI:
                    let data = event.pointee.MIDI.data
                    let command = data.0 & 0xF0
                    let noteNumber = data.1
                    if command == noteOnByte {
                        if let buf = self.samples[Int(noteNumber)] {
                            self.play(buf)
                        }
                    } else if command == noteOffByte {
                        // XXX: ignore for now
                    }
                    break // TODO
                case .midiSysEx:
                    var command: SamplerCommand = SamplerCommand.playSample(nil)
                    decodeSysex(event, &command)

                    switch command {
                    case .playSample(let ptr):
                        if let voiceIndex = self.getVoice() {
                            self.voices[voiceIndex].sample = ptr

                            // XXX: shoudn't be calling frameLength here (ObjC call)
                            self.voices[voiceIndex].sampleFrames = Int(ptr!.pointee.pcmBuffer.frameLength)
                            self.voices[voiceIndex].playhead = 0
                        }

                    case .assignSample(let ptr, let noteNumber):
                        self.samples[Int(noteNumber)] = ptr!.pointee.pcmBuffer
                    case .stop:
                        for index in 0..<self.voices.count {
                            self.voices[index].inUse = false
                        }
                    }
                default:
                    break
                }

                events = .init(event.pointee.head.next)
            }

            let outputBufferListPointer = UnsafeMutableAudioBufferListPointer(outputBufferList)

            // Clear output.
            for channel in 0 ..< outputBufferListPointer.count {
                outputBufferListPointer[channel].clear()
            }

            // Render all active voices to output.
            for voiceIndex in self.voices.indices {
                self.voices[voiceIndex].render(to: outputBufferListPointer, frameCount: frameCount)
            }

            return noErr
        }
    }

}

public class Sampler: Node {
    public let connections: [Node] = []

    public let avAudioNode: AVAudioNode
    let samplerAU: SamplerAudioUnit

    public init() {
        let componentDescription = AudioComponentDescription(instrument: "tpla")

        AUAudioUnit.registerSubclass(SamplerAudioUnit.self,
                                     as: componentDescription,
                                     name: "Player AU",
                                     version: .max)
        avAudioNode = instantiate(componentDescription: componentDescription)
        samplerAU = avAudioNode.auAudioUnit as! SamplerAudioUnit
    }

    public func stop() {
        samplerAU.stop()
    }

    public func play(_ buffer: AVAudioPCMBuffer) {
        samplerAU.play(buffer)
        samplerAU.collect()
    }

    public func play(url: URL) {
        if let buffer = try? AVAudioPCMBuffer(url: url) {
            play(buffer)
        }
    }

    public func assign(_ buffer: AVAudioPCMBuffer, to midiNote: UInt8) {
        samplerAU.setSample(buffer, midiNote: midiNote)
    }

    public func assign(url: URL, to midiNote: UInt8) {
        if let buffer = try? AVAudioPCMBuffer(url: url) {
            assign(buffer, to: midiNote)
        }
    }

    public func playMIDINote(_ noteNumber: UInt8) {
        samplerAU.playMIDINote(noteNumber)
    }

}
