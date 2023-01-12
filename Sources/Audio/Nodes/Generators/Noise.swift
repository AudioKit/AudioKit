// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioUnit
import AVFoundation
import Utilities

/// Pure Swift Noise Generator
public class Noise: Node {
    public let connections: [Node] = []

    public let au: AUAudioUnit

    let noiseAU: NoiseAudioUnit

    /// Output Volume (Default 1), values above 1 will have gain applied
    public var amplitude: AUValue = 1.0 {
        didSet {
            amplitude = max(amplitude, 0)
            noiseAU.amplitudeParam.value = amplitude
            start()
        }
    }

    /// Initialize the pure Swift Noise Generator
    /// - Parameters:
    ///   - amplitude: Volume, usually 0-1
    public init(amplitude: AUValue = 1.0) {
        let componentDescription = AudioComponentDescription(instrument: "pgns")

        AUAudioUnit.registerSubclass(NoiseAudioUnit.self,
                                     as: componentDescription,
                                     name: "NoiseGenerator AU",
                                     version: .max)
        au = instantiateAU(componentDescription: componentDescription)
        noiseAU = au as! NoiseAudioUnit
        noiseAU.amplitudeParam.value = amplitude
        self.amplitude = amplitude
        stop()
    }
}

/// Renders an NoiseGenerator
class NoiseAudioUnit: AUAudioUnit {
    private var inputBusArray: AUAudioUnitBusArray!
    private var outputBusArray: AUAudioUnitBusArray!

    let inputChannelCount: NSNumber = 2
    let outputChannelCount: NSNumber = 2

    override public var channelCapabilities: [NSNumber]? {
        return [inputChannelCount, outputChannelCount]
    }

    let amplitudeParam = AUParameterTree.createParameter(identifier: "amplitude", name: "amplitude", address: 0, range: 0 ... 10, unit: .generic, flags: [])

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

        parameterTree = AUParameterTree.createTree(withChildren: [amplitudeParam])

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

    /// Volume usually 0-1
    var amplitude: AUValue = 1

    func processEvents(events: UnsafePointer<AURenderEvent>?) {
        process(events: events,
                param: { event in

                    let paramEvent = event.pointee

                    switch paramEvent.parameterAddress {
                    case 0: amplitude = paramEvent.value
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

                for frame in 0 ..< Int(frameCount) {
                    // Get signal value for this frame at time.
                    let value = self.amplitude * Float.random(in: -1 ... 1)

                    // Set the same value on all channels (due to the inputFormat we have only 1 channel though).
                    for buffer in ablPointer {
                        let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
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
