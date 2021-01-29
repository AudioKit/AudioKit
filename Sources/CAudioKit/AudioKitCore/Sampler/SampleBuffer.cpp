// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SampleBuffer.hpp"

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
