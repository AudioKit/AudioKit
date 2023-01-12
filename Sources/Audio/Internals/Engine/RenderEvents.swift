// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioToolbox
import Foundation

/// Handles the ickyness of accessing AURenderEvents without reading off the end of the struct.
///
/// - Parameters:
///   - events: render event list
///   - midi: callback for midi events
///   - sysex: callback for sysex events
///   - param: callback for param events
func process(events: UnsafePointer<AURenderEvent>?,
             midi: (UnsafePointer<AUMIDIEvent>) -> Void = { _ in },
             sysex: (UnsafePointer<AUMIDIEvent>) -> Void = { _ in },
             param: (UnsafePointer<AUParameterEvent>) -> Void = { _ in })
{
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
