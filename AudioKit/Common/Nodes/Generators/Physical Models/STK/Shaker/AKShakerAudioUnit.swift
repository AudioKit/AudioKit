// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public class AKShakerAudioUnit: AKAudioUnitBase {

    public override func createDSP() -> AKDSPRef {
        return akCreateDSP("AKShakerDSP")
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [])
    }

    public func trigger(type: AUValue, amplitude: AUValue) {

        if let midiBlock = scheduleMIDIEventBlock {
            let event = AKMIDIEvent(noteOn: UInt8(type),
                                    velocity: UInt8(amplitude * 127.0),
                                    channel: 0)
            event.data.withUnsafeBufferPointer { ptr in
                guard let ptr = ptr.baseAddress else { return }
                midiBlock(AUEventSampleTimeImmediate, 0, event.data.count, ptr)
            }
        }

    }
}
