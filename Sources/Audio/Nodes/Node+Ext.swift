// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import MIDI
import Utilities

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

        au.parameterTree = AUParameterTree.createTree(withChildren: params)
    }
}

extension Node {

    /// The underlying AudioUnit for the node.
    ///
    /// NOTE: some AVAudioNodes (e.g.  AVAudioPlayerNode) can't be used without AVAudioEngine.
    /// For those we'll need to use AUAudioUnit directly and override this.
    public var au: AUAudioUnit {
        avAudioNode.auAudioUnit
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
    /// - Parameter node: AVAudioNode to associate
    func associateParams(with node: AVAudioNode) {
        let mirror = Mirror(reflecting: self)

        for child in mirror.children {
            if let param = child.value as? ParameterBase {
                param.projectedValue.associate(with: node)
            }
        }
    }

    var bypassed: Bool {
        get { au.shouldBypassEffect }
        set { au.shouldBypassEffect = newValue }
    }
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
