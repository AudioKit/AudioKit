//
//  AKSamplerVoice.hpp
//  AKSampler
//
//  Created by Shane Dunne on 2018-02-24.
//

#pragma once
#include <math.h>

#include "AKSampleBuffer.hpp"
#include "AKEnvelopeGenerator.hpp"

struct AKSampleOscillator
{
    bool bLooping;      // true until note released
    double fIndex;      // use double so we don't lose precision when fIndex becomes much larger than fIncrement
    double fIncrement;  // 1.0 = play at original speed
    double fIncMul;     // multiplier applied to increment for pitch bend, vibrato
    
    void setPitchOffsetSemitones(double semitones) { fIncMul = pow(2.0, semitones/12.0); }
    
    // return true if we run out of samples
    inline bool getSample(AKSampleBuffer* pSampleBuffer, int nSamples, float* pOut, float gain)
    {
        if (fIndex > pSampleBuffer->fEnd) return true;
        *pOut = pSampleBuffer->interp(fIndex, gain);
        
        fIndex += fIncMul * fIncrement;
        if (pSampleBuffer->bLoop && bLooping)
        {
            if (fIndex >= pSampleBuffer->fLoopEnd)
                fIndex = fIndex - pSampleBuffer->fLoopEnd + pSampleBuffer->fLoopStart;
        }
        return false;
    }
    
    // return true if we run out of samples
    inline bool getSamplePair(AKSampleBuffer* pSampleBuffer, int nSamples, float* pOutLeft, float* pOutRight, float gain)
    {
        if (fIndex > pSampleBuffer->fEnd) return true;
        pSampleBuffer->interp(fIndex, pOutLeft, pOutRight, gain);
        
        fIndex += fIncMul * fIncrement;
        if (pSampleBuffer->bLoop && bLooping)
        {
            if (fIndex >= pSampleBuffer->fLoopEnd)
                fIndex = fIndex - pSampleBuffer->fLoopEnd + pSampleBuffer->fLoopStart;
        }
        return false;
    }
};

// This works, but is experimental
//#define USE_EXPONENTIAL_ENVELOPES

#include "AKResonantLowPassFilter.hpp"

struct AKSamplerVoice
{
    AKSampleOscillator oscillator;      // every voice has 1 oscillator,
    AKSampleBuffer* pSampleBuffer;      // a pointer to the sample buffer for that oscillator,
    AKResonantLowPassFilter filterL, filterR;     // two filters (left/right),
#ifdef USE_EXPONENTIAL_ENVELOPES
    AKShapedEnvelopeGenerator ampEG, filterEG;    // and two envelope generators
#else
    AKEnvelopeGenerator ampEG, filterEG;
#endif
    
    int noteNumber;     // MIDI note number, or -1 if not playing any note
    float noteHz;       // note frequency in Hz
    float noteVol;      // fraction 0.0 - 1.0, based on MIDI velocity
    
    // temporary holding variables
    float tempGain;     // product of global volume, note volume, and amp EG
    bool filterEnable;  // true if filter should be used
    
    AKSamplerVoice() : noteNumber(-1) {}
    
    void start(unsigned noteNum, float sampleRateHz, float freqHz, float volume, AKSampleBuffer* pSampleBuf);
    void restart(float volume);
    void release();
    void stop();
    
    // return true if amp envelope is finished
    bool prepToGetSamples(float masterVol, float pitchOffset, float cutoffMultiple);
    
    bool getSamples(int nSamples, float* pOut);
    bool getSamples(int nSamples, float* pOutLeft, float* pOutRight);
};
