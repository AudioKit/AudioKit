// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AudioUnit
import AVFoundation
import Accelerate

public class Volume: Node {
    public let connections: [Node] = []

    public let avAudioNode: AVAudioNode

    let volumeAU: VolumeAudioUnit

    public var volume: Float { get { volumeAU.volumeParam.value } set { volumeAU.volumeParam.value = newValue }}
    public var pan: Float { get { volumeAU.panParam.value } set { volumeAU.panParam.value = newValue }}

    public init() {

        let componentDescription = AudioComponentDescription(effect: "volu")

        AUAudioUnit.registerSubclass(VolumeAudioUnit.self,
                                     as: componentDescription,
                                     name: "Volume AU",
                                     version: .max)
        avAudioNode = instantiate(componentDescription: componentDescription)
        volumeAU = avAudioNode.auAudioUnit as! VolumeAudioUnit
    }
}


/// Changes the volume of input.
class VolumeAudioUnit: AUAudioUnit {

    private var inputBusArray: AUAudioUnitBusArray!
    private var outputBusArray: AUAudioUnitBusArray!

    let inputChannelCount: NSNumber = 2
    let outputChannelCount: NSNumber = 2

    override public var channelCapabilities: [NSNumber]? {
        return [inputChannelCount, outputChannelCount]
    }

    let volumeParam = AUParameterTree.createParameter(identifier: "volume", name: "volume", address: 0, range: 0...10, unit: .generic, flags: [])

    let panParam = AUParameterTree.createParameter(identifier: "pan", name: "pan", address: 1, range: -1...1, unit: .generic, flags: [])

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

        parameterTree = AUParameterTree.createTree(withChildren: [volumeParam, panParam])

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
    
    private var volume: AUValue = 1.0
    private var pan: AUValue = 0.0

    func processEvents(events: UnsafePointer<AURenderEvent>?) {

        var events = events
        while let event = events {

            if event.pointee.head.eventType == .parameter {

                let paramEvent = event.pointee.parameter

                switch paramEvent.parameterAddress {
                case 0: volume = paramEvent.value
                case 1: pan = paramEvent.value
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

            self.processEvents(events: renderEvents)
            
            let ablPointer = UnsafeMutableAudioBufferListPointer(outputBufferList)

            // Better be stereo.
            assert(ablPointer.count == 2)

            var inputFlags: AudioUnitRenderActionFlags = []
            _ = inputBlock?(&inputFlags, timeStamp, frameCount, 0, outputBufferList)

            let outBufL = UnsafeMutableBufferPointer<Float>(ablPointer[0])
            let outBufR = UnsafeMutableBufferPointer<Float>(ablPointer[1])
            for frame in 0..<Int(frameCount) {

                if self.pan > 0 {
                    outBufL[frame] *= 1.0 - self.pan
                } else if self.pan < 0 {
                    outBufR[frame] *= 1.0 + self.pan
                }
                outBufL[frame] *= self.volume
                outBufR[frame] *= self.volume

            }
            return noErr
        }
    }
    
}

