//
//  AKFunctionTable.mm
//  ExtendingAudioKit
//
//  Created by Shane Dunne on 2018-02-22.
//  Copyright © 2018 Shane Dunne & Associates. All rights reserved.
//

#include "AKFunctionTable.hpp"
#include <math.h>

void AKFunctionTable::init(int tableLength)
{
    if (nTableSize == tableLength) return;
    nTableSize = tableLength;
    if (pWaveTable) delete[] pWaveTable;
    pWaveTable = new float[tableLength];
}

void AKFunctionTable::deinit()
{
    if (pWaveTable) delete[] pWaveTable;
    pWaveTable = 0;
}

void AKFunctionTable::triangle()
{
    // in case user forgot, init table to size 2
    if (pWaveTable == 0) init(2);

    if (nTableSize == 2)   // default 2 elements suffice for a triangle wave
    {
        pWaveTable[0] = -1.0f;
        pWaveTable[1] = 1.0f;
    }
    else    // you would normally only do this if you plan to low-pass filter the result
    {
        for (int i=0; i < nTableSize; i++)
            pWaveTable[i] = 2.0f * (0.5f - fabs((float(i)/nTableSize) - 0.5f)) - 1.0f;
    }
}

void AKFunctionTable::sawtooth()
{
    // in case user forgot, init table to default size
    if (pWaveTable == 0) init();
    
    for (int i=0; i < nTableSize; i++)
        pWaveTable[i] = (float)(2.0 * double(i)/nTableSize - 1.0);
}

void AKFunctionTable::sinusoid()
{
    // in case user forgot, init table to default size
    if (pWaveTable == 0) init();
    
    for (int i=0; i < nTableSize; i++)
        pWaveTable[i] = (float)(sin(double(i)/nTableSize * 2.0 * M_PI));
}


// Initialize a AKFunctionTable to an exponential-rise shape, scaled to fit in the unit square.
// The function itself is y = -exp(-x), where x ranges from 'left' to 'right'.
// The more negative 'left' is, the more vertical the start of the rise; -5.0 yields near-vertical.
// The more postitive 'right' is, the more horizontal then end of the rise; +5.0 yields near-horizontal.
void AKFunctionTable::exponentialRise(float left, float right)
{
    // in case user forgot, init table to default size
    if (pWaveTable == 0) init();
    
    float bottom = -exp(-left);
    float top = -exp(-right);
    float vscale = 1.0f / (top - bottom);
    
    float x = left;
    float dx = (right - left) / (nTableSize - 1);
    for (int i=0; i < nTableSize; i++, x += dx)
        pWaveTable[i] = vscale * (-exp(-x) - bottom);
}

// Initialize a AKFunctionTable to an exponential-fall shape, scaled to fit in the unit square.
// The function itself is y = exp(-x), where x ranges from 'left' to 'right'.
// The more negative 'left' is, the more vertical the start of the fall; -5.0 yields near-vertical.
// The more postitive 'right' is, the more horizontal then end of the fall; +5.0 yields near-horizontal.
void AKFunctionTable::exponentialFall(float left, float right)
{
    // in case user forgot, init table to default size
    if (pWaveTable == 0) init();
    
    float bottom = exp(-left);
    float top = exp(-right);
    float vscale = 1.0f / (top - bottom);
    
    float x = left;
    float dx = (right - left) / (nTableSize - 1);
    for (int i=0; i < nTableSize; i++, x += dx)
        pWaveTable[i] = vscale * (exp(-x) - bottom);
}


void AKFunctionTableOscillator::init(double sampleRate, float frequency)
{
    sampleRateHz = sampleRate;
    phase = 0.0f;
    phaseDelta = frequency / sampleRate;
}

void AKFunctionTableOscillator::deinit()
{
    waveTable.deinit();
}

void AKFunctionTableOscillator::setFrequency(float frequency)
{
    phaseDelta = frequency / sampleRateHz;
}
