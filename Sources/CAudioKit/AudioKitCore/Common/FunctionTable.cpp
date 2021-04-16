// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "FunctionTable.h"
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
                pWaveTable[i] = 2.0f * amplitude * (0.25f - fabsf((float(i)/nTableSize) - 0.5f));
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

    // A variation of sinusoid() which adds a tiny bit of 2nd harmonic, producing a tone closer to
    // that of a Hammond organ tonewheel generator.
    void AudioKitCore::FunctionTable::hammond(float amplitude)
    {
        // in case user forgot, init table to default size
        if (pWaveTable == 0) init();

        for (int i = 0; i < nTableSize; i++)
            pWaveTable[i] = (float)(amplitude *
                (sin(double(i) / nTableSize * 2.0 * M_PI) + 0.015f * sin(double(i) / nTableSize * 4.0 * M_PI))
                );
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

    void FunctionTable::linearCurve(float gain)
    {
        // in case user forgot, init table to default size
        if (pWaveTable == 0) init();

        for (int i = 0; i < nTableSize; i++)
            pWaveTable[i] = gain * i / float(nTableSize);
    }
    
    // Initialize a FunctionTable to an exponential shape, scaled to fit in the unit square.
    // The function itself is y = -exp(-x), where x ranges from 'left' to 'right'.
    // The more negative 'left' is, the more vertical the start of the rise; -5.0 yields near-vertical.
    // The more positive 'right' is, the more horizontal then end of the rise; +5.0 yields near-horizontal.
    void FunctionTable::exponentialCurve(float left, float right)
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

    // Initialize a FunctionTable to a power-curve shape, defined in the unit square.
    // The given exponent may be positive for a concave-up shape or negative for concave-down.
    // Typical range of the exponent is plus or minus 4 or 5.
    void FunctionTable::powerCurve(float exponent)
    {
        // in case user forgot, init table to default size
        if (pWaveTable == 0) init();

        float x = 0.0f;
        float dx = 1.0f / (nTableSize - 1);
        for (int i=0; i < nTableSize; i++, x += dx)
            pWaveTable[i] = powf(x, exponent);
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

    // Initialize WaveShaper's lookup table to an identity
    void WaveShaper::init(int tableLength)
    {
        waveTable.init(tableLength);
        for (int i = 0; i < tableLength; i++)
            waveTable.pWaveTable[i] = i / float(tableLength);
    }
}

