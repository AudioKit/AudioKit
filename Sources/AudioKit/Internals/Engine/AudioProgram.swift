// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AudioUnit
import AVFoundation
import AudioToolbox

public struct ExecInfo {
    var outputBuffer: UnsafeMutablePointer<AudioBufferList>
    var outputPCMBuffer: AVAudioPCMBuffer
    var renderBlock: AURenderBlock
    var inputBlock: AURenderPullInputBlock
    var avAudioEngine: AVAudioEngine?
}

/// Information about what the engine needs to run on the audio thread.
public struct AudioProgram {

    /// List of information about AudioUnits we're executing.
    public var infos: [ExecInfo] = []

    /// Are we done using this schedule?
    var done: Bool = false
}
