//
//  AKStereoDelayDSP.mm
//  AudioKit
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKStereoDelayDSP.hpp"
#include "StereoDelay.hpp"
#include "DSPKernel.hpp" // for clamp()

extern "C" AKDSPRef createStereoDelayDSP(int channelCount, double sampleRate) {
    AKStereoDelayDSP *dsp = new AKStereoDelayDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKStereoDelayDSP::InternalData {
    AudioKitCore::StereoDelay delay;

    AKLinearParameterRamp timeRamp;
    AKLinearParameterRamp feedbackRamp;
    AKLinearParameterRamp dryWetMixRamp;

};

AKStereoDelayDSP::AKStereoDelayDSP() : data(new InternalData) {
    data->timeRamp.setTarget(defaultTime, true);
    data->timeRamp.setDurationInSamples(defaultRampDurationSamples);
    data->feedbackRamp.setTarget(defaultFeedback, true);
    data->feedbackRamp.setDurationInSamples(defaultRampDurationSamples);
    data->dryWetMixRamp.setTarget(defaultDryWetMix, true);
    data->dryWetMixRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKStereoDelayDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKStereoDelayParameterTime:
            data->timeRamp.setTarget(clamp(value, timeLowerBound, timeUpperBound), immediate);
            break;
        case AKStereoDelayParameterFeedback:
            data->feedbackRamp.setTarget(clamp(value, feedbackLowerBound, feedbackUpperBound), immediate);
            break;
        case AKStereoDelayParameterDryWetMix:
            data->dryWetMixRamp.setTarget(clamp(value, dryWetMixLowerBound, dryWetMixUpperBound), immediate);
            break;
        case AKStereoDelayParameterPingPong:
            data->delay.setPingPongMode(value > 0.5f);
            break;
        case AKStereoDelayParameterRampDuration:
            data->timeRamp.setRampDuration(value, sampleRate);
            data->feedbackRamp.setRampDuration(value, sampleRate);
            data->dryWetMixRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKStereoDelayDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKStereoDelayParameterTime:
            return data->timeRamp.getTarget();
        case AKStereoDelayParameterFeedback:
            return data->feedbackRamp.getTarget();
        case AKStereoDelayParameterDryWetMix:
            return data->dryWetMixRamp.getTarget();
        case AKStereoDelayParameterPingPong:
            return data->delay.getPingPongMode() ? 1.0f : 0.0f;
        case AKStereoDelayParameterRampDuration:
            return data->timeRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKStereoDelayDSP::init(int channelCount, double sampleRate) {
    // TODO add something to handle 1 vs 2 channels
    data->delay.init(sampleRate, timeUpperBound * 1000.0);
}

void AKStereoDelayDSP::deinit() {
    data->delay.deinit();
}

void AKStereoDelayDSP::clear() {
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
