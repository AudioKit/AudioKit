// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AudioUnit
import AVFoundation
import Atomics

extension AudioBuffer {
    func clear() {
        bzero(mData, Int(mDataByteSize))
    }
}

/// Renders contents of a file
class SamplerAudioUnit: AUAudioUnit {

    private var inputBusArray: AUAudioUnitBusArray!
    private var outputBusArray: AUAudioUnitBusArray!

    let inputChannelCount: NSNumber = 2
    let outputChannelCount: NSNumber = 2

    /// Returns an available voice
    func getVoice() -> Int? {

        // Compare and swap until we find a voice.
        for index in 0..<voices.count {

            // Using CAS here prevents a race where multiple threads
            // are trying to allocate a voice.
            if voices[index].state.compareExchange(expected: .free, desired: .allocated, ordering: .relaxed).exchanged {
                return index
            }
        }

        // No voices available.
        return nil
    }

    /// Associate a midi note with a sample.
    func setSample(_ sample: AVAudioPCMBuffer, midiNote: Int8) {

        // XXX: not thread safe
        samples[Int(midiNote)] = sample
    }

    /// Play a sample immediately.
    func play(_ sample: AVAudioPCMBuffer) {

        if let voiceIndex = getVoice() {
            voices[voiceIndex].pcmBuffer = sample
            voices[voiceIndex].data = .init(sample.mutableAudioBufferList)
            voices[voiceIndex].sampleFrames = Int(sample.frameLength)
            voices[voiceIndex].playhead = 0

            // Once we're doing setting up the voice, mark it as
            // active so the render thread may use it.
            voices[voiceIndex].state.store(.active, ordering: .relaxed)
        }

        collect()
    }

    /// Free buffers which have been played.
    func collect() {
        for index in 0..<voices.count {
            if voices[index].state.load(ordering: .relaxed) == .done {
                voices[index].pcmBuffer = nil
                voices[index].data = nil
                voices[index].playhead = 0
                voices[index].state.store(.free, ordering: .relaxed)
            }
        }
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

            if let event = renderEvents {
                if event.pointee.head.eventType == .MIDI {

                }
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

class Sampler: Node {
    let connections: [Node] = []

    let avAudioNode: AVAudioNode
    let samplerAU: SamplerAudioUnit

    init() {
        let componentDescription = AudioComponentDescription(generator: "tpla")

        AUAudioUnit.registerSubclass(SamplerAudioUnit.self,
                                     as: componentDescription,
                                     name: "Player AU",
                                     version: .max)
        avAudioNode = instantiate(componentDescription: componentDescription)
        samplerAU = avAudioNode.auAudioUnit as! SamplerAudioUnit
    }

    func play(_ buffer: AVAudioPCMBuffer) {
        samplerAU.play(buffer)
    }
}
