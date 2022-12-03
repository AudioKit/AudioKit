// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AudioUnit
import AVFoundation
import Atomics

struct ExecInfo {
    var outputBuffer: UnsafeMutablePointer<AudioBufferList>
    var outputPCMBuffer: AVAudioPCMBuffer
    var renderBlock: AURenderBlock
    var inputBlock: AURenderPullInputBlock
}

struct ExecSchedule {
    var infos: [ExecInfo] = []

    /// Are we done using this schedule?
    var done: Bool = false
}

/// Our single audio unit which will evaluate all audio units.
class EngineAudioUnit: AUAudioUnit {
    
    // The list of things to execute.
    var execList = ManagedAtomic<UnsafeMutablePointer<ExecSchedule>>(UnsafeMutablePointer<ExecSchedule>.allocate(capacity: 1))

    var dspList: UnsafeMutablePointer<ExecSchedule>?
    
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

    var activeNodes = Set<ObjectIdentifier>()

    var schedule = ExecSchedule()

    var previousSchedules: [UnsafeMutablePointer<ExecSchedule>] = []

    public var output: Node? {
        didSet {
            // We will call compile from allocateRenderResources.
            if renderResourcesAllocated {
                compile()
            }
        }
    }

    func compile() {
        // Traverse the node graph to schedule
        // audio units.

        if let output = output {

            // Generate a new schedule of AUs.
            var scheduled = Set<ObjectIdentifier>()
            var list: [Node] = []

            schedule(node: output, scheduled: &scheduled, list: &list)

            // Generate output buffers for each AU.
            let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
            var buffers: [ObjectIdentifier: AVAudioPCMBuffer] = [:]

            for node in list {
                let length = maximumFramesToRender
                let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: length)!
                buf.frameLength = length
                buffers[ObjectIdentifier(node)] = buf
            }

            // Pass the schedule to the engineAU
            var execList: [ExecInfo] = []

            for node in list {

                // Activate input buses.
                for busIndex in 0..<node.au.inputBusses.count {
                    let bus = node.au.inputBusses[busIndex]
                    try! bus.setFormat(format)
                    bus.isEnabled = true
                }

                if !activeNodes.contains(ObjectIdentifier(node)) {
                    try! node.au.allocateRenderResources()
                    activeNodes.insert(ObjectIdentifier(node))
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

                } else {

                    if !inputBufferLists.isEmpty {
                        inputBlock = EngineAudioUnit.basicInputBlock(inputBufferLists: inputBufferLists)
                    }

                    let info = ExecInfo(outputBuffer: nodeBuffer.mutableAudioBufferList,
                                        outputPCMBuffer: nodeBuffer,
                                        renderBlock: node.au.renderBlock,
                                        inputBlock: inputBlock)

                    execList.append(info)

                }
            }

            // Save schedule.
            schedule = ExecSchedule(infos: execList)

            // Update engine exec list.
            let ptr = UnsafeMutablePointer<ExecSchedule>.allocate(capacity: 1)
            ptr.initialize(to: schedule)
            previousSchedules.append(ptr)
            self.execList.store(ptr, ordering: .relaxed)

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
    
    override var renderBlock: AURenderBlock {
        { (actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
           timeStamp: UnsafePointer<AudioTimeStamp>,
           frameCount: AUAudioFrameCount,
           outputBusNumber: Int,
           outputBufferList: UnsafeMutablePointer<AudioBufferList>,
           inputBlock: AURenderPullInputBlock?) in

            let nextList = self.execList.load(ordering: .relaxed)

            if nextList != self.dspList {
                self.dspList?.pointee.done = true
                self.dspList = nextList
            }

            if let dspList = self.dspList {
                var i = 0
                for exec in dspList.pointee.infos {

                    let out = i == dspList.pointee.infos.count-1 ? outputBufferList : exec.outputBuffer
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
            }
            
            return noErr
        }
    }
    
}
