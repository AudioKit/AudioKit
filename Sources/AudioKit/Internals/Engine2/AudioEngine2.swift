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
    
    init() {
        
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
            var execList: [EngineAudioUnit.AUExecInfo] = []
            
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
                    
                    let info = EngineAudioUnit.AUExecInfo(outputBuffer: nodeBuffer.mutableAudioBufferList,
                                                          outputPCMBuffer: nodeBuffer,
                                                          renderBlock: renderBlock,
                                                          inputBlock: inputBlock)
                    
                    execList.append(info)
                    
                } else {
                    
                    if !inputBufferLists.isEmpty {
                        inputBlock = AudioEngine2.basicInputBlock(inputBufferLists: inputBufferLists)
                    }
                    
                    let info = EngineAudioUnit.AUExecInfo(outputBuffer: nodeBuffer.mutableAudioBufferList,
                                                          outputPCMBuffer: nodeBuffer,
                                                          renderBlock: node.au.renderBlock,
                                                          inputBlock: inputBlock)
                    
                    execList.append(info)
                    
                }
            }
            
            // Update engine exec list.
            engineAU.execList = execList
            
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
}
