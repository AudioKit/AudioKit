// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>
#include <math.h>

#include "AKModulatedDelayDSP.hpp"

AKDSPRef akChorusCreateDSP()
{
    return new AKModulatedDelayDSP(kChorus);
}

AKDSPRef akFlangerCreateDSP()
{
    return new AKModulatedDelayDSP(kFlanger);
}

#import "AudioKitCore/Modulated Delay/ModulatedDelay_Defines.h"
const float kAKChorus_DefaultFrequency = kChorusDefaultModFreqHz;
const float kAKChorus_DefaultDepth = kChorusDefaultDepth;
const float kAKChorus_DefaultFeedback = kChorusDefaultFeedback;
const float kAKChorus_DefaultDryWetMix = kChorusDefaultMix;

const float kAKChorus_MinFrequency = kChorusMinModFreqHz;
const float kAKChorus_MaxFrequency = kChorusMaxModFreqHz;
const float kAKChorus_MinFeedback  = kChorusMinFeedback;
const float kAKChorus_MaxFeedback  = kChorusMaxFeedback;
const float kAKChorus_MinDepth     = kChorusMinDepth;
const float kAKChorus_MaxDepth     = kChorusMaxDepth;
const float kAKChorus_MinDryWetMix = kChorusMinDryWetMix;
const float kAKChorus_MaxDryWetMix = kChorusMaxDryWetMix;

const float kAKFlanger_DefaultFrequency = kFlangerDefaultModFreqHz;
const float kAKFlanger_DefaultDepth = kFlangerDefaultDepth;
const float kAKFlanger_DefaultFeedback = kFlangerDefaultFeedback;
const float kAKFlanger_DefaultDryWetMix = kFlangerDefaultMix;

const float kAKFlanger_MinFrequency = kFlangerMinModFreqHz;
const float kAKFlanger_MaxFrequency = kFlangerMaxModFreqHz;
const float kAKFlanger_MinFeedback  = kFlangerMinFeedback;
const float kAKFlanger_MaxFeedback  = kFlangerMaxFeedback;
const float kAKFlanger_MinDepth     = kFlangerMinDepth;
const float kAKFlanger_MaxDepth     = kFlangerMaxDepth;
const float kAKFlanger_MinDryWetMix = kFlangerMinDryWetMix;
const float kAKFlanger_MaxDryWetMix = kFlangerMaxDryWetMix;

AKModulatedDelayDSP::AKModulatedDelayDSP(AKModulatedDelayType type)
    : delay(type)
{
    parameters[AKModulatedDelayParameterFrequency] = &frequencyRamp;
    parameters[AKModulatedDelayParameterDepth] = &depthRamp;
    parameters[AKModulatedDelayParameterFeedback] = &feedbackRamp;
    parameters[AKModulatedDelayParameterDryWetMix] = &dryWetMixRamp;
    
    bCanProcessInPlace = true;
}

void AKModulatedDelayDSP::init(int channels, double sampleRate)
{
    AKDSPBase::init(channels, sampleRate);
    delay.init(channels, sampleRate);
}

void AKModulatedDelayDSP::deinit()
{
    AKDSPBase::deinit();
    delay.deinit();
}

#define CHUNKSIZE 8     // defines ramp interval

void AKModulatedDelayDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset)
{
    float *inBuffers[2], *outBuffers[2];
    inBuffers[0]  = (float *)inputBufferLists[0]->mBuffers[0].mData  + bufferOffset;
    inBuffers[1]  = (float *)inputBufferLists[0]->mBuffers[1].mData  + bufferOffset;
    outBuffers[0] = (float *)outputBufferList->mBuffers[0].mData + bufferOffset;
    outBuffers[1] = (float *)outputBufferList->mBuffers[1].mData + bufferOffset;
    unsigned channelCount = outputBufferList->mNumberBuffers;

    if (!isStarted)
    {
        // effect bypassed: just copy input to output
        memcpy(outBuffers[0], inBuffers[0], frameCount * sizeof(float));
        if (channelCount > 0)
            memcpy(outBuffers[1], inBuffers[1], frameCount * sizeof(float));
        return;
    }

    // process in chunks of maximum length CHUNKSIZE
    for (int frameIndex = 0; frameIndex < frameCount; frameIndex += CHUNKSIZE) {
        int chunkSize = frameCount - frameIndex;
        if (chunkSize > CHUNKSIZE) chunkSize = CHUNKSIZE;

        // ramp parameters
        frequencyRamp.stepBy(chunkSize);
        depthRamp.stepBy(chunkSize);
        feedbackRamp.stepBy(chunkSize);
        dryWetMixRamp.stepBy(chunkSize);

        // apply changes
        delay.setModFrequencyHz(frequencyRamp.get());
        delay.setModDepthFraction(depthRamp.get());
        float fb = feedbackRamp.get();
        delay.setLeftFeedback(fb);
        delay.setRightFeedback(fb);
        delay.setDryWetMix(dryWetMixRamp.get());

        // process
        delay.Render(channelCount, chunkSize, inBuffers, outBuffers);

        // advance pointers
        inBuffers[0] += chunkSize;
        inBuffers[1] += chunkSize;
        outBuffers[0] += chunkSize;
        outBuffers[1] += chunkSize;
    }
}

