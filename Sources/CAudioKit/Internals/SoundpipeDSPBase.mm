// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "SoundpipeDSPBase.h"

#include "Soundpipe.h"
#include "vocwrapper.h"

void SoundpipeDSPBase::init(int channelCount, double sampleRate) {
    DSPBase::init(channelCount, sampleRate);
    sp_create(&sp);
    sp->sr = sampleRate;
    sp->nchan = channelCount;
}

void SoundpipeDSPBase::deinit() {
    DSPBase::deinit();
    sp_destroy(&sp);
}

void SoundpipeDSPBase::processSample(int channel, float *in, float *out) {
    *out = *in;
}

void SoundpipeDSPBase::handleMIDIEvent(AUMIDIEvent const& midiEvent) {
    uint8_t status = midiEvent.data[0] & 0xF0;

    if (status == MIDI_NOTE_ON) { 
        internalTrigger = 1.0;
    }
}

void SoundpipeDSPBase::process(FrameRange range) {
    for (int i : range) {
        for (int channel = 0; channel < channelCount; ++channel) {
            processSample(channel, &inputSample(channel, i), &outputSample(channel, i));
        }
    }
}
