// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Node in an audio graph.
public protocol Node: AnyObject {

    /// Nodes providing audio input to this node.
    var connections: [Node] { get }

    /// Internal AVAudioEngine node.
    var avAudioNode: AVAudioNode { get }

    /// Override point for any connections internal to the node.
    func makeInternalConnections()
}

extension Node {

    /// Reset the internal state of the unit
    /// Fixes issues such as https://github.com/AudioKit/AudioKit/issues/2046
    public func reset() {
        if let avAudioUnit = avAudioNode as? AVAudioUnit {
            AudioUnitReset(avAudioUnit.audioUnit, kAudioUnitScope_Global, 0)
        }
    }

    func detach() {
        if let engine = avAudioNode.engine {
            engine.detach(avAudioNode)
        }
        for connection in connections {
            connection.detach()
        }
    }

    func disconnectAV() {
        if let engine = avAudioNode.engine {
            engine.disconnectNodeInput(avAudioNode)
            for (_, connection) in connections.enumerated() {
                connection.disconnectAV()
            }
        }
    }

    /// Work-around for an AVAudioEngine bug.
    func initLastRenderTime() {
        // We don't have a valid lastRenderTime until we query it.
        _ = avAudioNode.lastRenderTime

        for connection in connections {
            connection.initLastRenderTime()
        }
    }

    /// Scan for all parameters and associate with the node.
    func associateParams(with node: AVAudioNode) {
        let mirror = Mirror(reflecting: self)

        for child in mirror.children {
            if let param = child.value as? ParameterBase {
                param.projectedValue.associate(with: node)
            }
        }
    }

    func makeAVConnections() {
        makeInternalConnections()
        // Are we attached?
        if let engine = avAudioNode.engine {
            for (bus, connection) in connections.enumerated() {
                if let sourceEngine = connection.avAudioNode.engine {
                    if sourceEngine != avAudioNode.engine {
                        Log("🛑 Error: Attempt to connect nodes from different engines.")
                        return
                    }
                }

                engine.attach(connection.avAudioNode)

                // Mixers will decide which input bus to use.
                if let mixer = avAudioNode as? AVAudioMixerNode {
                    mixer.connectMixer(input: connection.avAudioNode)
                } else {
                    avAudioNode.connect(input: connection.avAudioNode, bus: bus)
                }

                connection.makeAVConnections()
            }
        }
    }

    #if !os(tvOS)
    /// Schedule an event with an offset
    ///
    /// - Parameters:
    ///   - event: MIDI Event to schedule
    ///   - offset: Time in samples
    ///
    public func scheduleMIDIEvent(event: MIDIEvent, offset: UInt64) {
        if let midiBlock = avAudioNode.auAudioUnit.scheduleMIDIEventBlock {
            event.data.withUnsafeBufferPointer { ptr in
                guard let ptr = ptr.baseAddress else { return }
                midiBlock(AUEventSampleTimeImmediate + AUEventSampleTime(offset), 0, event.data.count, ptr)
            }
        }
    }
    #endif

    var bypassed: Bool {
        get { avAudioNode.auAudioUnit.shouldBypassEffect }
        set { avAudioNode.auAudioUnit.shouldBypassEffect = newValue }
    }

    public func start() { bypassed = false }
    public func stop() { bypassed = true }
    public func play() { bypassed = false }
    public func bypass() { bypassed = true }

    func instantiateAudioUnit(componentDescription: AudioComponentDescription) -> AVAudioUnit {

        let semaphore = DispatchSemaphore(value: 0)
        var result: AVAudioUnit!

        AUAudioUnit.registerSubclass(AudioUnitBase.self,
                                     as: componentDescription,
                                     name: "Local \(Self.self)",
                                     version: .max)
        AVAudioUnit.instantiate(with: componentDescription) { avAudioUnit, _ in
            guard let au = avAudioUnit else {
                fatalError("Unable to instantiate AVAudioUnit")
            }
            guard let myAU = au.auAudioUnit as? AudioUnitBase else {
                fatalError("AudioUnit not of expected type")
            }

            result = au

            // If there are no parameters created, search for @Parameter
            if myAU.parameterTree!.children.isEmpty {
                let mirror = Mirror(reflecting: self)
                var params: [AUParameter] = []

                for child in mirror.children {
                    if let param = child.value as? ParameterBase {
                        let def = param.projectedValue.def
                        let auParam = AUParameter(identifier: def.identifier,
                                                name: def.name,
                                                address: def.address,
                                                min: def.range.lowerBound,
                                                max: def.range.upperBound,
                                                unit: def.unit,
                                                flags: def.flags)
                        params.append(auParam)
                        param.projectedValue.associate(with: au, parameter: auParam)
                    }
                }

                myAU.parameterTree = AUParameterTree.createTree(withChildren: params)
            }

            semaphore.signal()
        }

        _ = semaphore.wait(wallTimeout: .distantFuture)

        return result
    }

}

/// Convenience for AudioKit nodes.
open class NodeBase: Node {
    /// Nodes providing input to this node.
    public var connections: [Node] { [] }

    /// The internal AVAudioEngine AVAudioNode
    open var avAudioNode: AVAudioNode

    /// Initialize the node from an AVAudioNode
    /// - Parameter avAudioNode: AVAudioNode to initialize with
    public init(avAudioNode: AVAudioNode) {
        self.avAudioNode = avAudioNode
    }

    public func makeInternalConnections() { }
}
