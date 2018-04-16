//
//  SamplerVoice.cpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "SamplerVoice.hpp"
#include <stdio.h>

namespace AudioKitCore
{
    void SamplerVoice::init(double sampleRate)
    {
        filterL.init(sampleRate);
        filterR.init(sampleRate);
        ampEG.init();
        filterEG.init();
    }
    
    void SamplerVoice::start(unsigned noteNum, float sampleRateHz, float freqHz, float volume, SampleBuffer* pBuf)
    {
        pSampleBuffer = pBuf;
        oscillator.fIndex = pBuf->fStart;
        oscillator.fIncrement = (pBuf->sampleRateHz / sampleRateHz) * (freqHz / pBuf->noteHz);
        oscillator.fIncMul = 1.0;
        oscillator.bLooping = pBuf->bLoop;
        
        noteVol = volume;
        ampEG.start();
        
        double sr = (double)sampleRateHz;
        filterL.updateSampleRate(sr);
        filterR.updateSampleRate(sr);
        filterEG.start();
        
        noteHz = freqHz;
        noteNumber = noteNum;
    }
    
    void SamplerVoice::restart(float volume, SampleBuffer* pSampleBuf)
    {
        tempNoteVol = noteVol;
        pNewSampleBuffer = pSampleBuf;
        ampEG.restart();
        noteVol = volume;
        filterEG.start();
    }
    
    void SamplerVoice::release(bool loopThruRelease)
    {
        if (!loopThruRelease) oscillator.bLooping = false;
        ampEG.release();
        filterEG.release();
    }
    
    void SamplerVoice::stop()
    {
        noteNumber = -1;
        ampEG.reset();
        filterEG.reset();
    }
    
    bool SamplerVoice::prepToGetSamples(float masterVol, float pitchOffset,
                                        float cutoffMultiple, float cutoffEgStrength,
                                        float resLinear)
    {
        if (ampEG.isIdle()) return true;

        if (ampEG.isPreStarting())
        {
            tempGain = masterVol * tempNoteVol * ampEG.getSample();
            if (!ampEG.isPreStarting())
            {
                tempGain = masterVol * noteVol * ampEG.getSample();
                pSampleBuffer = pNewSampleBuffer;
                oscillator.fIndex = pSampleBuffer->fStart;
                oscillator.bLooping = pSampleBuffer->bLoop;
            }
        }
        else
            tempGain = masterVol * noteVol * ampEG.getSample();
        oscillator.setPitchOffsetSemitones(pitchOffset);
        
        // negative value of cutoffMultiple means filters are disabled
        if (cutoffMultiple < 0.0f)
        {
            filterEnable = false;
        }
        else
        {
            filterEnable = true;
            double cutoffHz = noteHz * (1.0f + cutoffMultiple + cutoffEgStrength * filterEG.getSample());
            filterL.setParams(cutoffHz, resLinear);
            filterR.setParams(cutoffHz, resLinear);
        }
        
        return false;
    }
    
    bool SamplerVoice::getSamples(int nSamples, float* pOut)
    {
        for (int i=0; i < nSamples; i++)
        {
            float sample;
            if (oscillator.getSample(pSampleBuffer, nSamples, &sample, tempGain)) return true;
            *pOut++ += filterEnable ? filterL.process(sample) : sample;
        }
        return false;
    }
    
    bool SamplerVoice::getSamples(int nSamples, float* pOutLeft, float* pOutRight)
    {
        for (int i=0; i < nSamples; i++)
        {
            float leftSample, rightSample;
            if (oscillator.getSamplePair(pSampleBuffer, nSamples, &leftSample, &rightSample, tempGain)) return true;
            if (filterEnable)
            {
                *pOutLeft++ += filterL.process(leftSample);
                *pOutRight++ += filterR.process(rightSample);
            }
            else
            {
                *pOutLeft++ += leftSample;
                *pOutRight++ += rightSample;
            }
        }
        return false;
    }

}
