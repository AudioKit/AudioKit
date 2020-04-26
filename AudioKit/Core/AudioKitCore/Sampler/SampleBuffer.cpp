// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

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
        loopEndPoint = endPoint = (float)(sampleCount - 1);
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
