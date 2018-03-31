//
//  AdjustableDelayLine.cpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AdjustableDelayLine.hpp"

namespace AudioKitCore
{
    AdjustableDelayLine::AdjustableDelayLine() : pBuffer(0)
    {
    }
    
    void AdjustableDelayLine::init(double sampleRate, double maxDelayMs)
    {
        sampleRateHz = sampleRate;
        capacity = int(maxDelayMs * sampleRateHz / 1000.0);
        if (pBuffer) delete[] pBuffer;
        pBuffer = new float[capacity];
        for (int i=0; i < capacity; i++) pBuffer[i] = 0.0f;
        writeIndex = 0;
        readIndex = (float)(capacity - 1);
    }
    
    void AdjustableDelayLine::deinit()
    {
        if (pBuffer) delete[] pBuffer;
        pBuffer = 0;
    }
    
    void AdjustableDelayLine::setDelayMs(double delayMs)
    {
        float fReadWriteGap = float(delayMs * sampleRateHz / 1000.0);
        if (fReadWriteGap < 0.0f) fReadWriteGap = 0.0f;
        if (fReadWriteGap > capacity) fReadWriteGap = (float)capacity;
        readIndex = writeIndex - fReadWriteGap;
        while (readIndex < 0.0f) readIndex += capacity;
    }
    
    void AdjustableDelayLine::setFeedback(float feedback)
    {
        fbFraction = feedback;
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
        
        return outSample;
    }
    
}
