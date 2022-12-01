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
            
            for exec in self.execList {
                let status = exec.renderBlock(actionFlags,
                                              timeStamp,
                                              frameCount,
                                              0,
                                              exec.outputBuffer,
                                              exec.inputBlock)
                
                // Propagate errors.
                if status != noErr {
                    return status
                }
            }
            
            return noErr
        }
    }
    
}
