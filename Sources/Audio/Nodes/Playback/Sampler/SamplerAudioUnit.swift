// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import Utilities

/// Renders contents of a file
class SamplerAudioUnit: AUAudioUnit {
    private var inputBusArray: AUAudioUnitBusArray!
    private var outputBusArray: AUAudioUnitBusArray!

    let inputChannelCount: NSNumber = 2
    let outputChannelCount: NSNumber = 2

    let kernel = SamplerKernel()

    var cachedMIDIBlock: AUScheduleMIDIEventBlock?

    /// Associate a midi note with a sample.
    func setSample(_ sample: AVAudioPCMBuffer, midiNote: UInt8) {
        let holder = UnsafeMutablePointer<SampleHolder>.allocate(capacity: 1)

        holder.initialize(to: SampleHolder(pcmBuffer: sample,
                                           bufferList: .init(sample.mutableAudioBufferList),
                                           frameLength: sample.frameLength))

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
        let command: SamplerCommand = .panic
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
    ///
    /// XXX: should we have an async version that will wait until the sample is played?
    func play(_ sample: AVAudioPCMBuffer) {
        let holder = UnsafeMutablePointer<SampleHolder>.allocate(capacity: 1)

        holder.initialize(to: SampleHolder(pcmBuffer: sample,
                                           bufferList: .init(sample.mutableAudioBufferList),
                                           frameLength: sample.frameLength))

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

    func play(noteNumber: UInt8) {
        if cachedMIDIBlock == nil {
            cachedMIDIBlock = scheduleMIDIEventBlock
            assert(cachedMIDIBlock != nil)
        }

        if let block = cachedMIDIBlock {
            block(.zero, 0, 3, [noteOnByte, noteNumber, 127])
        }
    }

    func stop(noteNumber: UInt8) {
        if cachedMIDIBlock == nil {
            cachedMIDIBlock = scheduleMIDIEventBlock
            assert(cachedMIDIBlock != nil)
        }

        if let block = cachedMIDIBlock {
            block(.zero, 0, 3, [noteOffByte, noteNumber, 0])
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

    override public var channelCapabilities: [NSNumber]? {
        return [inputChannelCount, outputChannelCount]
    }

    /// Initialize with component description and options
    /// - Parameters:
    ///   - componentDescription: Audio Component Description
    ///   - options: Audio Component Instantiation Options
    /// - Throws: error
    override public init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws
    {
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

    override var internalRenderBlock: AUInternalRenderBlock {

        let kernel = self.kernel

        return { (_: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
           _: UnsafePointer<AudioTimeStamp>,
           frameCount: AUAudioFrameCount,
           _: Int,
           outputBufferList: UnsafeMutablePointer<AudioBufferList>,
           renderEvents: UnsafePointer<AURenderEvent>?,
           _: AURenderPullInputBlock?) in

            kernel.processEvents(events: renderEvents)
            return kernel.render(frameCount: frameCount, outputBufferList: outputBufferList)
        }
    }
}
