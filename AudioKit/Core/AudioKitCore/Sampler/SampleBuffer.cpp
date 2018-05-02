//
//  SampleBuffer.cpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "SampleBuffer.hpp"

namespace AudioKitCore
{

    SampleBuffer::SampleBuffer()
    : pSamples(0)
    , nChannelCount(0)
    , nSampleCount(0)
    , startPoint(0.0f)
    , endPoint(0.0f)
    , bLoop(false)
    , loopStartPoint(0.0f)
    , loopEndPoint(0.0f)
    {
    }
    
    SampleBuffer::~SampleBuffer()
    {
        deinit();
    }
    
    void SampleBuffer::init(float sampleRate, int nChannelCount, int nSampleCount)
    {
        this->sampleRateHz = sampleRate;
        this->nSampleCount = nSampleCount;
        this->nChannelCount = nChannelCount;
        if (pSamples) delete[] pSamples;
        pSamples = new float[nChannelCount * nSampleCount];
        loopStartPoint = startPoint = 0.0f;
        loopEndPoint = endPoint = (float)nSampleCount;
    }
    
    void SampleBuffer::deinit()
    {
        if (pSamples) delete[] pSamples;
        pSamples = 0;
    }
    
    void SampleBuffer::setData(unsigned nIndex, float data)
    {
        if ((int)nIndex < nChannelCount * nSampleCount)
        {
            pSamples[nIndex] = data;
        }
    }
    
}
