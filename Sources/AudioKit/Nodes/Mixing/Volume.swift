// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AudioUnit
import AVFoundation
import Accelerate

public class Volume: Node {
    public let connections: [Node] = []

    public let avAudioNode: AVAudioNode

    let volumeAU: VolumeAudioUnit

    // XXX: should be using parameters
    public var volume: Float { get { volumeAU.volume } set { volumeAU.volume = newValue }}

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
    
    var volume: AUValue = 1.0

    override var internalRenderBlock: AUInternalRenderBlock {
        { (actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
           timeStamp: UnsafePointer<AudioTimeStamp>,
           frameCount: AUAudioFrameCount,
           outputBusNumber: Int,
           outputBufferList: UnsafeMutablePointer<AudioBufferList>,
           renderEvents: UnsafePointer<AURenderEvent>?,
           inputBlock: AURenderPullInputBlock?) in
            
            let ablPointer = UnsafeMutableAudioBufferListPointer(outputBufferList)

            var inputFlags: AudioUnitRenderActionFlags = []
            _ = inputBlock?(&inputFlags, timeStamp, frameCount, 0, outputBufferList)

            for channel in 0..<ablPointer.count {

                let outBuf = UnsafeMutableBufferPointer<Float>(ablPointer[channel])

                let stride = vDSP_Stride(1)
                vDSP_vsmul(outBuf.baseAddress!,
                           stride,
                           &self.volume,
                           outBuf.baseAddress!,
                           stride,
                           vDSP_Length(frameCount))

            }
            
            return noErr
        }
    }
    
}

