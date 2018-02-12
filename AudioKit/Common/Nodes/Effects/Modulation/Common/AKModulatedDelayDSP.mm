//
//  AKModulatedDelayDSP.cpp
//  AudioKit
//
//  Created by Shane Dunne on 2018-02-11.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKModulatedDelayDSP.hpp"

AKModulatedDelayDSP::AKModulatedDelayDSP(AKModulatedDelayType type)
    : effectType(type)
    , AKDSPBase()
{
    frequencyRamp.setTarget(DEFAULT_FREQUENCY_HZ, true);
    frequencyRamp.setDurationInSamples(10000);
    depthRamp.setTarget(MIN_FRACTION, true);
    depthRamp.setDurationInSamples(10000);
    feedbackRamp.setTarget(MIN_FRACTION, true);
    feedbackRamp.setDurationInSamples(10000);
    switch (type) {
        case kFlanger:
            dryWetMixRamp.setTarget(FLANGER_DEFAULT_DRYWETMIX, true);
            break;
        case kChorus:
        default:
            dryWetMixRamp.setTarget(CHORUS_DEFAULT_DRYWETMIX, true);
            break;
    }
    dryWetMixRamp.setDurationInSamples(10000);
}

void AKModulatedDelayDSP::init(int _channels, double _sampleRate)
{
    AKDSPBase::init(_channels, _sampleRate);
    
    minDelayMs = CHORUS_MIN_DELAY_MS;
    maxDelayMs = CHORUS_MAX_DELAY_MS;
    switch (effectType) {
        case kFlanger:
            minDelayMs = FLANGER_MIN_DELAY_MS;
            maxDelayMs = FLANGER_MAX_DELAY_MS;
            modOscillator.initTriangle(_sampleRate, DEFAULT_FREQUENCY_HZ);
            break;
        case kChorus:
        default:
            modOscillator.initSinusoid(_sampleRate, DEFAULT_FREQUENCY_HZ);
            break;
    }
    delayRangeMs = 0.5f * (maxDelayMs - minDelayMs);
    midDelayMs = 0.5f * (minDelayMs + maxDelayMs);
    leftDelayLine.init(_sampleRate, maxDelayMs);
    rightDelayLine.init(_sampleRate, maxDelayMs);
    leftDelayLine.setDelayMs(minDelayMs);
    rightDelayLine.setDelayMs(minDelayMs);
}

void AKModulatedDelayDSP::deinit()
{
    leftDelayLine.deinit();
    rightDelayLine.deinit();
    modOscillator.deinit();
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
        case AKModulatedDelayParameterRampTime:
            frequencyRamp.setRampTime(value, _sampleRate);
            depthRamp.setRampTime(value, _sampleRate);
            feedbackRamp.setRampTime(value, _sampleRate);
            dryWetMixRamp.setRampTime(value, _sampleRate);
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
        case AKModulatedDelayParameterRampTime:
            return frequencyRamp.getRampTime(_sampleRate);
    }
    return 0;
}

void AKModulatedDelayDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset)
{
    
    // For each sample.
    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        
        int frameOffset = int(frameIndex + bufferOffset);
        
        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            frequencyRamp.advanceTo(_now + frameOffset);
            depthRamp.advanceTo(_now + frameOffset);
            feedbackRamp.advanceTo(_now + frameOffset);
            dryWetMixRamp.advanceTo(_now + frameOffset);
            
            modOscillator.setFrequency(frequencyRamp.getValue());
            float fb = feedbackRamp.getValue();
            leftDelayLine.setFeedback(fb);
            rightDelayLine.setFeedback(fb);
        }
        
        // do actual signal processing
        float *inLeft  = (float *)_inBufferListPtr->mBuffers[0].mData  + frameOffset;
        float *outLeft = (float *)_outBufferListPtr->mBuffers[0].mData + frameOffset;
        float *inRight  = (float *)_inBufferListPtr->mBuffers[1].mData  + frameOffset;
        float *outRight = (float *)_outBufferListPtr->mBuffers[1].mData + frameOffset;
        
        float modLeft, modRight;
        modOscillator.getSamples(&modLeft, &modRight);
        float depth = depthRamp.getValue();
        
        float leftDelayMs = midDelayMs + delayRangeMs * depth * modLeft;
        float rightDelayMs = midDelayMs + delayRangeMs * depth * modRight;
        switch (effectType) {
            case kFlanger:
                leftDelayMs = minDelayMs + delayRangeMs * depth * (1.0f + modLeft);
                rightDelayMs = minDelayMs + delayRangeMs * depth * (1.0f + modRight);
                break;
                
            case kChorus:
            default:
                break;
        }
        leftDelayLine.setDelayMs(leftDelayMs);
        rightDelayLine.setDelayMs(rightDelayMs);
        
        float dryWetMix = dryWetMixRamp.getValue();
        float dryFraction = 1.0f - dryWetMix;
        *outLeft = dryFraction * (*inLeft) + dryWetMix * leftDelayLine.push(*inLeft);
        *outRight = dryFraction * (*inRight) + dryWetMix * rightDelayLine.push(*inRight);
    }
}


SDDelayLine::SDDelayLine() : pBuffer(0)
{
}

void SDDelayLine::init(double sampleRate, double maxDelayMs)
{
    sampleRateHz = sampleRate;
    capacity = int(maxDelayMs * sampleRateHz / 1000.0);
    if (pBuffer) delete[] pBuffer;
    pBuffer = new float[capacity];
    for (int i=0; i < capacity; i++) pBuffer[i] = 0.0f;
    writeIndex = 0;
    readIndex = capacity - 1;
}

void SDDelayLine::deinit()
{
    if (pBuffer) delete[] pBuffer;
    pBuffer = 0;
}

void SDDelayLine::setDelayMs(double delayMs)
{
    float fReadWriteGap = float(delayMs * sampleRateHz / 1000.0);
    if (fReadWriteGap < 0.0f) fReadWriteGap = 0.0f;
    if (fReadWriteGap > capacity) fReadWriteGap = capacity;
    readIndex = writeIndex - fReadWriteGap;
    while (readIndex < 0.0f) readIndex += capacity;
}

void SDDelayLine::setFeedback(float feedback)
{
    fbFraction = feedback;
}

float SDDelayLine::push(float sample)
{
    if (!pBuffer) return sample;
    
    int ri = int(readIndex);
    float f = readIndex - ri;
    int rj = ri + 1; if (rj >= capacity) rj -= capacity;
    readIndex += 1.0f;
    if (readIndex >= capacity) readIndex -= capacity;
    
    float si = pBuffer[ri];
    float sj = pBuffer[rj];
    float outSample = (1.0 - f) * si + f * sj;
    
    pBuffer[writeIndex++] = sample + fbFraction * outSample;
    if (writeIndex >= capacity) writeIndex = 0;
    
    return outSample;
}


SDWaveTable::SDWaveTable()
: pWaveTable(0), nTableSize(0)
{
}

void SDWaveTable::init(int tableLength)
{
    if (nTableSize == tableLength) return;
    nTableSize = tableLength;
    if (pWaveTable) delete[] pWaveTable;
    pWaveTable = new float[tableLength];
}

void SDWaveTable::deinit()
{
    if (pWaveTable) delete[] pWaveTable;
    pWaveTable = 0;
}

void SDWaveTable::initSinusoid(int tableLength)
{
    init(tableLength);
    for (int i=0; i < tableLength; i++)
        pWaveTable[i] = sin(double(i)/tableLength * 2.0 * M_PI);
}

void SDWaveTable::initTriangle(int tableLength)
{
    init(tableLength);
    for (int i=0; i < tableLength; i++)
        pWaveTable[i] = 2.0f * (0.5f - fabs((double(i)/tableLength) - 0.5)) - 1.0f;
}

float SDWaveTable::interp(float phase)
{
    while (phase < 0) phase += 1.0;
    while (phase >= 1.0) phase -= 1.0f;
    
    float readIndex = phase * nTableSize;
    int ri = int(readIndex);
    float f = readIndex - ri;
    int rj = ri + 1; if (rj >= nTableSize) rj -= nTableSize;
    
    float si = pWaveTable[ri];
    float sj = pWaveTable[rj];
    return (1.0 - f) * si + f * sj;
}


void SDTwoPhaseOscillator::init(double sampleRate, float frequency, int tableLength)
{
    sampleRateHz = sampleRate;
    phase = 0.0f;
    phaseDelta = frequency / sampleRate;
}

void SDTwoPhaseOscillator::deinit()
{
    waveTable.deinit();
}

void SDTwoPhaseOscillator::initSinusoid(double sampleRate, float frequency, int tableLength)
{
    init(sampleRate, frequency, tableLength);
    waveTable.initSinusoid(tableLength);
}

void SDTwoPhaseOscillator::initTriangle(double sampleRate, float frequency, int tableLength)
{
    init(sampleRate, frequency, tableLength);
    waveTable.initTriangle(tableLength);
}

void SDTwoPhaseOscillator::setFrequency(float frequency)
{
    phaseDelta = frequency / sampleRateHz;
}

void SDTwoPhaseOscillator::getSamples(float* pSin, float* pCos)
{
    *pSin = waveTable.interp(phase);
    *pCos = waveTable.interp(phase + 0.25f);
    phase += phaseDelta;
    if (phase >= 1.0f) phase -= 1.0f;
}
