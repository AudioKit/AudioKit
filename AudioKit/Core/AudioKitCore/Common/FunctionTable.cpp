//
//  FunctionTable.cpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "FunctionTable.hpp"
#ifndef _USE_MATH_DEFINES
  #define _USE_MATH_DEFINES
#endif
#include <math.h>

namespace AudioKitCore
{

    void FunctionTable::init(int tableLength)
    {
        if (nTableSize == tableLength) return;
        nTableSize = tableLength;
        if (pWaveTable) delete[] pWaveTable;
        pWaveTable = new float[tableLength];
    }
    
    void FunctionTable::deinit()
    {
        if (pWaveTable) delete[] pWaveTable;
        nTableSize = 0;
        pWaveTable = 0;
    }
    
    void FunctionTable::triangle(float amplitude)
    {
        // in case user forgot, init table to size 2
        if (pWaveTable == 0) init(2);
        
        if (nTableSize == 2)   // default 2 elements suffice for a triangle wave
        {
            pWaveTable[0] = -amplitude;
            pWaveTable[1] = amplitude;
        }
        else    // you would normally only do this if you plan to low-pass filter the result
        {
            for (int i=0; i < nTableSize; i++)
                pWaveTable[i] = 2.0f * amplitude * (0.5f - fabsf((float(i)/nTableSize) - 0.5f)) - amplitude;
        }
    }
    
    void FunctionTable::sawtooth(float amplitude)
    {
        // in case user forgot, init table to default size
        if (pWaveTable == 0) init();
        
        for (int i=0; i < nTableSize; i++)
            pWaveTable[i] = (float)(2.0 * amplitude * double(i)/nTableSize - amplitude);
    }
    
    void FunctionTable::sinusoid(float amplitude)
    {
        // in case user forgot, init table to default size
        if (pWaveTable == 0) init();
        
        for (int i=0; i < nTableSize; i++)
            pWaveTable[i] = (float)(amplitude * sin(double(i)/nTableSize * 2.0 * M_PI));
    }

    void FunctionTable::square(float amplitude, float dutyCycle)
    {
        // in case user forgot, init table to default size
        if (pWaveTable == 0) init();

        float dcOffset = amplitude * (2.0f * dutyCycle - 1.0f);
        for (int i=0; i < nTableSize; i++)
        {
            float phase = (float)i / nTableSize;
            pWaveTable[i] = (phase < dutyCycle ? amplitude : -amplitude) - dcOffset;
        }
    }
    
    // Initialize a FunctionTable to an exponential-rise shape, scaled to fit in the unit square.
    // The function itself is y = -exp(-x), where x ranges from 'left' to 'right'.
    // The more negative 'left' is, the more vertical the start of the rise; -5.0 yields near-vertical.
    // The more postitive 'right' is, the more horizontal then end of the rise; +5.0 yields near-horizontal.
    void FunctionTable::exponentialRise(float left, float right)
    {
        // in case user forgot, init table to default size
        if (pWaveTable == 0) init();
        
        float bottom = -expf(-left);
        float top = -expf(-right);
        float vscale = 1.0f / (top - bottom);
        
        float x = left;
        float dx = (right - left) / (nTableSize - 1);
        for (int i=0; i < nTableSize; i++, x += dx)
            pWaveTable[i] = vscale * (-expf(-x) - bottom);
    }
    
    // Initialize a FunctionTable to an exponential-fall shape, scaled to fit in the unit square.
    // The function itself is y = exp(-x), where x ranges from 'left' to 'right'.
    // The more negative 'left' is, the more vertical the start of the fall; -5.0 yields near-vertical.
    // The more postitive 'right' is, the more horizontal then end of the fall; +5.0 yields near-horizontal.
    void FunctionTable::exponentialFall(float left, float right)
    {
        // in case user forgot, init table to default size
        if (pWaveTable == 0) init();
        
        float bottom = expf(-left);
        float top = expf(-right);
        float vscale = 1.0f / (top - bottom);
        
        float x = left;
        float dx = (right - left) / (nTableSize - 1);
        for (int i=0; i < nTableSize; i++, x += dx)
            pWaveTable[i] = vscale * (expf(-x) - bottom);
    }
    
    void FunctionTableOscillator::init(double sampleRate, float frequency, int tableLength)
    {
        waveTable.init(tableLength);
        sampleRateHz = sampleRate;
        phase = 0.0f;
        phaseDelta = (float)(frequency / sampleRate);
    }
    
    void FunctionTableOscillator::deinit()
    {
        waveTable.deinit();
    }
    
    void FunctionTableOscillator::setFrequency(float frequency)
    {
        phaseDelta = (float)(frequency / sampleRateHz);
    }

}

