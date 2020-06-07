// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKSequencerEngineAudioUnit: AKAudioUnitBase {

    private(set) var tempo: AUParameter!

    private(set) var length: AUParameter!

    private(set) var maximumPlayCount: AUParameter!

    private(set) var position: AUParameter!

    private(set) var loopEnabled: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createAKSequencerEngineDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        tempo = AUParameter(
            identifier: "tempo",
            name: "Tempo",
            address: AKSequencerEngineParameter.tempo.rawValue,
            range: 1.0 ... 20.0,
            unit: .BPM,
            flags: .default)

        length = AUParameter(
            identifier: "length",
            name: "Length of the sequence",
            address: AKSequencerEngineParameter.length.rawValue,
            range: 0.0 ... Float.greatestFiniteMagnitude,
            unit: .beats,
            flags: .default)

        maximumPlayCount = AUParameter(
            identifier: "maximumPlayCount",
            name: "Maximum times to loop before stopping",
            address: AKSequencerEngineParameter.maximumPlayCount.rawValue,
            range: 0.0 ... Float(Int.max),
            unit: .generic,
            flags: .default)

        position = AUParameter(
            identifier: "position",
            name: "Release Duration",
            address: AKSequencerEngineParameter.position.rawValue,
            range: 0.0 ... Float.greatestFiniteMagnitude,
            unit: .beats,
            flags: .default)

        loopEnabled = AUParameter(
            identifier: "loopEnabled",
            name: "Looping Enabled",
            address: AKSequencerEngineParameter.loopEnabled.rawValue,
            range: 0.0 ... 1.0,
            unit: .boolean,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [tempo,
                                                                  length,
                                                                  maximumPlayCount,
                                                                  position,
                                                                  loopEnabled])

        tempo.value = AUValue(120)
        length.value = AUValue(4)
        maximumPlayCount.value = AUValue(0)
        position.value = AUValue(0)
        loopEnabled.value = AUValue(1)
    }

    func setTarget(_ target: AudioUnit) {
        sequencerEngineSetAUTarget(dsp, target)
    }

    func addMIDIEvent(status: UInt8,
                      data1: UInt8,
                      data2: UInt8,
                      beat: Double) {
        sequencerEngineAddMIDIEvent(dsp, status, data1, data2, beat)
    }

    func addMIDINote(number: UInt8,
                     velocity: UInt8,
                     beat: Double,
                     duration: Double) {
        sequencerEngineAddMIDINote(dsp, number, velocity, beat, duration)
    }

    func removeEvent(beat: Double) {
        sequencerEngineRemoveMIDIEvent(dsp, beat)
    }

    func removeNote(beat: Double) {
        sequencerEngineRemoveMIDINote(dsp, beat)
    }

    func removeNote(number: MIDINoteNumber, beat: Double) {
        sequencerEngineRemoveSpecificMIDINote(dsp, beat, number)
    }

    func removeAllInstancesOf(number: MIDINoteNumber) {
        sequencerEngineRemoveAllInstancesOf(dsp, number)
    }

    func clear() {
        sequencerEngineClear(dsp)
    }

    func stopPlayingNotes() {
        sequencerEngineStopPlayingNotes(dsp)
    }
}
