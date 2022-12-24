// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AudioUnit
import AVFoundation

struct ExecInfo {
    var outputBuffer: UnsafeMutablePointer<AudioBufferList>
    var outputPCMBuffer: AVAudioPCMBuffer
    var renderBlock: AURenderBlock
    var inputBlock: AURenderPullInputBlock
    var avAudioEngine: AVAudioEngine?
}

struct ExecSchedule {
    var infos: [ExecInfo] = []

    /// Are we done using this schedule?
    var done: Bool = false
}

/// Our single audio unit which will evaluate all audio units.
class EngineAudioUnit: AUAudioUnit {

    /// Audio thread ONLY. Reference to currently executing schedule.
    var dspList: UnsafeMutablePointer<ExecSchedule>?
    
    private var inputBusArray: AUAudioUnitBusArray!
    private var outputBusArray: AUAudioUnitBusArray!

    let inputChannelCount: NSNumber = 2
    let outputChannelCount: NSNumber = 2

    var cachedMIDIBlock: AUScheduleMIDIEventBlock?

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

    deinit {
        print("deleting \(previousSchedules.count) schedules")
        for ptr in previousSchedules {
            ptr.deinitialize(count: 1)
            ptr.deallocate()
        }
    }
    
    override var inputBusses: AUAudioUnitBusArray {
        inputBusArray
    }
    
    override var outputBusses: AUAudioUnitBusArray {
        outputBusArray
    }

    /// Returns a function that mixes together the contents of buffers.
    static func mixerRenderBlock(inputBufferLists: [UnsafeMutablePointer<AudioBufferList>]) -> AURenderBlock {
        {
            (actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
               timeStamp: UnsafePointer<AudioTimeStamp>,
               frameCount: AUAudioFrameCount,
               outputBusNumber: Int,
               outputBufferList: UnsafeMutablePointer<AudioBufferList>,
               inputBlock: AURenderPullInputBlock?) in

            let ablPointer = UnsafeMutableAudioBufferListPointer(outputBufferList)

            for channel in 0..<ablPointer.count {

                let outBuf = UnsafeMutableBufferPointer<Float>(ablPointer[channel])
                for frame in 0..<Int(frameCount) {
                    outBuf[frame] = 0.0
                }

                for inputBufferList in inputBufferLists {
                    let inputPointer = UnsafeMutableAudioBufferListPointer(inputBufferList)
                    let inBuf = UnsafeMutableBufferPointer<Float>(inputPointer[channel])

                    for frame in 0..<Int(frameCount) {
                        outBuf[frame] += inBuf[frame]
                    }
                }
            }

            return noErr
        }
    }

    static func avRenderBlock(block: @escaping AVAudioEngineManualRenderingBlock) -> AURenderBlock {
        {
            (actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
             timeStamp: UnsafePointer<AudioTimeStamp>,
             frameCount: AUAudioFrameCount,
             outputBusNumber: Int,
             outputBufferList: UnsafeMutablePointer<AudioBufferList>,
             inputBlock: AURenderPullInputBlock?) in

            var status = noErr
            _ = block(frameCount, outputBufferList, &status)

            return status
        }
    }

    /// Returns a function which provides input from a buffer list.
    ///
    /// Typically, AUs are evaluated recursively. This is less than ideal for various reasons:
    /// - Harder to parallelize.
    /// - Stack trackes are too deep.
    /// - Profiler results are hard to read.
    ///
    /// So instead we use a dummy input block that just copies over an ABL.
    static func basicInputBlock(inputBufferLists: [UnsafeMutablePointer<AudioBufferList>]) -> AURenderPullInputBlock {
        {
            (flags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
             timestamp: UnsafePointer<AudioTimeStamp>,
             frames: AUAudioFrameCount,
             bus: Int,
             outputBuffer: UnsafeMutablePointer<AudioBufferList>) in

            // We'd like to avoid actually copying samples, so just copy the ABL.
            let buffer = inputBufferLists[bus]

            assert(buffer.pointee.mNumberBuffers == outputBuffer.pointee.mNumberBuffers)
            let ablSize = MemoryLayout<AudioBufferList>.size + Int(buffer.pointee.mNumberBuffers) * MemoryLayout<AudioBuffer>.size
            memcpy(outputBuffer, buffer, ablSize)

            return noErr
        }
    }

    var schedule = ExecSchedule()

    var previousSchedules: [UnsafeMutablePointer<ExecSchedule>] = []

    let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!

    public var output: Node? {
        didSet {
            // We will call compile from allocateRenderResources.
            if renderResourcesAllocated {
                compile()
            }
        }
    }

    /// Allocates an output buffer for reach node.
    func makeBuffers(nodes: [Node]) -> [ObjectIdentifier: AVAudioPCMBuffer] {

        var buffers: [ObjectIdentifier: AVAudioPCMBuffer] = [:]

        for node in nodes {
            let length = maximumFramesToRender
            let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: length)!
            buf.frameLength = length
            buffers[ObjectIdentifier(node)] = buf
        }

        return buffers
    }

    /// Recompiles our DAG of nodes into a list of render functions to be called on the audio thread.
    func compile() {
        // Traverse the node graph to schedule
        // audio units.

        if cachedMIDIBlock == nil {
            cachedMIDIBlock = scheduleMIDIEventBlock
        }

        if let output = output {

            // Generate a new schedule of AUs.
            var scheduled = Set<ObjectIdentifier>()
            var list: [Node] = []

            schedule(node: output, scheduled: &scheduled, list: &list)

            // Generate output buffers for each AU.
            let buffers = makeBuffers(nodes: list)

            // Pass the schedule to the engineAU
            var execList: [ExecInfo] = []

            for node in list {

                // Activate input busses.
                for busIndex in 0..<node.au.inputBusses.count {
                    let bus = node.au.inputBusses[busIndex]
                    try! bus.setFormat(format)
                    bus.isEnabled = true
                }

                if !node.au.renderResourcesAllocated {
                    try! node.au.allocateRenderResources()
                }

                let nodeBuffer = buffers[ObjectIdentifier(node)]!
                assert(nodeBuffer.frameCapacity == maximumFramesToRender)

                let inputBuffers = node.connections.map { buffers[ObjectIdentifier($0)]! }
                let inputBufferLists = inputBuffers.map { $0.mutableAudioBufferList }

                var inputBlock: AURenderPullInputBlock = { (_, _, _, _, _) in return noErr }

                if let mixer = node as? Mixer {

                    // Set the engine on the mixer so adding or removing mixer inputs
                    // can trigger a recompile.
                    mixer.engineAU = self

                    let renderBlock = EngineAudioUnit.mixerRenderBlock(inputBufferLists: inputBufferLists)

                    let info = ExecInfo(outputBuffer: nodeBuffer.mutableAudioBufferList,
                                        outputPCMBuffer: nodeBuffer,
                                        renderBlock: renderBlock,
                                        inputBlock: inputBlock)

                    execList.append(info)

                } else if node.avAudioNode as? AVAudioUnit != nil {

                    // We've just got a wrapped AU, so we can grab the render
                    // block.

                    if !inputBufferLists.isEmpty {
                        inputBlock = EngineAudioUnit.basicInputBlock(inputBufferLists: inputBufferLists)
                    }

                    let info = ExecInfo(outputBuffer: nodeBuffer.mutableAudioBufferList,
                                        outputPCMBuffer: nodeBuffer,
                                        renderBlock: node.au.renderBlock,
                                        inputBlock: inputBlock)

                    execList.append(info)

                } else {

                    // Other AVAudioNodes seem to need an AVAudioEngine, so make one!
                    let avEngine = AVAudioEngine()
                    try! avEngine.enableManualRenderingMode(.realtime, format: format, maximumFrameCount: maximumFramesToRender)
                    avEngine.attach(node.avAudioNode)

                    assert(node.connections.count <= 1)

                    if node.connections.count > 0 {
                        avEngine.connect(avEngine.inputNode, to: node.avAudioNode, format: nil)

                        let bufferList = inputBufferLists.first!
                        avEngine.inputNode.setManualRenderingInputPCMFormat(format) { frames in
                            UnsafePointer(bufferList)
                        }
                    }

                    avEngine.connect(node.avAudioNode, to: avEngine.outputNode, format: nil)

                    let renderBlock = Self.avRenderBlock(block: avEngine.manualRenderingBlock)

                    try! avEngine.start()

                    let info = ExecInfo(outputBuffer: nodeBuffer.mutableAudioBufferList,
                                        outputPCMBuffer: nodeBuffer,
                                        renderBlock: renderBlock,
                                        inputBlock: inputBlock,
                                        avAudioEngine: avEngine)

                    execList.append(info)

                }
            }

            // Save schedule.
            schedule = ExecSchedule(infos: execList)

            // Update engine exec list.
            let ptr = UnsafeMutablePointer<ExecSchedule>.allocate(capacity: 1)
            ptr.initialize(to: schedule)
            previousSchedules.append(ptr)

            let array = encodeSysex(ptr)

            if let block = cachedMIDIBlock {
                block(.zero, 0, array.count, array)
            }

            // Cleanup old schedules.
            // Start from the end. Once we find a finished
            // data, delete all data before and including.
            var i = previousSchedules.count-1
            while i > 0 {
                if previousSchedules[i].pointee.done {

                    print("removing \(i) old schedules")

                    for j in 0...i {
                        let ptr = previousSchedules[j]
                        ptr.deinitialize(count: 1)
                        ptr.deallocate()
                    }

                    previousSchedules.removeFirst(i+1)

                    break
                }
                i -= 1
            }

        }
    }

    /// Recursively build a schedule of audio units to run.
    func schedule(node: Node,
                  scheduled: inout Set<ObjectIdentifier>,
                  list: inout [Node]) {

        let id = ObjectIdentifier(node)
        if scheduled.contains(id) { return }

        scheduled.insert(id)

        for input in node.connections {
            schedule(node: input, scheduled: &scheduled, list: &list)
        }

        list.append(node)
    }
    
    override func allocateRenderResources() throws {
        try super.allocateRenderResources()
        compile()
    }
    
    override func deallocateRenderResources() {
        super.deallocateRenderResources()
    }

    /// Decode a MIDI sysex message containing a pointer to a new ExecSchedule.
    func updateDSPList(events: UnsafePointer<AURenderEvent>?) {
        var events = events
        while let event = events {

            if event.pointee.head.eventType == .midiSysEx {

                // Maybe a little sketchy to init this to 0, but didn't
                // see something better.
                var ptr = UnsafeMutablePointer<ExecSchedule>.init(bitPattern: 0)
                decodeSysex(event, &ptr)

                if let oldList = self.dspList {
                    oldList.pointee.done = true
                }

                self.dspList = ptr
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

            self.updateDSPList(events: renderEvents)

            if let dspList = self.dspList {
                var i = 0
                for exec in dspList.pointee.infos {

                    // Use the outputBufferList for the last AU in the schedule.
                    let out = i == dspList.pointee.infos.count-1 ? outputBufferList : exec.outputBuffer

                    // Do the actual DSP.
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
                        case AVAudioEngineManualRenderingError.notRunning.rawValue:
                            print("got AVAudioEngineManualRenderingErrorNotRunning")
                        default:
                            print("unknown rendering error \(status)")
                        }
                        return status
                    }

                    i += 1
                }
            } else {

                // If we start processing before setting an output node,
                // we won't have a execution schedule, so just clear the
                // output.
                let outputBufferListPointer = UnsafeMutableAudioBufferListPointer(outputBufferList)

                // Clear output.
                for channel in 0 ..< outputBufferListPointer.count {
                    outputBufferListPointer[channel].clear()
                }
            }
            
            return noErr
        }
    }
    
}
