// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "STKInstrumentDSP.h"

STKInstrumentDSP::STKInstrumentDSP() : DSPBase(/*inputBusCount*/0) {
    isStarted = false;
}

void STKInstrumentDSP::reset() {
    if(auto instr = getInstrument()) {
        instr->clear();
    }
}

void STKInstrumentDSP::handleMIDIEvent(AUMIDIEvent const& midiEvent) {
    isStarted = true;
    uint8_t status = midiEvent.data[0] & 0xF0;

    uint8_t veloc = midiEvent.data[2];
    auto note = midiEvent.data[1];
    auto amplitude = (AUValue)veloc / 127.0;
    float frequency = pow(2.0, (note - 69.0) / 12.0) * 440.0;

    if(auto instr = getInstrument()) {

        switch(status) {
            case MIDI_NOTE_OFF : {
                uint8_t note = midiEvent.data[1];
                if (note > 127) break;
                instr->noteOff(amplitude);
                break;
            }
            case MIDI_NOTE_ON : {
                uint8_t note = midiEvent.data[1];
                uint8_t veloc = midiEvent.data[2];
                if (note > 127 || veloc > 127) break;
                instr->noteOn(frequency, amplitude);
                break;
            }
        }
    }
}

void STKInstrumentDSP::process2(FrameRange range) {
    auto instr = getInstrument();

    for (int i : range) {
        if (instr) outputSample(0, i) = instr->tick();
    }
    cloneFirstChannel(range);
}
