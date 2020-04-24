//
//  AKStereoDelayDSP.mm
//  AudioKit
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKStereoDelayDSP.hpp"
#include "StereoDelay.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createStereoDelayDSP() {
    return new AKStereoDelayDSP();
}

struct AKStereoDelayDSP::InternalData {
    AudioKitCore::StereoDelay delay;
    float timeUpperBound = 2.f;
    AKLinearParameterRamp timeRamp;
    AKLinearParameterRamp feedbackRamp;
    AKLinearParameterRamp dryWetMixRamp;
};

AKStereoDelayDSP::AKStereoDelayDSP() : data(new InternalData) {
    parameters[AKStereoDelayParameterTime] = &data->timeRamp;
    parameters[AKStereoDelayParameterFeedback] = &data->feedbackRamp;
    parameters[AKStereoDelayParameterDryWetMix] = &data->dryWetMixRamp;
    
    bCanProcessInPlace = true;
}

void AKStereoDelayDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    if (address == AKStereoDelayParameterPingPong) {
        data->delay.setPingPongMode(value > 0.5f);
    }
    else {
        AKDSPBase::setParameter(address, value, immediate);
    }
}

float AKStereoDelayDSP::getParameter(uint64_t address) {
    if (address == AKStereoDelayParameterPingPong) {
        return data->delay.getPingPongMode() ? 1.0f : 0.0f;
    }
    else {
        return AKDSPBase::getParameter(address);
    }
}

void AKStereoDelayDSP::init(int channelCount, double sampleRate) {
    AKDSPBase::init(channelCount, sampleRate);
    // TODO add something to handle 1 vs 2 channels
    data->delay.init(sampleRate, data->timeUpperBound * 1000.0);
}

void AKStereoDelayDSP::deinit() {
    AKDSPBase::deinit();
    data->delay.deinit();
}

void AKStereoDelayDSP::reset() {
    AKDSPBase::reset();
    data->delay.clear();
}

#define CHUNKSIZE 8     // defines ramp interval

void AKStereoDelayDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset)
{
    const float *inBuffers[2];
    float *outBuffers[2];
    inBuffers[0]  = (const float *)inBufferListPtr->mBuffers[0].mData  + bufferOffset;
    inBuffers[1]  = (const float *)inBufferListPtr->mBuffers[1].mData  + bufferOffset;
    outBuffers[0] = (float *)outBufferListPtr->mBuffers[0].mData + bufferOffset;
    outBuffers[1] = (float *)outBufferListPtr->mBuffers[1].mData + bufferOffset;
    //unsigned inChannelCount = inBufferListPtr->mNumberBuffers;
    //unsigned outChannelCount = outBufferListPtr->mNumberBuffers;

    if (!isStarted)
    {
        // effect bypassed: just copy input to output
        memcpy(outBuffers[0], inBuffers[0], frameCount * sizeof(float));
        memcpy(outBuffers[1], inBuffers[1], frameCount * sizeof(float));
        return;
    }

    // process in chunks of maximum length CHUNKSIZE
    for (int frameIndex = 0; frameIndex < frameCount; frameIndex += CHUNKSIZE)
    {
        int frameOffset = int(frameIndex + bufferOffset);
        int chunkSize = frameCount - frameIndex;
        if (chunkSize > CHUNKSIZE) chunkSize = CHUNKSIZE;

        // ramp parameters
        data->timeRamp.advanceTo(now + frameOffset);
        data->feedbackRamp.advanceTo(now + frameOffset);
        data->dryWetMixRamp.advanceTo(now + frameOffset);

        // apply changes
        data->delay.setDelayMs(1000.0 * data->timeRamp.getValue());
        data->delay.setFeedback(data->feedbackRamp.getValue());
        data->delay.setDryWetMix(data->dryWetMixRamp.getValue());

        // process
        data->delay.render(chunkSize, inBuffers, outBuffers);

        // advance pointers
        inBuffers[0] += chunkSize;
        inBuffers[1] += chunkSize;
        outBuffers[0] += chunkSize;
        outBuffers[1] += chunkSize;
    }
}
