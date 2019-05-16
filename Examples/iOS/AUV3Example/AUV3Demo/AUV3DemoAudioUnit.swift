//
//  AUV3DemoAudioUnit.swift
//  AUV3Demo
//
//  Created by Jeff Cooper on 5/16/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation
import AudioKit

class AUV3DemoAudioUnit: AUAudioUnit {

    var engine = AVAudioEngine()    //each unit needs it's own avaudioEngine
    var conductor = Conductor()     //add Conductor.swift to auv3 target

    override init(componentDescription: AudioComponentDescription, options: AudioComponentInstantiationOptions = []) throws {
        AKLog("initing auv3 demo unit")
        AudioKit.engine = engine    // AudioKit.engine needs to be set early on

        conductor.setupRoute()

        do {
            try engine.enableManualRenderingMode(.realtime, format: AudioKit.format, maximumFrameCount: 4096)
            try super.init(componentDescription: componentDescription, options: options)
            try setOutputBusArrays()
        } catch {
            AKLog("Could not init audio unit")
            throw error
        }

        conductor.start()
        setInternalRenderingBlock()
    }

    func noteOn(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        conductor.playNote(noteNumber: note, velocity: velocity)
    }
    func noteOff(note: MIDINoteNumber, channel: MIDIChannel) {
        conductor.stop(noteNumber: note)
    }
    private func setInternalRenderingBlock() {
        self._internalRenderBlock = { (actionFlags, timeStamp, frameCount, outputBusNumber, outputData, renderEvent, pullInputBlock) in
            if let event = renderEvent?.pointee {
                switch event.head.eventType {
                case .parameter:
                    AKLog("receiving parameter")
                case .parameterRamp:
                    AKLog("receiving parameter ramp")
                case .MIDI:
                    self.handleMIDI(midiEventPointer: event.MIDI)
                case .midiSysEx:
                    AKLog("receiving MIDI Sysex")
                @unknown default:
                    AKLog("receiving unknown render event")
                }
            }

            // this is the line that actually produces sound using the buffers, keep it at the end
            _ = self.engine.manualRenderingBlock(frameCount, outputData, nil)
            return noErr
        }
    }

    private func handleMIDI(midiEventPointer: AUMIDIEvent) {
        var rawMIDIEventList: AUMIDIEvent? = midiEventPointer
        var midiEvents = [AUMIDIEvent]()
        while rawMIDIEventList != nil {
            if let rawEvent = rawMIDIEventList {
                midiEvents.append(rawEvent)
                rawMIDIEventList = rawMIDIEventList!.next?.pointee.MIDI
            }
        }
        for event in midiEvents {
            let midiEvent = AKMIDIEvent(data: [event.data.0, event.data.1, event.data.2])
            if midiEvent.status?.type == .noteOn {
                if midiEvent.data[2] == 0 {
                    noteOff(note: event.data.1, channel: midiEvent.channel ?? 0)
                } else {
                    noteOn(note: event.data.1, velocity: event.data.2, channel: midiEvent.channel ?? 0)
                }
            } else if midiEvent.status?.type == .noteOff {
                noteOff(note: event.data.1, channel: midiEvent.channel ?? 0)
            }
            AKLog("recd \(midiEvent.description)")
        }
    }

    private var _internalRenderBlock: AUInternalRenderBlock!
    override var internalRenderBlock: AUInternalRenderBlock {
        return self._internalRenderBlock
    }

    // Default OutputBusArray stuff you will need
    private var _outputBusArray: AUAudioUnitBusArray!

    override var outputBusses: AUAudioUnitBusArray {
        return self._outputBusArray
    }

    private func setOutputBusArrays() throws {
        let bus = try AUAudioUnitBus(format: AudioKit.format)
        self._outputBusArray = AUAudioUnitBusArray(audioUnit: self, busType: AUAudioUnitBusType.output, busses: [bus])
    }
}
