// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSequencerEngineDSP.hpp"

extern "C" AKDSPRef createAKSequencerEngineDSP() {
    return new AKSequencerEngineDSP();
}

extern "C" void sequencerEngineAddMIDIEvent(AKDSPRef dsp, uint8_t status, uint8_t data1, uint8_t data2, double beat) {
    ((AKSequencerEngineDSP*)dsp)->addMIDIEvent(status, data1, data2, beat);
}

extern "C" void sequencerEngineAddMIDINote(AKDSPRef dsp, uint8_t noteNumber, uint8_t velocity, double beat, double duration) {
    ((AKSequencerEngineDSP*)dsp)->addMIDINote(noteNumber, velocity, beat, duration);
}

extern "C" void sequencerEngineRemoveMIDIEvent(AKDSPRef dsp, double beat) {
    ((AKSequencerEngineDSP*)dsp)->removeEventAt(beat);
}

extern "C" void sequencerEngineRemoveMIDINote(AKDSPRef dsp, double beat) {
    ((AKSequencerEngineDSP*)dsp)->removeNoteAt(beat);
}

extern "C" void sequencerEngineRemoveSpecificMIDINote(AKDSPRef dsp, double beat, uint8_t noteNumber) {
    ((AKSequencerEngineDSP*)dsp)->removeNoteAt(noteNumber, beat);
}

extern "C" void sequencerEngineRemoveAllInstancesOf(AKDSPRef dsp, uint8_t noteNumber) {
    ((AKSequencerEngineDSP*)dsp)->removeAllInstancesOf(noteNumber);
}

extern "C" void sequencerEngineStopPlayingNotes(AKDSPRef dsp) {
    ((AKSequencerEngineDSP*)dsp)->stopPlayingNotes();
}

extern "C" void sequencerEngineClear(AKDSPRef dsp) {
    ((AKSequencerEngineDSP*)dsp)->clear();
}

extern "C" void sequencerEngineSetAUTarget(AKDSPRef dsp, AudioUnit audioUnit) {
    ((AKSequencerEngineDSP*)dsp)->setTargetAU(audioUnit);
}
