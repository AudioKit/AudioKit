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
    : samples(0)
    , channelCount(0)
    , sampleCount(0)
    , startPoint(0.0f)
    , endPoint(0.0f)
    , isLooping(false)
    , loopStartPoint(0.0f)
    , loopEndPoint(0.0f)
    {
    }
    
    SampleBuffer::~SampleBuffer()
    {
        deinit();
    }
    
    void SampleBuffer::init(float sampleRate, int channelCount, int sampleCount)
    {
        this->sampleRate = sampleRate;
        this->sampleCount = sampleCount;
        this->channelCount = channelCount;
        if (samples) delete[] samples;
        samples = new float[channelCount * sampleCount];
        loopStartPoint = startPoint = 0.0f;
        loopEndPoint = endPoint = (float)sampleCount;
    }
    
    void SampleBuffer::deinit()
    {
        if (samples) delete[] samples;
        samples = 0;
    }
    
    void SampleBuffer::setData(unsigned index, float data)
    {
        if ((int)index < channelCount * sampleCount)
        {
            samples[index] = data;
        }
    }
    
}
