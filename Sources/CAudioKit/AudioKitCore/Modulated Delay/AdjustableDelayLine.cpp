// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AdjustableDelayLine.h"
#include <algorithm>

namespace AudioKitCore
{
    void AdjustableDelayLine::init(double sampleRate, double maxDelayMilliseconds)
    {
        sampleRateHz = sampleRate;
        maxDelayMs = maxDelayMilliseconds;

        buffer.resize(int(maxDelayMs * sampleRateHz / 1000.0));
        clear();
        writeIndex = 0;
        readIndex = (float)(buffer.size() - 1);
        fbFraction = 0.0f;
        output = 0.0f;
    }
    
    void AdjustableDelayLine::deinit()
    {
        buffer.clear();
    }
    
    void AdjustableDelayLine::clear()
    {
        std::fill(buffer.begin(), buffer.end(), 0.0f);
    }
    
    void AdjustableDelayLine::setDelayMs(double delayMs)
    {
        if (delayMs > maxDelayMs) delayMs = maxDelayMs;
        if (delayMs < 0.0f) delayMs = 0.0f;

        size_t capacity = buffer.size();

        float fReadWriteGap = float(delayMs * sampleRateHz / 1000.0);
        if (fReadWriteGap < 0.0f) fReadWriteGap = 0.0f;
        if (fReadWriteGap > capacity) fReadWriteGap = (float)capacity;
        readIndex = writeIndex - fReadWriteGap;
        while (readIndex < 0.0f) readIndex += capacity;
        while (readIndex >= capacity) readIndex -= capacity;
    }
    
    float AdjustableDelayLine::push(float sample)
    {
        if (buffer.empty()) return sample;

        size_t capacity = buffer.size();
        
        int ri = int(readIndex);
        float f = readIndex - ri;
        int rj = ri + 1; if (rj >= capacity) rj -= capacity;
        readIndex += 1.0f;
        if (readIndex >= capacity) readIndex -= capacity;
        
        float si = buffer[ri];
        float sj = buffer[rj];
        float outSample = (1.0f - f) * si + f * sj;
        
        buffer[writeIndex++] = sample + fbFraction * outSample;
        if (writeIndex >= capacity) writeIndex = 0;
        
        return (output = outSample);
    }
    
}
