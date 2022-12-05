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

    /// Sample data we're playing. Use AudioBufferList directly because we don't know if
    /// accessing an AVAudioPCMBuffer from the audio thread is rt-safe.
    var data: UnsafePointer<AudioBufferList>?

    /// Current frame we're playing. Could be negative to indicate number of frames to wait before playing.
    var playhead: Int = 0

    // Envelope state, etc. would go here.
}

/// Renders contents of a file
class SamplerAudioUnit: AUAudioUnit {

    private var inputBusArray: AUAudioUnitBusArray!
    private var outputBusArray: AUAudioUnitBusArray!

    let inputChannelCount: NSNumber = 2
    let outputChannelCount: NSNumber = 2

    var floatChannelDatas: [FloatChannelData] = []
    var files: [AVAudioFile] = [] {
        didSet {
            floatChannelDatas.removeAll()
            for file in files {
                if let data = file.toFloatChannelData() {
                    floatChannelDatas.append(data)
                }
            }
        }
    }

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
    func playSample(_ sample: AVAudioPCMBuffer) {

        // XXX: not thread safe.
        if let voiceIndex = allocVoice() {
            voices[voiceIndex].pcmBuffer = sample
            voices[voiceIndex].data = sample.audioBufferList
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

    var playheadInSamples: Int = 0
    var isPlaying: Bool = false

    override var internalRenderBlock: AUInternalRenderBlock {
        { (actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
           timeStamp: UnsafePointer<AudioTimeStamp>,
           frameCount: AUAudioFrameCount,
           outputBusNumber: Int,
           outputBufferList: UnsafeMutablePointer<AudioBufferList>,
           renderEvents: UnsafePointer<AURenderEvent>?,
           inputBlock: AURenderPullInputBlock?) in

            let ablPointer = UnsafeMutableAudioBufferListPointer(outputBufferList)

            for frame in 0 ..< Int(frameCount) {
                var value: Float = 0.0
                let sample = self.playheadInSamples + frame
                if sample < self.floatChannelDatas[0][0].count {
                    value = self.floatChannelDatas[0][0][sample]
                }
                for buffer in ablPointer {
                    let buf = UnsafeMutableBufferPointer<Float>(buffer)
                    assert(frame < buf.count)
                    buf[frame] = self.isPlaying ? value : 0.0
                }
            }
            if self.isPlaying {
                self.playheadInSamples += Int(frameCount)
            }

            return noErr
        }
    }

}

class Sampler: Node {
    let connections: [Node] = []

    let avAudioNode: AVAudioNode
    let samplerAU: SamplerAudioUnit

    /// Position of playback in seconds
    var playheadPosition: Double = 0.0

    func movePlayhead(to position: Double) {
        samplerAU.playheadInSamples = Int(position * 44100)
    }

    func rewind() {
        movePlayhead(to: 0)
    }

    func play() {
        samplerAU.isPlaying = true
    }

    func stop() {
        samplerAU.isPlaying = false
    }


    init(file: AVAudioFile) {

        let componentDescription = AudioComponentDescription(generator: "tpla")

        AUAudioUnit.registerSubclass(SamplerAudioUnit.self,
                                     as: componentDescription,
                                     name: "Player AU",
                                     version: .max)
        avAudioNode = instantiate(componentDescription: componentDescription)
        samplerAU = avAudioNode.auAudioUnit as! SamplerAudioUnit
        samplerAU.files.append(file)
    }
}
