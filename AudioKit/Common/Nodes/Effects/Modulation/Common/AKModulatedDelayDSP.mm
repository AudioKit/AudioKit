//
//  AKModulatedDelayDSP.mm
//  AudioKit
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKModulatedDelayDSP.hpp"

extern "C" void* createChorusDSP(int nChannels, double sampleRate)
{
    return new AKModulatedDelayDSP(kChorus);
}

extern "C" void* createFlangerDSP(int nChannels, double sampleRate)
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
    : AudioKitCore::ModulatedDelay(type)
    , AKDSPBase()
{
    depthRamp.setTarget(0.0f, true);
    depthRamp.setDurationInSamples(10000);
    feedbackRamp.setTarget(0.0f, true);
    feedbackRamp.setDurationInSamples(10000);
    switch (type) {
        case kFlanger:
            frequencyRamp.setTarget(kAKFlanger_DefaultFrequency, true);
            dryWetMixRamp.setTarget(kAKFlanger_DefaultDryWetMix, true);
            break;
        case kChorus:
        default:
            frequencyRamp.setTarget(kAKChorus_DefaultFrequency, true);
            dryWetMixRamp.setTarget(kAKChorus_DefaultDryWetMix, true);
            break;
    }
    dryWetMixRamp.setDurationInSamples(10000);
    frequencyRamp.setDurationInSamples(10000);
}

void AKModulatedDelayDSP::init(int channels, double sampleRate)
{
    AKDSPBase::init(channels, sampleRate);
    AudioKitCore::ModulatedDelay::init(channels, sampleRate);
}

void AKModulatedDelayDSP::deinit()
{
    AudioKitCore::ModulatedDelay::deinit();
}

void AKModulatedDelayDSP::setParameter(AUParameterAddress address, float value, bool immediate)
{
    switch (address) {
        case AKModulatedDelayParameterFrequency:
            frequencyRamp.setTarget(value, immediate);
            break;
        case AKModulatedDelayParameterDepth:
            depthRamp.setTarget(value, immediate);
            break;
        case AKModulatedDelayParameterFeedback:
            feedbackRamp.setTarget(value, immediate);
            break;
        case AKModulatedDelayParameterDryWetMix:
            dryWetMixRamp.setTarget(value, immediate);
            break;
        case AKModulatedDelayParameterRampDuration:
            frequencyRamp.setRampDuration(value, _sampleRate);
            depthRamp.setRampDuration(value, _sampleRate);
            feedbackRamp.setRampDuration(value, _sampleRate);
            dryWetMixRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

float AKModulatedDelayDSP::getParameter(AUParameterAddress address)
{
    switch (address) {
        case AKModulatedDelayParameterFrequency:
            return frequencyRamp.getTarget();
        case AKModulatedDelayParameterDepth:
            return depthRamp.getTarget();
        case AKModulatedDelayParameterFeedback:
            return feedbackRamp.getTarget();
        case AKModulatedDelayParameterDryWetMix:
            return dryWetMixRamp.getTarget();
        case AKModulatedDelayParameterRampDuration:
            return frequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

#define CHUNKSIZE 8     // defines ramp interval

void AKModulatedDelayDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset)
{
    float *inBuffers[2], *outBuffers[2];
    inBuffers[0]  = (float *)_inBufferListPtr->mBuffers[0].mData  + bufferOffset;
    inBuffers[1]  = (float *)_inBufferListPtr->mBuffers[1].mData  + bufferOffset;
    outBuffers[0] = (float *)_outBufferListPtr->mBuffers[0].mData + bufferOffset;
    outBuffers[1] = (float *)_outBufferListPtr->mBuffers[1].mData + bufferOffset;
    unsigned channelCount = _outBufferListPtr->mNumberBuffers;

    if (!_playing)
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
        frequencyRamp.advanceTo(_now + frameOffset);
        depthRamp.advanceTo(_now + frameOffset);
        feedbackRamp.advanceTo(_now + frameOffset);
        dryWetMixRamp.advanceTo(_now + frameOffset);
        
        // apply changes
        modOscillator.setFrequency(frequencyRamp.getValue());
        modDepthFraction = depthRamp.getValue();
        float fb = feedbackRamp.getValue();
        leftDelayLine.setFeedback(fb);
        rightDelayLine.setFeedback(fb);
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

