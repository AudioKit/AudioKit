// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "ModulatedDelay.h"
#include "ModulatedDelay_Defines.h"

#include "AdjustableDelayLine.hpp"
#include "FunctionTable.hpp"

#ifdef _MSC_VER
#pragma warning(push)
#pragma warning(disable:4018) // more "signed/unsigned mismatch"
#pragma warning(disable:4100) // unreferenced formal parameter
#pragma warning(disable:4101) // unreferenced local variable
#pragma warning(disable:4245) // 'return': conversion from 'int' to 'size_t', signed/unsigned mismatch
#pragma warning(disable:4267) // conversion from... possible loss of data
#pragma warning(disable:4305) // truncation from 'double' to 'float'
#pragma warning(disable:4309) // truncation of constant value
#pragma warning(disable:4334) // result of 32-bit shift implicitly converted to 64 bits
#pragma warning(disable:4456) // Declaration hides previous local declaration
#pragma warning(disable:4458) // declaration ... hides class member
#pragma warning(disable:4505) // unreferenced local function has been removed
#endif

struct ModulatedDelay::InternalData
{
    AudioKitCore::AdjustableDelayLine leftDelayLine, rightDelayLine;
    AudioKitCore::FunctionTableOscillator modOscillator;
};

ModulatedDelay::ModulatedDelay(ModulatedDelayType type)
: modFreqHz(1.0f)
, modDepthFraction(0.0f)
, effectType(type), data(new InternalData)
{
}

ModulatedDelay::~ModulatedDelay()
{
    deinit();
}

void ModulatedDelay::init(int channelCount, double sampleRate)
{
    minDelayMs = kChorusMinDelayMs;
    maxDelayMs = kChorusMaxDelayMs;
    data->modOscillator.init(sampleRate, modFreqHz);
    switch (effectType) {
        case kFlanger:
            minDelayMs = kFlangerMinDelayMs;
            maxDelayMs = kFlangerMaxDelayMs;
            data->modOscillator.waveTable.triangle();
            break;
        case kChorus:
        default:
            data->modOscillator.waveTable.sinusoid();
            break;
    }
    delayRangeMs = 0.5f * (maxDelayMs - minDelayMs);
    midDelayMs = 0.5f * (minDelayMs + maxDelayMs);
    data->leftDelayLine.init(sampleRate, maxDelayMs);
    data->rightDelayLine.init(sampleRate, maxDelayMs);
    data->leftDelayLine.setDelayMs(minDelayMs);
    data->rightDelayLine.setDelayMs(minDelayMs);
}

void ModulatedDelay::deinit()
{
    data->leftDelayLine.deinit();
    data->rightDelayLine.deinit();
    data->modOscillator.deinit();
}

void ModulatedDelay::setModFrequencyHz(float freq)
{
    data->modOscillator.setFrequency(freq);
}

void ModulatedDelay::setLeftFeedback(float feedback)
{
    data->leftDelayLine.setFeedback(feedback);
}

void ModulatedDelay::setRightFeedback(float feedback)
{
    data->rightDelayLine.setFeedback(feedback);
}

void ModulatedDelay::Render(unsigned channelCount, unsigned sampleCount,
                              float *inBuffers[], float *outBuffers[])
{
    float *pInLeft   = inBuffers[0];
    float *pInRight  = inBuffers[1];
    float *pOutLeft  = outBuffers[0];
    float *pOutRight = outBuffers[1];
    
    for (int i=0; i < (int)sampleCount; i++)
    {
        float modLeft, modRight;
        data->modOscillator.getSamples(&modLeft, &modRight);
        
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
        data->leftDelayLine.setDelayMs(leftDelayMs);
        data->rightDelayLine.setDelayMs(rightDelayMs);
        
        float dryFraction = 1.0f - dryWetMix;
        *pOutLeft++ = dryFraction * (*pInLeft) + dryWetMix * data->leftDelayLine.push(*pInLeft);
        pInLeft++;
        if (channelCount > 1)
        {
            *pOutRight++ = dryFraction * (*pInRight) + dryWetMix * data->rightDelayLine.push(*pInRight);
            pInRight++;
        }
    }
    
}
