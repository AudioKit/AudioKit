// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AudioToolbox

func eventType(event: UnsafePointer<AURenderEvent>) -> AURenderEventType {
    event.withMemoryRebound(to: AURenderEventHeader.self, capacity: 1) { pointer in
        pointer.pointee.eventType
    }
}

func process(events: UnsafePointer<AURenderEvent>?,
             midi: (UnsafePointer<AUMIDIEvent>) -> () = { _ in },
             sysex: (UnsafePointer<AUMIDIEvent>) -> () = { _ in },
             param: (UnsafePointer<AUParameterEvent>) -> () = { _ in }) {

    var events = events
    while let event = events {

        event.withMemoryRebound(to: AURenderEventHeader.self, capacity: 1) { pointer in

            switch pointer.pointee.eventType {
            case .MIDI:
                event.withMemoryRebound(to: AUMIDIEvent.self, capacity: 1, midi)
            case .midiSysEx:
                event.withMemoryRebound(to: AUMIDIEvent.self, capacity: 1, sysex)
            case .parameter:
                event.withMemoryRebound(to: AUParameterEvent.self, capacity: 1, param)
            default:
                break
            }

            events = .init(pointer.pointee.next)

        }

    }
}
