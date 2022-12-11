// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AudioUnit
import AVFoundation

/// Voice struct used by the audio thread.
struct SamplerVoice {

    /// Is the voice in use?
    var inUse: Bool = false

    /// Hopefully we can keep the PCMBuffer alive from the audio thread while
    /// still being rt-safe.
    var pcmBuffer: AVAudioPCMBuffer?

    /// Sample data we're playing. Use AudioBufferList directly because we AVAudioPCMBuffer isn't rt-safe.
    ///
    /// Note that we shouldn't actually be mutating this, but the type is more convenient.
    var data: UnsafeMutableAudioBufferListPointer?

    /// Number of frames in the buffer for sake of convenience.
    var sampleFrames: Int = 0

    /// Current frame we're playing. Could be negative to indicate number of frames to wait before playing.
    var playhead: Int = 0

    // Envelope state, etc. would go here.
}

extension SamplerVoice {
    mutating func render(to outputPtr: UnsafeMutableAudioBufferListPointer,
                         frameCount: AVAudioFrameCount) {
        if inUse, let data = self.data {
            for frame in 0..<Int(frameCount) {

                // Our playhead must be in range.
                if playhead >= 0 && playhead < sampleFrames {

                    for channel in 0 ..< data.count where channel < outputPtr.count {

                        let outP = outputPtr[channel].mData!.bindMemory(to: Float.self,
                                                                        capacity: Int(frameCount))

                        let inP = data[channel].mData!.bindMemory(to: Float.self,
                                                                  capacity: Int(self.sampleFrames))

                        outP[frame] += inP[playhead]
                    }

                }

                // Advance playhead by a frame.
                playhead += 1

                // Are we done playing?
                if playhead >= sampleFrames {
                    inUse = false
                    break
                }
            }
        }
    }
}

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
    func allocVoice() -> Int? {
        if let index = voices.firstIndex(where: { !$0.inUse }) {
            voices[index].inUse = true
            return index
        }
        return nil
    }

    /// Associate a midi note with a sample.
    func setSample(_ sample: AVAudioPCMBuffer, midiNote: Int8) {

        // XXX: not thread safe
        samples[Int(midiNote)] = sample
    }

    /// Play a sample immediately.
    func play(_ sample: AVAudioPCMBuffer) {

        // XXX: not thread safe.
        if let voiceIndex = allocVoice() {
            voices[voiceIndex].pcmBuffer = sample
            voices[voiceIndex].data = .init(sample.mutableAudioBufferList)
            voices[voiceIndex].sampleFrames = Int(sample.frameLength)
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
