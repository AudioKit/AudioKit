// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "SoundpipeDSPBase.h"

#include "soundpipe.h"
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

    if(status == 0x90) { // note on
        internalTrigger = 1.0;
    }
}

void SoundpipeDSPBase::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);
        for (int channel = 0; channel <  channelCount; ++channel) {
            float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;

            if (isStarted) {
                processSample(channel, in, out);
            } else {
                *out = *in;
            }
        }
    }
}
