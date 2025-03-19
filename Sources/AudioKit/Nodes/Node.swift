// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/// Node in an audio graph.
public protocol Node: AnyObject {
    /// Nodes providing audio input to this node.
    var connections: [Node] { get }

    /// Internal AVAudioEngine node.
    var avAudioNode: AVAudioNode { get }

    /// Start the node
    func start()

    /// Stop the node
    func stop()

    /// Bypass the node
    func bypass()

    /// Tells whether the node is processing (ie. started, playing, or active)
    var isStarted: Bool { get }

    /// Audio format to use when connecting this node.
    /// Defaults to  [Settings.audioFormat](x-source-tag://SettingsAudioFormat)
    var outputFormat: AVAudioFormat { get }
}

public extension Node {
    /// Reset the internal state of the unit
    /// Fixes issues such as https://github.com/AudioKit/AudioKit/issues/2046
    func reset() {
        if let avAudioUnit = avAudioNode as? AVAudioUnit {
            AudioUnitReset(avAudioUnit.audioUnit, kAudioUnitScope_Global, 0)
        }
    }

#if !os(tvOS)
    /// Schedule an event with an offset
    ///
    /// - Parameters:
    ///   - event: MIDI Event to schedule
    ///   - offset: Time in samples
    ///
    func scheduleMIDIEvent(event: MIDIEvent, offset: UInt64 = 0) {
        if let midiBlock = avAudioNode.auAudioUnit.scheduleMIDIEventBlock {
            event.data.withUnsafeBufferPointer { ptr in
                guard let ptr = ptr.baseAddress else { return }
                midiBlock(AUEventSampleTimeImmediate + AUEventSampleTime(offset), 0, event.data.count, ptr)
            }
        }
    }
#endif

    var isStarted: Bool { !bypassed }
    func start() { bypassed = false }
    func stop() { bypassed = true }
    func play() { bypassed = false }
    func bypass() { bypassed = true }
    var outputFormat: AVAudioFormat { Settings.audioFormat }

    /// All parameters on the Node
    var parameters: [NodeParameter] {
        let mirror = Mirror(reflecting: self)
        var params: [NodeParameter] = []

        for child in mirror.children {
            if let param = child.value as? ParameterBase {
                params.append(param.projectedValue)
            }
        }

        return params
    }

    /// Set up node parameters using reflection
    func setupParameters() {
        let mirror = Mirror(reflecting: self)
        var params: [AUParameter] = []

        for child in mirror.children {
            if let param = child.value as? ParameterBase {
                let def = param.projectedValue.def
                let auParam = AUParameterTree.createParameter(identifier: def.identifier,
                                                              name: def.name,
                                                              address: def.address,
                                                              range: def.range,
                                                              unit: def.unit,
                                                              flags: def.flags)
                params.append(auParam)
                param.projectedValue.associate(with: avAudioNode, parameter: auParam)
            }
        }

        avAudioNode.auAudioUnit.parameterTree = AUParameterTree.createTree(withChildren: params)
    }
}

extension Node {

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
    /// - Parameter node: AVAudioNode to associate
    func associateParams(with node: AVAudioNode) {
        let mirror = Mirror(reflecting: self)

        for child in mirror.children {
            if let param = child.value as? ParameterBase {
                param.projectedValue.associate(with: node)
            }
        }
    }

    func makeAVConnections(for subset: [Node]? = nil) {
        let connections = subset ?? connections
        if let node = self as? HasInternalConnections {
            node.makeInternalConnections()
        }

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

				// If avAudioNode is a Mixer, let Mixers will decide which input bus to use.
				if let mixer = avAudioNode as? AVAudioMixerNode {
					mixer.connectMixer(input: connection.avAudioNode, format: connection.outputFormat)
					if let akMixer = self as? Mixer {
						mixer.outputVolume = akMixer.volume
					}
				} else if let environmentNode = avAudioNode as? AVAudioEnvironmentNode,
						  let mixer3D = connection as? Mixer3D,
						  let avAudioMixerNode = mixer3D.avAudioNode as? AVAudioMixerNode {
					// If avAudioNode isA AVAudioEnvironmentNode and a Mixer3D is connecting to it.
					// Makes sure the Mixer3D -Connects> EnvironmentNode as Mono.  **THIS IS IMPORTANT!**
					// This also ensure EnvironmentalNodes input connections are **only** Mixers3D, so you can adjust 3D Parameters
					environmentNode.connectMixer3D(avAudioMixerNode, format: connection.outputFormat)
				} else {
					avAudioNode.connect(input: connection.avAudioNode, bus: bus, format: connection.outputFormat)
				}

				connection.makeAVConnections()
			}
        }
    }

    var bypassed: Bool {
        get { avAudioNode.auAudioUnit.shouldBypassEffect }
        set { avAudioNode.auAudioUnit.shouldBypassEffect = newValue }
    }
}

public protocol HasInternalConnections: AnyObject {
    /// Override point for any connections internal to the node.
    func makeInternalConnections()
}

/// Protocol mostly to support DynamicOscillator in SoundpipeAudioKit, but could be used elsewhere
public protocol DynamicWaveformNode: Node {
    /// Sets the wavetable
    /// - Parameter waveform: The tablve
    func setWaveform(_ waveform: Table)

    /// Gets the floating point values stored in the wavetable
    func getWaveformValues() -> [Float]

    /// Set the waveform change handler
    /// - Parameter handler: Closure with an array of floats as the argument
    func setWaveformUpdateHandler(_ handler: @escaping ([Float]) -> Void)
}
