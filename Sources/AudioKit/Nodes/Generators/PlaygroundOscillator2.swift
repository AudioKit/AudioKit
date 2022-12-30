// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioUnit
import AVFoundation

public class PlaygroundOscillator2: Node {
    public let connections: [Node] = []

    public let avAudioNode: AVAudioNode

    let oscAU: PlaygroundOscillatorAudioUnit

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

    public init(frequency: AUValue = 440, amplitude: AUValue = 1.0) {

        let componentDescription = AudioComponentDescription(instrument: "pgos")

        AUAudioUnit.registerSubclass(PlaygroundOscillatorAudioUnit.self,
                                     as: componentDescription,
                                     name: "Oscillator AU",
                                     version: .max)
        avAudioNode = instantiate(componentDescription: componentDescription)
        oscAU = avAudioNode.auAudioUnit as! PlaygroundOscillatorAudioUnit
        self.oscAU.amplitudeParam.value = amplitude
        self.amplitude = amplitude
        self.oscAU.frequencyParam.value = frequency
        self.frequency = frequency

    }
}


/// Renders an oscillator
class PlaygroundOscillatorAudioUnit: AUAudioUnit {

    private var inputBusArray: AUAudioUnitBusArray!
    private var outputBusArray: AUAudioUnitBusArray!

    let inputChannelCount: NSNumber = 2
    let outputChannelCount: NSNumber = 2

    override public var channelCapabilities: [NSNumber]? {
        return [inputChannelCount, outputChannelCount]
    }

    let frequencyParam = AUParameterTree.createParameter(identifier: "frequency", name: "frequency", address: 0, range: 0...22050, unit: .hertz, flags: [])

    let amplitudeParam = AUParameterTree.createParameter(identifier: "amplitude", name: "amplitude", address: 1, range: 0...10, unit: .generic, flags: [])

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

        parameterTree = AUParameterTree.createTree(withChildren: [frequencyParam, amplitudeParam])

        let paramBlock = self.scheduleParameterBlock

        parameterTree?.implementorValueObserver = { parameter, value in
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

    func processEvents(events: UnsafePointer<AURenderEvent>?) {

        var events = events
        while let event = events {

            if event.pointee.head.eventType == .parameter {

                let paramEvent = event.pointee.parameter

                switch paramEvent.parameterAddress {
                case 0: frequency = paramEvent.value
                case 1: amplitude = paramEvent.value
                default: break
                }
            }

            events = .init(event.pointee.head.next)
        }

    }

    override var internalRenderBlock: AUInternalRenderBlock {
        { (actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
           timeStamp: UnsafePointer<AudioTimeStamp>,
           frameCount: AUAudioFrameCount,
           outputBusNumber: Int,
           outputBufferList: UnsafeMutablePointer<AudioBufferList>,
           renderEvents: UnsafePointer<AURenderEvent>?,
           inputBlock: AURenderPullInputBlock?) in

            let ablPointer = UnsafeMutableAudioBufferListPointer(outputBufferList)

            let twoPi: AUValue = AUValue(2 * Double.pi)
            let phaseIncrement = (twoPi / AUValue(Settings.sampleRate)) * self.frequency
            for frame in 0 ..< Int(frameCount) {
                // Get signal value for this frame at time.
                let value = sin(self.currentPhase) * self.amplitude

                // Advance the phase for the next frame.
                self.currentPhase += phaseIncrement
                if self.currentPhase >= twoPi { self.currentPhase -= twoPi }
                if self.currentPhase < 0.0 { self.currentPhase += twoPi }
                // Set the same value on all channels (due to the inputFormat we have only 1 channel though).
                for buffer in ablPointer {
                    let buf = UnsafeMutableBufferPointer<Float>(buffer)
                    assert(frame < buf.count)
                    buf[frame] = value
                }
            }

            return noErr
        }
    }

}

