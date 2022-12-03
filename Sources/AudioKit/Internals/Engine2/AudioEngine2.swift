// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AudioEngine2 {
    
    /// Internal AVAudioEngine
    public let avEngine = AVAudioEngine()
    
    public var output: Node? {
        didSet {
            compile()
        }
    }
    
    var engineAU: EngineAudioUnit
    var avAudioUnit: AVAudioUnit

    // maximum number of frames the engine will be asked to render in any single render call
    let maximumFrameCount: AVAudioFrameCount = 1024
    
    public init() {
        
        let componentDescription = AudioComponentDescription(effect: "akau")
        
        AUAudioUnit.registerSubclass(EngineAudioUnit.self,
                                     as: componentDescription,
                                     name: "engine AU",
                                     version: .max)
        
        avAudioUnit = instantiate(componentDescription: componentDescription)
        engineAU = avAudioUnit.auAudioUnit as! EngineAudioUnit
        
        avEngine.attach(avAudioUnit)
        avEngine.connect(avEngine.inputNode, to: avAudioUnit, format: nil)
        avEngine.connect(avAudioUnit, to: avEngine.mainMixerNode, format: nil)
    }

    deinit {
        print("deleting \(previousSchedules.count) schedules")
        for ptr in previousSchedules {
            ptr.deinitialize(count: 1)
            ptr.deallocate()
        }
    }
    
    /// Start the engine
    public func start() throws {
        try avEngine.start()
    }
    
    /// Stop the engine
    public func stop() {
        avEngine.stop()
    }

    /// Pause the engine
    public func pause() {
        avEngine.pause()
    }
    
    var activeNodes = Set<ObjectIdentifier>()
    
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

    var schedule = ExecSchedule()

    var previousSchedules: [UnsafeMutablePointer<ExecSchedule>] = []
    
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
                // What should the frame capacity be?
                let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 1024)!
                buf.frameLength = 512
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
                assert(nodeBuffer.frameCapacity == 1024)
                
                let inputBuffers = node.connections.map { buffers[ObjectIdentifier($0)]! }
                let inputBufferLists = inputBuffers.map { $0.mutableAudioBufferList }
                
                var inputBlock: AURenderPullInputBlock = { (_, _, _, _, _) in return noErr }
                
                if let mixer = node as? Mixer {
                    
                    // Set the engine on the mixer so adding or removing mixer inputs
                    // can trigger a recompile.
                    mixer.engine2 = self
                    
                    let renderBlock = AudioEngine2.mixerRenderBlock(inputBufferLists: inputBufferLists)
                    
                    let info = ExecInfo(outputBuffer: nodeBuffer.mutableAudioBufferList,
                                        outputPCMBuffer: nodeBuffer,
                                        renderBlock: renderBlock,
                                        inputBlock: inputBlock)
                    
                    execList.append(info)
                    
                } else {
                    
                    if !inputBufferLists.isEmpty {
                        inputBlock = AudioEngine2.basicInputBlock(inputBufferLists: inputBufferLists)
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
            engineAU.execList.store(ptr, ordering: .relaxed)

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

    /// Start testing for a specified total duration
    /// - Parameter duration: Total duration of the entire test
    /// - Returns: A buffer which you can append to
    public func startTest(totalDuration duration: Double) -> AVAudioPCMBuffer {
        let samples = Int(duration * Settings.sampleRate)

        do {
            avEngine.reset()
            try avEngine.enableManualRenderingMode(.offline,
                                                   format: Settings.audioFormat,
                                                   maximumFrameCount: maximumFrameCount)
            try start()
        } catch let err {
            Log("🛑 Start Test Error: \(err)")
        }

        return AVAudioPCMBuffer(
            pcmFormat: avEngine.manualRenderingFormat,
            frameCapacity: AVAudioFrameCount(samples)
        )!
    }

    /// Render audio for a specific duration
    /// - Parameter duration: Length of time to render for
    /// - Returns: Buffer of rendered audio
    public func render(duration: Double) -> AVAudioPCMBuffer {
        let sampleCount = Int(duration * Settings.sampleRate)
        let startSampleCount = Int(avEngine.manualRenderingSampleTime)

        let buffer = AVAudioPCMBuffer(
            pcmFormat: avEngine.manualRenderingFormat,
            frameCapacity: AVAudioFrameCount(sampleCount)
        )!

        let tempBuffer = AVAudioPCMBuffer(
            pcmFormat: avEngine.manualRenderingFormat,
            frameCapacity: AVAudioFrameCount(maximumFrameCount)
        )!

        do {
            while avEngine.manualRenderingSampleTime < sampleCount + startSampleCount {
                let currentSampleCount = Int(avEngine.manualRenderingSampleTime)
                let framesToRender = min(UInt32(sampleCount + startSampleCount - currentSampleCount), maximumFrameCount)
                try avEngine.renderOffline(AVAudioFrameCount(framesToRender), to: tempBuffer)
                buffer.append(tempBuffer)
            }
        } catch let err {
            Log("🛑 Could not render offline \(err)")
        }
        return buffer
    }

}
