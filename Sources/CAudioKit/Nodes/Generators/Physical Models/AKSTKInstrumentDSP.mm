// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSTKInstrumentDSP.hpp"

AKSTKInstrumentDSP::AKSTKInstrumentDSP() : AKDSPBase(/*inputBusCount*/0) { }

void AKSTKInstrumentDSP::reset() {
    if(auto instr = getInstrument()) {
        instr->clear();
    }
}

void AKSTKInstrumentDSP::handleMIDIEvent(AUMIDIEvent const& midiEvent) {

    uint8_t status = midiEvent.data[0] & 0xF0;

    uint8_t veloc = midiEvent.data[2];
    auto note = midiEvent.data[1];
    auto amplitude = (AUValue)veloc / 127.0;
    float frequency = pow(2.0, (note - 69.0) / 12.0) * 440.0;

    if(auto instr = getInstrument()) {

        switch(status) {
            case 0x80 : { // note off
                uint8_t note = midiEvent.data[1];
                if (note > 127) break;
                instr->noteOff(amplitude);
                break;
            }
            case 0x90 : { // note on
                uint8_t note = midiEvent.data[1];
                uint8_t veloc = midiEvent.data[2];
                if (note > 127 || veloc > 127) break;
                instr->noteOn(frequency, amplitude);
                break;
            }
        }

    }

}

void AKSTKInstrumentDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    auto instr = getInstrument();

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        float outputSample = 0.0;
        if(isStarted && instr) {
            outputSample = instr->tick();
        }

        for (int channel = 0; channel < channelCount; ++channel) {
            float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;
            *out = outputSample;
        }
    }

}
