// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AudioUnit
import AVFoundation

/// Our single audio unit which will evaluate all audio units.
class EngineAudioUnit: AUAudioUnit {
    
    struct AUExecInfo {
        var outputBuffer: UnsafeMutablePointer<AudioBufferList>
        var outputPCMBuffer: AVAudioPCMBuffer
        var renderBlock: AURenderBlock
        var inputBlock: AURenderPullInputBlock
    }
    
    // The list of things to execute.
    // XXX: ultimately we'll need to update this using a lock-free queue.
    var execList: [AUExecInfo] = []
    
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
        inputBusArray = AUAudioUnitBusArray(audioUnit: self, busType: .input, busses: [try AUAudioUnitBus(format: format)])
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
    
    override var renderBlock: AURenderBlock {
        { (actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
           timeStamp: UnsafePointer<AudioTimeStamp>,
           frameCount: AUAudioFrameCount,
           outputBusNumber: Int,
           outputBufferList: UnsafeMutablePointer<AudioBufferList>,
           inputBlock: AURenderPullInputBlock?) in
            
            var i = 0
            for exec in self.execList {
                
                let out = i == self.execList.count-1 ? outputBufferList : exec.outputBuffer
                let status = exec.renderBlock(actionFlags,
                                              timeStamp,
                                              frameCount,
                                              0,
                                              out,
                                              exec.inputBlock)
                
                // Propagate errors.
                if status != noErr {
                    switch status {
                    case kAudioUnitErr_NoConnection:
                        print("got kAudioUnitErr_NoConnection")
                    case kAudioUnitErr_TooManyFramesToProcess:
                        print("got kAudioUnitErr_TooManyFramesToProcess")
                    default:
                        print("rendering error \(status)")
                    }
                    return status
                }
                
                i += 1
            }
            
            return noErr
        }
    }
    
}
