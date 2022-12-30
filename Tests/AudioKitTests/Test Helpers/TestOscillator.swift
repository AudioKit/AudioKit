// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AudioUnit
import AVFoundation
import AudioKit

public class TestOscillator: Node {
    public let connections: [Node] = []

    public let avAudioNode: AVAudioNode

    let oscAU: TestOscillatorAudioUnit

    // XXX: should be using parameters
    public var frequency: Float { get { oscAU.frequency } set { oscAU.frequency = newValue }}

    public init() {

        let componentDescription = AudioComponentDescription(generator: "tosc")

        AUAudioUnit.registerSubclass(TestOscillatorAudioUnit.self,
                                     as: componentDescription,
                                     name: "osc AU",
                                     version: .max)
        avAudioNode = instantiate(componentDescription: componentDescription)
        oscAU = avAudioNode.auAudioUnit as! TestOscillatorAudioUnit
    }
}


/// Renders a sine wave.
class TestOscillatorAudioUnit: AUAudioUnit {

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
    
    var currentPhase: Double = 0.0
    var frequency: Float = 440.0
    var amplitude: Float = 1.0
    
    override var internalRenderBlock: AUInternalRenderBlock {
        { (actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
           timeStamp: UnsafePointer<AudioTimeStamp>,
           frameCount: AUAudioFrameCount,
           outputBusNumber: Int,
           outputBufferList: UnsafeMutablePointer<AudioBufferList>,
           renderEvents: UnsafePointer<AURenderEvent>?,
           inputBlock: AURenderPullInputBlock?) in
            
            let ablPointer = UnsafeMutableAudioBufferListPointer(outputBufferList)
            
            let twoPi = 2 * Double.pi
            let phaseIncrement = (twoPi / Double(Settings.sampleRate)) * Double(self.frequency)
            for frame in 0 ..< Int(frameCount) {
                // Get signal value for this frame at time.
                let value = sin(Float(self.currentPhase)) * self.amplitude
                
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

