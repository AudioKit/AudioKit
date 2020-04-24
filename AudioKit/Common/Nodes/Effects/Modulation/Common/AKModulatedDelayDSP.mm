//
//  AKModulatedDelayDSP.mm
//  AudioKit
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>
#include <math.h>

#include "AKModulatedDelayDSP.hpp"

extern "C" AKDSPRef createChorusDSP()
{
    return new AKModulatedDelayDSP(kChorus);
}

extern "C" AKDSPRef createFlangerDSP()
{
    return new AKModulatedDelayDSP(kFlanger);
}

#import "ModulatedDelay_Defines.h"
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
    : AKModulatedDelay(type)
    , AKDSPBase()
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
    AKModulatedDelay::init(channels, sampleRate);
}

void AKModulatedDelayDSP::deinit()
{
    AKDSPBase::deinit();
    AKModulatedDelay::deinit();
}

#define CHUNKSIZE 8     // defines ramp interval

void AKModulatedDelayDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset)
{
    float *inBuffers[2], *outBuffers[2];
    inBuffers[0]  = (float *)inBufferListPtr->mBuffers[0].mData  + bufferOffset;
    inBuffers[1]  = (float *)inBufferListPtr->mBuffers[1].mData  + bufferOffset;
    outBuffers[0] = (float *)outBufferListPtr->mBuffers[0].mData + bufferOffset;
    outBuffers[1] = (float *)outBufferListPtr->mBuffers[1].mData + bufferOffset;
    unsigned channelCount = outBufferListPtr->mNumberBuffers;

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
        int frameOffset = int(frameIndex + bufferOffset);
        int chunkSize = frameCount - frameIndex;
        if (chunkSize > CHUNKSIZE) chunkSize = CHUNKSIZE;

        // ramp parameters
        frequencyRamp.advanceTo(now + frameOffset);
        depthRamp.advanceTo(now + frameOffset);
        feedbackRamp.advanceTo(now + frameOffset);
        dryWetMixRamp.advanceTo(now + frameOffset);

        // apply changes
        setModFrequencyHz(frequencyRamp.getValue());
        modDepthFraction = depthRamp.getValue();
        float fb = feedbackRamp.getValue();
        setLeftFeedback(fb);
        setRightFeedback(fb);
        dryWetMix = dryWetMixRamp.getValue();

        // process
        Render(channelCount, chunkSize, inBuffers, outBuffers);

        // advance pointers
        inBuffers[0] += chunkSize;
        inBuffers[1] += chunkSize;
        outBuffers[0] += chunkSize;
        outBuffers[1] += chunkSize;
    }
}

