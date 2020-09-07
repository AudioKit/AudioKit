// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKSoundpipeDSPBase.hpp"

#include "soundpipe.h"
#include "vocwrapper.h"

void AKSoundpipeDSPBase::init(int channelCount, double sampleRate) {
    AKDSPBase::init(channelCount, sampleRate);
    sp_create(&sp);
    sp->sr = sampleRate;
    sp->nchan = channelCount;
}

void AKSoundpipeDSPBase::deinit() {
    AKDSPBase::deinit();
    sp_destroy(&sp);
}

void AKSoundpipeDSPBase::processSample(int channel, float *in, float *out) {
    *out = *in;
}

void AKSoundpipeDSPBase::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
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
