// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
#pragma once
#include <AudioToolbox/AudioToolbox.h>

/// Handles the ickyness of accessing AURenderEvents without reading off the end of the struct.
///
/// - Parameters:
///   - events: render event list
///   - midi: callback for midi events
///   - sysex: callback for sysex events
///   - param: callback for param events
template<typename MidiFunc, typename SysexFunc, typename ParamFunc>
void processRenderEvents(AURenderEvent* events,
                         MidiFunc midiFunc,
                         SysexFunc sysexFunc,
                         ParamFunc paramFunc) {
    
    while(events) {
        switch(events->head.eventType) {
            case AURenderEventMIDI:
                midiFunc(&events->MIDI);
                break;
            case AURenderEventMIDISysEx:
                sysexFunc(&events->MIDI);
                break;
            case AURenderEventParameter:
                paramFunc(&events->parameter);
                break;
            case AURenderEventParameterRamp:
                paramFunc(&events->parameter);
                break;
            case AURenderEventMIDIEventList:
                midiFunc(&events->MIDI);
                break;
        }
        events = events->head.next;
    }
}
