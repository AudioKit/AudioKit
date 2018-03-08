//
//  SamplerVoice.cpp
//  AudioKit Core
//
//  Created by Shane Dunne on 2018-02-24.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "SamplerVoice.hpp"
#include <stdio.h>

namespace AudioKitCore
{
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
        filterEG.start(true);
        
        noteHz = freqHz;
        noteNumber = noteNum;
    }
    
    void SamplerVoice::restart(float volume)
    {
        oscillator.fIndex = pSampleBuffer->fStart;
        oscillator.bLooping = pSampleBuffer->bLoop;
        noteVol = volume;
        ampEG.start();
        filterEG.start(true);
    }
    
    void SamplerVoice::release()
    {
        oscillator.bLooping = false;
        ampEG.release();
        filterEG.release();
    }
    
    void SamplerVoice::stop()
    {
        noteNumber = -1;
        ampEG.reset();
        filterEG.reset();
    }
    
    bool SamplerVoice::prepToGetSamples(float masterVol, float pitchOffset, float cutoffMultiple)
    {
        if (ampEG.isIdle()) return true;
        
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
            
            double cutoffHz = noteHz * (1.0f + cutoffMultiple * filterEG.getSample());
            
            // TESTING ONLY
            double resonanceDb = 6.0;
            
            filterL.setParams(cutoffHz, resonanceDb); //setCutoff(cutoffHz);
            filterR.setParams(cutoffHz, resonanceDb); //setCutoff(cutoffHz);
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
