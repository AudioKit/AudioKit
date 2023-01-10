// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AudioUnit
import AVFoundation
import AudioKit

public class ConstantGenerator: Node {
    public var au: AUAudioUnit
    
    public let connections: [Node] = []

    let oscAU: ConstantGeneratorAudioUnit

    // XXX: should be using parameters
    public var constant: Float { get { oscAU.constant } set { oscAU.constant = newValue }}

    public init(constant: Float) {

        let componentDescription = AudioComponentDescription(generator: "cgen")

        AUAudioUnit.registerSubclass(ConstantGeneratorAudioUnit.self,
                                     as: componentDescription,
                                     name: "constant generator AU",
                                     version: .max)
        au = instantiateAU(componentDescription: componentDescription)
        oscAU = au as! ConstantGeneratorAudioUnit
        self.constant = constant
    }
}


/// Renders a sine wave.
class ConstantGeneratorAudioUnit: AUAudioUnit {

    private var inputBusArray: AUAudioUnitBusArray!
    private var outputBusArray: AUAudioUnitBusArray!

    let inputChannelCount: NSNumber = 2
    let outputChannelCount: NSNumber = 2

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

    override func allocateRenderResources() throws {}

    override func deallocateRenderResources() {}

    var constant: Float = 0

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
                for buffer in ablPointer {
                    let buf = UnsafeMutableBufferPointer<Float>(buffer)
                    assert(frame < buf.count)
                    buf[frame] = self.constant
                }
            }

            return noErr
        }
    }

}
