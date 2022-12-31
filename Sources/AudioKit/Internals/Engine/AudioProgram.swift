// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AudioUnit
import AVFoundation
import AudioToolbox

public struct RenderInfo {
    var outputBuffer: UnsafeMutablePointer<AudioBufferList>
    var outputPCMBuffer: AVAudioPCMBuffer
    var renderBlock: AURenderBlock
    var inputBlock: AURenderPullInputBlock
    var avAudioEngine: AVAudioEngine?

    /// Number of inputs feeding this AU.
    var inputCount: Int

    /// Number of inputs already executed during processing.
    ///
    /// When this reaches zero we are ready to go.
    var finishedInputs: Int = 0

    /// Indices of AUs that this one feeds.
    var outputIndices: [Int]
}

/// Information about what the engine needs to run on the audio thread.
public struct AudioProgram {

    /// List of information about AudioUnits we're executing.
    public var infos: [RenderInfo] = []

    /// Queue of AUs that are ready to be executed by worker threads.
    var runQueue: AtomicList

    /// Nodes that we start processing first.
    var generatorIndices: [Int]

    /// Are we done using this schedule?
    var done: Bool = false

    init(infos: [RenderInfo], generatorIndices: [Int]) {
        self.infos = infos
        self.runQueue = AtomicList(size: infos.count)
        self.generatorIndices = generatorIndices
    }
}
