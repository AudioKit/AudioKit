// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import MIDIKitIO
import Utilities

public extension Node {
    /// Reset the internal state of the unit
    func reset() {
        auAudioUnit.reset()

        // Call AudioUnitReset due to https://github.com/AudioKit/AudioKit/issues/2046
        if let v2au = (auAudioUnit as? AUAudioUnitV2Bridge)?.audioUnit {
            AudioUnitReset(v2au, kAudioUnitScope_Global, 0)
        }
    }

    /// Schedule an event with an offset
    ///
    /// - Parameters:
    ///   - event: MIDI Event to schedule
    ///   - offset: Time in samples
    ///
    func scheduleMIDIEvent(event: MIDIEvent, offset: UInt64 = 0) {
        if let midiBlock = auAudioUnit.scheduleMIDIEventBlock {
            // note: AUScheduleMIDIEventBlock expected MIDI 1.0 raw bytes, not UMP/MIDI 2.0
            let midi1RawBytes = event.midi1RawBytes()
            event.midi1RawBytes().withUnsafeBufferPointer { ptr in
                guard let ptr = ptr.baseAddress else { return }
                midiBlock(AUEventSampleTimeImmediate + AUEventSampleTime(offset), 0, midi1RawBytes.count, ptr)
            }
        }
    }

    var isStarted: Bool { !bypassed }
    var outputFormat: AVAudioFormat {
        auAudioUnit.outputBusses[0].format
    }

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
                param.projectedValue.associate(with: auAudioUnit, parameter: auParam)
            }
        }

        auAudioUnit.parameterTree = AUParameterTree.createTree(withChildren: params)
    }
}

public extension Node {
    /// Scan for all parameters and associate with the node.
    /// - Parameter au: AUAudioUnit to associate
    func associateParams(with au: AUAudioUnit) {
        let mirror = Mirror(reflecting: self)

        for child in mirror.children {
            if let param = child.value as? ParameterBase {
                param.projectedValue.associate(with: au)
            }
        }
    }

    var bypassed: Bool {
        get { auAudioUnit.shouldBypassEffect }
        set { auAudioUnit.shouldBypassEffect = newValue }
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

public extension Node {

    /// Depth-first search of the Node DAG.
    func dfs(seen: inout Set<ObjectIdentifier>,
             list: inout [Node])
    {
        let id = ObjectIdentifier(self)
        if seen.contains(id) { return }

        seen.insert(id)

        for input in connections {
            input.dfs(seen: &seen, list: &list)
        }

        list.append(self)
    }
}
