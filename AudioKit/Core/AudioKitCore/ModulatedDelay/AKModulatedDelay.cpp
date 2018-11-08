//
//  ModulatedDelay.cpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKModulatedDelay.hpp"
#include "ModulatedDelay_Defines.h"

#include "AdjustableDelayLine.hpp"
#include "FunctionTable.hpp"

struct AKModulatedDelay::_Internal
{
    AudioKitCore::AdjustableDelayLine leftDelayLine, rightDelayLine;
    AudioKitCore::FunctionTableOscillator modOscillator;
};

AKModulatedDelay::AKModulatedDelay(AKModulatedDelayType type)
: modFreqHz(1.0f)
, modDepthFraction(0.0f)
, effectType(type), _private(new _Internal)
{
}

AKModulatedDelay::~AKModulatedDelay()
{
    deinit();
}

void AKModulatedDelay::init(int channels, double sampleRate)
{
    minDelayMs = kChorusMinDelayMs;
    maxDelayMs = kChorusMaxDelayMs;
    _private->modOscillator.init(sampleRate, modFreqHz);
    switch (effectType) {
        case kFlanger:
            minDelayMs = kFlangerMinDelayMs;
            maxDelayMs = kFlangerMaxDelayMs;
            _private->modOscillator.waveTable.triangle();
            break;
        case kChorus:
        default:
            _private->modOscillator.waveTable.sinusoid();
            break;
    }
    delayRangeMs = 0.5f * (maxDelayMs - minDelayMs);
    midDelayMs = 0.5f * (minDelayMs + maxDelayMs);
    _private->leftDelayLine.init(sampleRate, maxDelayMs);
    _private->rightDelayLine.init(sampleRate, maxDelayMs);
    _private->leftDelayLine.setDelayMs(minDelayMs);
    _private->rightDelayLine.setDelayMs(minDelayMs);
}

void AKModulatedDelay::deinit()
{
    _private->leftDelayLine.deinit();
    _private->rightDelayLine.deinit();
    _private->modOscillator.deinit();
}

void AKModulatedDelay::setModFrequencyHz(float freq)
{
    _private->modOscillator.setFrequency(freq);
}

void AKModulatedDelay::setLeftFeedback(float feedback)
{
    _private->leftDelayLine.setFeedback(feedback);
}

void AKModulatedDelay::setRightFeedback(float feedback)
{
    _private->rightDelayLine.setFeedback(feedback);
}

void AKModulatedDelay::Render(unsigned channelCount, unsigned sampleCount,
                              float *inBuffers[], float *outBuffers[])
{
    float *pInLeft   = inBuffers[0];
    float *pInRight  = inBuffers[1];
    float *pOutLeft  = outBuffers[0];
    float *pOutRight = outBuffers[1];
    
    for (int i=0; i < (int)sampleCount; i++)
    {
        float modLeft, modRight;
        _private->modOscillator.getSamples(&modLeft, &modRight);
        
        float leftDelayMs = midDelayMs + delayRangeMs * modDepthFraction * modLeft;
        float rightDelayMs = midDelayMs + delayRangeMs * modDepthFraction * modRight;
        switch (effectType) {
            case kFlanger:
                leftDelayMs = minDelayMs + delayRangeMs * modDepthFraction * (1.0f + modLeft);
                rightDelayMs = minDelayMs + delayRangeMs * modDepthFraction * (1.0f + modRight);
                break;
                
            case kChorus:
            default:
                break;
        }
        _private->leftDelayLine.setDelayMs(leftDelayMs);
        _private->rightDelayLine.setDelayMs(rightDelayMs);
        
        float dryFraction = 1.0f - dryWetMix;
        *pOutLeft++ = dryFraction * (*pInLeft) + dryWetMix * _private->leftDelayLine.push(*pInLeft);
        pInLeft++;
        if (channelCount > 1)
        {
            *pOutRight++ = dryFraction * (*pInRight) + dryWetMix * _private->rightDelayLine.push(*pInRight);
            pInRight++;
        }
    }
    
}
