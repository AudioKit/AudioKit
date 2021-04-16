// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AdjustableDelayLine.h"

namespace AudioKitCore
{
    AdjustableDelayLine::AdjustableDelayLine() : pBuffer(0)
    {
    }
    
    void AdjustableDelayLine::init(double sampleRate, double maxDelayMilliseconds)
    {
        sampleRateHz = sampleRate;
        maxDelayMs = maxDelayMilliseconds;

        capacity = int(maxDelayMs * sampleRateHz / 1000.0);
        if (pBuffer) delete[] pBuffer;
        pBuffer = new float[capacity];
        clear();
        writeIndex = 0;
        readIndex = (float)(capacity - 1);
        fbFraction = 0.0f;
        output = 0.0f;
    }
    
    void AdjustableDelayLine::deinit()
    {
        if (pBuffer) delete[] pBuffer;
        pBuffer = 0;
    }
    
    void AdjustableDelayLine::clear()
    {
        for (int i=0; i < capacity; i++) pBuffer[i] = 0.0f;
    }
    
    void AdjustableDelayLine::setDelayMs(double delayMs)
    {
        if (delayMs > maxDelayMs) delayMs = maxDelayMs;
        if (delayMs < 0.0f) delayMs = 0.0f;

        float fReadWriteGap = float(delayMs * sampleRateHz / 1000.0);
        if (fReadWriteGap < 0.0f) fReadWriteGap = 0.0f;
        if (fReadWriteGap > capacity) fReadWriteGap = (float)capacity;
        readIndex = writeIndex - fReadWriteGap;
        while (readIndex < 0.0f) readIndex += capacity;
        while (readIndex >= capacity) readIndex -= capacity;
    }
    
    float AdjustableDelayLine::push(float sample)
    {
        if (!pBuffer) return sample;
        
        int ri = int(readIndex);
        float f = readIndex - ri;
        int rj = ri + 1; if (rj >= capacity) rj -= capacity;
        readIndex += 1.0f;
        if (readIndex >= capacity) readIndex -= capacity;
        
        float si = pBuffer[ri];
        float sj = pBuffer[rj];
        float outSample = (1.0f - f) * si + f * sj;
        
        pBuffer[writeIndex++] = sample + fbFraction * outSample;
        if (writeIndex >= capacity) writeIndex = 0;
        
        return (output = outSample);
    }
    
}
