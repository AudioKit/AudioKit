// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Atomics
import AudioToolbox
import AudioUnit
import AVFoundation
import Foundation

public typealias AKAURenderContextObserver = (UnsafePointer<WorkGroup>?) -> Void

/// Our single audio unit which will evaluate all audio units.
public class EngineAudioUnit: AUAudioUnit {
    private var inputBusArray: AUAudioUnitBusArray!
    private var outputBusArray: AUAudioUnitBusArray!

    let inputChannelCount: NSNumber = 2
    let outputChannelCount: NSNumber = 2

    var cachedMIDIBlock: AUScheduleMIDIEventBlock?

    public static let instanceCount = ManagedAtomic(0)

    override public var channelCapabilities: [NSNumber]? {
        return [inputChannelCount, outputChannelCount]
    }

    /// Initialize with component description and options
    /// - Parameters:
    ///   - componentDescription: Audio Component Description
    ///   - options: Audio Component Instantiation Options
    /// - Throws: error
    override public init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws
    {
        try super.init(componentDescription: componentDescription, options: options)

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
        inputBusArray = AUAudioUnitBusArray(audioUnit: self,
                                            busType: .input,
                                            busses: [try AUAudioUnitBus(format: format)])
        outputBusArray = AUAudioUnitBusArray(audioUnit: self,
                                             busType: .output,
                                             busses: [try AUAudioUnitBus(format: format)])

        parameterTree = AUParameterTree.createTree(withChildren: [])

        let oldSelector = Selector(("renderContextObserver"))

        guard let method = class_getInstanceMethod(EngineAudioUnit.self, #selector(EngineAudioUnit.akRenderContextObserver)) else {
            fatalError()
        }

        let newType = method_getTypeEncoding(method)!

        let imp = method_getImplementation(method)

        class_replaceMethod(EngineAudioUnit.self, oldSelector, imp, newType)

        Self.instanceCount.wrappingIncrement(ordering: .relaxed)
    }

    deinit {
        Self.instanceCount.wrappingDecrement(ordering: .relaxed)
    }

    @objc public dynamic func akRenderContextObserver() -> AKAURenderContextObserver {
        print("setting up render context observer")
        return { [pool] workgroupPtr in
            print("actually in render context observer")

            if let workgroupPtr = workgroupPtr {
                print("joining workgroup")
                pool.join(workgroup: workgroupPtr.pointee)
            } else {
                print("leaving workgroup")
                pool.join(workgroup: nil)
            }
        }
    }

    override public var inputBusses: AUAudioUnitBusArray {
        inputBusArray
    }

    override public var outputBusses: AUAudioUnitBusArray {
        outputBusArray
    }

    /// Returns a function which provides input from a buffer list.
    ///
    /// Typically, AUs are evaluated recursively. This is less than ideal for various reasons:
    /// - Harder to parallelize.
    /// - Stack trackes are too deep.
    /// - Profiler results are hard to read.
    ///
    /// So instead we use a dummy input block that just copies over an ABL.
    static func basicInputBlock(inputBufferLists: [SynchronizedAudioBufferList]) -> AURenderPullInputBlock {
        {
            (_: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
             _: UnsafePointer<AudioTimeStamp>,
             _: AUAudioFrameCount,
             bus: Int,
             outputBuffer: UnsafeMutablePointer<AudioBufferList>) in

            // We'd like to avoid actually copying samples, so just copy the ABL.
            let inputBuffer: SynchronizedAudioBufferList = inputBufferLists[bus]

            inputBuffer.beginReading()

            assert(inputBuffer.abl.pointee.mNumberBuffers == outputBuffer.pointee.mNumberBuffers)

            // Note that we already have one buffer in the AudioBufferList type, hence the -1
            let bufferCount: Int = Int(inputBuffer.abl.pointee.mNumberBuffers)
            let ablSize = MemoryLayout<AudioBufferList>.size + (bufferCount - 1) * MemoryLayout<AudioBuffer>.size
            memcpy(outputBuffer, inputBuffer.abl, ablSize)

            return noErr
        }
    }

    /// Returns an input block which mixes buffer lists.
    static func mixerInputBlock(inputBufferLists: [SynchronizedAudioBufferList]) -> AURenderPullInputBlock {
        {
            (_: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
             _: UnsafePointer<AudioTimeStamp>,
             frameCount: AUAudioFrameCount,
             _: Int,
             outputBuffer: UnsafeMutablePointer<AudioBufferList>) in

            let ablPointer = UnsafeMutableAudioBufferListPointer(outputBuffer)

            for channel in 0 ..< ablPointer.count {
                let outBuf = UnsafeMutableBufferPointer<Float>(ablPointer[channel])
                for frame in 0 ..< Int(frameCount) {
                    outBuf[frame] = 0.0
                }

                for inputBufferList in inputBufferLists {
                    inputBufferList.beginReading()
                    let inputPointer = UnsafeMutableAudioBufferListPointer(inputBufferList.abl)
                    let inBuf = UnsafeMutableBufferPointer<Float>(inputPointer[channel])

                    for frame in 0 ..< Int(frameCount) {
                        outBuf[frame] += inBuf[frame]
                    }
                }
            }

            return noErr
        }
    }

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
    func makeBuffers(nodes: [Node]) -> [ObjectIdentifier: SynchronizedAudioBufferList] {
        var buffers: [ObjectIdentifier: SynchronizedAudioBufferList] = [:]

        for node in nodes {
            let length = maximumFramesToRender
            let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: length)!
            buf.frameLength = length
            buffers[ObjectIdentifier(node)] = SynchronizedAudioBufferList(buf)
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

            output.dfs(seen: &scheduled, list: &list)

            // Generate output buffers for each AU.
            let buffers = makeBuffers(nodes: list)

            // Pass the schedule to the engineAU
            var jobs: [RenderJob] = []
            var nodeJobs: [ObjectIdentifier: Int] = [:]

            for node in list {

                NodeEnginesManager.shared.set(engine: self, for: node)

                // Activate input busses.
                for busIndex in 0 ..< node.au.inputBusses.count {
                    let bus = node.au.inputBusses[busIndex]
                    try! bus.setFormat(format)
                    bus.isEnabled = true
                }

                if !node.au.renderResourcesAllocated {
                    try! node.au.allocateRenderResources()
                }

                let nodeBuffer = buffers[ObjectIdentifier(node)]!

                let inputBuffers = node.connections.map { buffers[ObjectIdentifier($0)]! }

                var inputBlock: AURenderPullInputBlock = { _, _, _, _, _ in noErr }

                let nodeJobIndex = jobs.count
                nodeJobs[ObjectIdentifier(node)] = nodeJobIndex

                if let mixer = node as? Mixer {

                    inputBlock = EngineAudioUnit.mixerInputBlock(inputBufferLists: inputBuffers)

                    let volumeAU = mixer.volumeAU

                    if !volumeAU.renderResourcesAllocated {
                        try! volumeAU.allocateRenderResources()
                    }

                    let job = RenderJob(outputBuffer: nodeBuffer,
                                        renderBlock: volumeAU.renderBlock,
                                        inputBlock: inputBlock,
                                        inputIndices: node.connections.map { nodeJobs[ObjectIdentifier($0)]! })

                    jobs.append(job)

                } else {
                    // We've just got a wrapped AU, so we can grab the render block.

                    if !inputBuffers.isEmpty {
                        inputBlock = EngineAudioUnit.basicInputBlock(inputBufferLists: inputBuffers)
                    }

                    let job = RenderJob(outputBuffer: nodeBuffer,
                                        renderBlock: node.au.renderBlock,
                                        inputBlock: inputBlock,
                                        inputIndices: node.connections.map { nodeJobs[ObjectIdentifier($0)]! })

                    jobs.append(job)
                }

                // Add render jobs for taps.
                for tap in Tap.getTapsFor(node: node) {

                    // We don't actually care about this output buffer. Perhaps
                    // there's a better way to express this?
                    let length = maximumFramesToRender
                    let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: length)!
                    buf.frameLength = length

                    let job = RenderJob(outputBuffer: .init(buf),
                                        renderBlock: tap.tapAU.renderBlock,
                                        inputBlock: EngineAudioUnit.basicInputBlock(inputBufferLists: [nodeBuffer]),
                                        inputIndices: [nodeJobIndex])

                    jobs.append(job)
                }
            }

            // Generate output indices
            for (index, job) in jobs.enumerated() {
                for inputIndex in job.inputIndices {
                    jobs[inputIndex].outputIndices.append(index)
                }
            }

            program.store(AudioProgram(jobs: jobs,
                                       generatorIndices: generatorIndices(nodes: list)),
                          ordering: .relaxed)
        }
    }

    var program = ManagedAtomic<AudioProgram>(AudioProgram(jobs: [], generatorIndices: []))

    /// Get just the signal generating nodes.
    func generatorIndices(nodes: [Node]) -> [Int] {
        nodes.enumerated().compactMap { index, node in
            node.connections.isEmpty ? index : nil
        }
    }

    override public func allocateRenderResources() throws {
        try super.allocateRenderResources()

        compile()
    }

    override public func deallocateRenderResources() {
        super.deallocateRenderResources()
    }

    // Worker threads.
    let pool = ThreadPool()

    override public var internalRenderBlock: AUInternalRenderBlock {
        return { [pool, program] (actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                         timeStamp: UnsafePointer<AudioTimeStamp>,
                         frameCount: AUAudioFrameCount,
                         _: Int,
                         outputBufferList: UnsafeMutablePointer<AudioBufferList>,
                         _: UnsafePointer<AURenderEvent>?,
                         _: AURenderPullInputBlock?) in

                let dspList = program.load(ordering: .relaxed)

//            process(events: renderEvents, sysex: { pointer in
//                var program: Unmanaged<AudioProgram>?
//                decodeSysex(pointer, &program)
//                dspList = program?.takeRetainedValue()
//            })

                // Clear output.
                let outputBufferListPointer = UnsafeMutableAudioBufferListPointer(outputBufferList)
                for channel in 0 ..< outputBufferListPointer.count {
                    outputBufferListPointer[channel].clear()
                }

                // Distribute the starting indices among workers.
                for (index, generatorIndex) in dspList.generatorIndices.enumerated() {
                    // If we have a very very large number of jobs (1024 * number of threads),
                    // then this could fail.
                    if !pool.workers[index % pool.workers.count].add(job: generatorIndex) {
                        return kAudioUnitErr_InvalidParameter
                    }
                }

                // Reset counters.
                dspList.reset()

                // Setup worker threads.
                for worker in pool.workers {
                    worker.program = dspList
                    worker.actionFlags = actionFlags
                    worker.timeStamp = timeStamp
                    worker.frameCount = frameCount
                    worker.outputBufferList = outputBufferList
                }

                // Wake workers.
                pool.start()

//            dspList.run(actionFlags: actionFlags,
//                        timeStamp: timeStamp,
//                        frameCount: frameCount,
//                        outputBufferList: outputBufferList,
//                        runQueue: runQueue,
//                        finishedInputs: finishedInputs)

                // Wait for workers to finish.
                pool.wait()

                return noErr
        }
    }
}
