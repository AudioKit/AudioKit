// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioUnit
import AVFoundation
import Utilities

enum OscillatorCommand {
    case table(UnsafeMutablePointer<Table>?)
}

public class Oscillator: Node {
    public let connections: [Node] = []

    public let au: AUAudioUnit

    let oscAU: OscillatorAudioUnit

    public var waveform: Table? {
        didSet {
            if let waveform = waveform {
                oscAU.setWaveform(waveform)
            }
        }
    }

    /// Output Volume (Default 1), values above 1 will have gain applied
    public var amplitude: AUValue = 1.0 {
        didSet {
            amplitude = max(amplitude, 0)
            oscAU.amplitudeParam.value = amplitude
        }
    }

    // Frequency in Hz
    public var frequency: AUValue = 440 {
        didSet {
            frequency = max(frequency, 0)
            oscAU.frequencyParam.value = frequency
        }
    }

    /// Initialize the pure Swift oscillator
    /// - Parameters:
    ///   - waveform: Shape of the oscillator waveform
    ///   - frequency: Pitch in Hz
    ///   - amplitude: Volume, usually 0-1
    public init(waveform: Table = Table(.sine), frequency: AUValue = 440, amplitude: AUValue = 1.0) {
        let componentDescription = AudioComponentDescription(instrument: "pgos")

        AUAudioUnit.registerSubclass(OscillatorAudioUnit.self,
                                     as: componentDescription,
                                     name: "Oscillator AU",
                                     version: .max)
        au = instantiateAU(componentDescription: componentDescription)
        oscAU = au as! OscillatorAudioUnit
        self.waveform = waveform
        oscAU.amplitudeParam.value = amplitude
        self.amplitude = amplitude
        oscAU.frequencyParam.value = frequency
        self.frequency = frequency
        oscAU.setWaveform(waveform)
        self.waveform = waveform
        stop()
    }
}

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

    let frequencyParam = AUParameterTree.createParameter(identifier: "frequency", name: "frequency", address: 0, range: 0 ... 22050, unit: .hertz, flags: [])

    let amplitudeParam = AUParameterTree.createParameter(identifier: "amplitude", name: "amplitude", address: 1, range: 0 ... 10, unit: .generic, flags: [])

    func setWaveform(_ waveform: Table) {
        let holder = UnsafeMutablePointer<Table>.allocate(capacity: 1)

        holder.initialize(to: waveform)

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

    override func allocateRenderResources() throws {}

    override func deallocateRenderResources() {}

    var currentPhase: AUValue = 0.0

    /// Pitch in Hz
    var frequency: AUValue = 440

    /// Volume usually 0-1
    var amplitude: AUValue = 1

    private var table = Table()

    func processEvents(events: UnsafePointer<AURenderEvent>?) {
        process(events: events,
                sysex: { event in
                    var command: OscillatorCommand = .table(nil)

                    decodeSysex(event, &command)
                    switch command {
                    case let .table(ptr):
                        table = ptr?.pointee ?? Table()
                    }
                }, param: { event in
                    let paramEvent = event.pointee
                    switch paramEvent.parameterAddress {
                    case 0: frequency = paramEvent.value
                    case 1: amplitude = paramEvent.value
                    default: break
                    }
                })
    }

    override var internalRenderBlock: AUInternalRenderBlock {
        { (_: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
           _: UnsafePointer<AudioTimeStamp>,
           frameCount: AUAudioFrameCount,
           _: Int,
           outputBufferList: UnsafeMutablePointer<AudioBufferList>,
           renderEvents: UnsafePointer<AURenderEvent>?,
           _: AURenderPullInputBlock?) in

            self.processEvents(events: renderEvents)

            let ablPointer = UnsafeMutableAudioBufferListPointer(outputBufferList)

            let twoPi: AUValue = .init(2 * Double.pi)
            let phaseIncrement = (twoPi / AUValue(Settings.sampleRate)) * self.frequency
            for frame in 0 ..< Int(frameCount) {
                // Get signal value for this frame at time.
                let index = Int(self.currentPhase / twoPi * Float(self.table.count))
                let value = self.table[index] * self.amplitude

                // Advance the phase for the next frame.
                self.currentPhase += phaseIncrement
                if self.currentPhase >= twoPi { self.currentPhase -= twoPi }
                if self.currentPhase < 0.0 { self.currentPhase += twoPi }
                // Set the same value on all channels (due to the inputFormat we have only 1 channel though).
                for buffer in ablPointer {
                    let buf = UnsafeMutableBufferPointer<Float>(buffer)
                    assert(frame < buf.count)
                    if self.shouldBypassEffect {
                        buf[frame] = 0
                    } else {
                        buf[frame] = value
                    }
                }
            }

            return noErr
        }
    }
}
