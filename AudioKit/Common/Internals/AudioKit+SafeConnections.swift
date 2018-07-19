//
//  AudioKit+SafeConnections.swift
//  AudioKit
//
//  Created by Jeff Cooper on 4/20/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

/// This extension makes connect calls shorter, and safer by attaching nodes if not already attached.
extension AudioKit {

    // Attaches nodes if node.engine == nil
    private static func safeAttach(_ nodes: [AVAudioNode]) {
        _ = nodes.filter { $0.engine == nil }.map { engine.attach($0) }
    }

    // AVAudioMixer will crash if engine is started and connection is made to a bus exceeding mixer's
    // numberOfInputs. The crash only happens when using the AVAudioEngine function that connects a node to an array
    // of AVAudioConnectionPoints and the mixer is one of those points. When AVAudioEngine uses a different function
    // that connects a node's output to a single AVAudioMixerNode, the mixer's inputs are incremented to accommodate
    // the new connection. So the workaround is to create dummy nodes, make a connections to the mixer using the
    // function that makes the mixer create new inputs, then remove the dummy nodes so that there is an available
    // bus to connect to.
    //
    private static func checkMixerInputs(_ connectionPoints: [AVAudioConnectionPoint]) {

        if !engine.isRunning { return }

        for connection in connectionPoints {
            if let mixer = connection.node as? AVAudioMixerNode,
                connection.bus >= mixer.numberOfInputs {

                var dummyNodes = [AVAudioNode]()
                while connection.bus >= mixer.numberOfInputs {
                    let dummyNode = AVAudioUnitSampler()
                    dummyNode.setOutput(to: mixer)
                    dummyNodes.append(dummyNode)
                }
                for dummyNode in dummyNodes {
                    dummyNode.disconnectOutput()
                }

            }
        }
    }

    // If an AVAudioMixerNode's output connection is made while engine is running, and there are no input connections
    // on the mixer, subsequent connections made to the mixer will silently fail.  A workaround is to connect a dummy
    // node to the mixer prior to making a connection, then removing the dummy node after the connection has been made.
    //
    private static func addDummyOnEmptyMixer(_ node: AVAudioNode) -> AVAudioNode? {

        // Only an issue if engine is running, node is a mixer, and mixer has no inputs
        guard let mixer = node as? AVAudioMixerNode,
            engine.isRunning,
            !engine.mixerHasInputs(mixer: mixer) else {
                return nil
        }

        let dummy = AVAudioUnitSampler()
        engine.attach(dummy)
        engine.connect(dummy, to: mixer, format: AudioKit.format)
        return dummy
    }

    @objc open static func connect(_ sourceNode: AVAudioNode,
                                   to destNodes: [AVAudioConnectionPoint],
                                   fromBus sourceBus: AVAudioNodeBus,
                                   format: AVAudioFormat?) {

        let connectionsWithNodes = destNodes.filter { $0.node != nil }
        safeAttach([sourceNode] + connectionsWithNodes.map { $0.node! })
        // See addDummyOnEmptyMixer for dummyNode explanation.
        let dummyNode = addDummyOnEmptyMixer(sourceNode)
        checkMixerInputs(connectionsWithNodes)
        engine.connect(sourceNode, to: connectionsWithNodes, fromBus: sourceBus, format: format)
        dummyNode?.disconnectOutput()
    }

    @objc open static func connect(_ node1: AVAudioNode,
                                   to node2: AVAudioNode,
                                   fromBus bus1: AVAudioNodeBus,
                                   toBus bus2: AVAudioNodeBus,
                                   format: AVAudioFormat?) {

        safeAttach([node1, node2])
        // See addDummyOnEmptyMixer for dummyNode explanation.
        let dummyNode = addDummyOnEmptyMixer(node1)
        engine.connect(node1, to: node2, fromBus: bus1, toBus: bus2, format: format)
        dummyNode?.disconnectOutput()
    }

    @objc open static func connect(_ node1: AVAudioNode, to node2: AVAudioNode, format: AVAudioFormat?) {
        connect(node1, to: node2, fromBus: 0, toBus: 0, format: format)
    }

    //Convenience
    @objc open static func detach(nodes: [AVAudioNode]) {
        for node in nodes {
            engine.detach(node)
        }
    }

    /// Render output to an AVAudioFile for a duration.
    ///
    ///     - Parameters:
    ///         - audioFile: An file initialized for writing
    ///         - duration: Duration to render, in seconds
    ///         - prerender: A closure called before rendering starts, use this to start players, set initial parameters, etc...
    ///
    @available(iOS 11, macOS 10.13, tvOS 11, *)
    @objc open static func renderToFile(_ audioFile: AVAudioFile, duration: Double, prerender: (() -> Void)? = nil) throws {
        try engine.renderToFile(audioFile, duration: duration, prerender: prerender)
    }

}
