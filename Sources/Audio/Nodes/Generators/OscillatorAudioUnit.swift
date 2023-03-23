// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioUnit
import AVFoundation
import Utilities

/// Renders an oscillator
class OscillatorAudioUnit: AUAudioUnit {
    private var inputBusArray: AUAudioUnitBusArray!
    private var outputBusArray: AUAudioUnitBusArray!

    let inputChannelCount: NSNumber = 2
    let outputChannelCount: NSNumber = 2

    override public var channelCapabilities: [NSNumber]? {
        return [inputChannelCount, outputChannelCount]
    }

    var cachedMIDIBlock: AUScheduleMIDIEventBlock?

    let frequencyParam = AUParameterTree.createParameter(identifier: "frequency",
                                                         name: "frequency",
                                                         address: 0,
                                                         range: 0 ... 22050,
                                                         unit: .hertz,
                                                         flags: [])

    let amplitudeParam = AUParameterTree.createParameter(identifier: "amplitude",
                                                         name: "amplitude",
                                                         address: 1,
                                                         range: 0 ... 10,
                                                         unit: .generic,
                                                         flags: [])

    func setWaveform(_ waveform: Table) {
        let waveVec = Vec<Float>(waveform.content)
        let holder = UnsafeMutablePointer<Vec<Float>>.allocate(capacity: 1)

        holder.initialize(to: waveVec)

        let command: OscillatorCommand = .table(holder)
        let sysex = encodeSysex(command)

        if cachedMIDIBlock == nil {
            cachedMIDIBlock = scheduleMIDIEventBlock
            assert(cachedMIDIBlock != nil)
        }

        if let block = cachedMIDIBlock {
            block(.zero, 0, sysex.count, sysex)
        }
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

        parameterTree = AUParameterTree.createTree(withChildren: [frequencyParam, amplitudeParam])

        let paramBlock = scheduleParameterBlock

        parameterTree?.implementorValueObserver = { parameter, _ in
            paramBlock(.zero, 0, parameter.address, parameter.value)
        }
    }

    override var inputBusses: AUAudioUnitBusArray {
        inputBusArray
    }

    override var outputBusses: AUAudioUnitBusArray {
        outputBusArray
    }

    override func allocateRenderResources() throws {
        try super.allocateRenderResources()
        kernel.sampleRate = outputBusArray[0].format.sampleRate
    }

    override var shouldBypassEffect: Bool {
        didSet {
            kernel.bypassed = shouldBypassEffect
        }
    }

    var kernel = OscillatorKernel()

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
