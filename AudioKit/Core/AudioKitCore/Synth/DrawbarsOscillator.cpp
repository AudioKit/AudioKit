//
//  DrawbarsOscillator.cpp
//  AudioKit
//
//  Created by Shane Dunne on 2018-04-02.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "DrawbarsOscillator.hpp"
#include <math.h>
#include <stdio.h>

namespace AudioKitCore
{

    // 9 Hammond drawbars mapped to harmonic numbers, minus 1 for a 0-based array
    const int DrawbarsOscillator::drawBarMap[9] = { 0, 2, 1, 3, 5, 7, 9, 11, 15 };

    void DrawbarsOscillator::init(double sampleRate, WaveStack *pStack)
    {
        sampleRateHz = sampleRate;
        pWaveStack = pStack;
        phaseDeltaMultiplier = 1.0f;
        for (int i=0; i < phaseCount; i++)
        {
            phase[i] = phaseDelta[i] = 0.0f;
            safetyLevels[i] = 0.0f;
        }
        level = safetyLevels;
    }

    void DrawbarsOscillator::setFrequency(float frequency)
    {
        // First, compute the normalized base frequency (all we need for one phase)
        double normalizedFrequency = double(frequency) / sampleRateHz;

        // set each phase's normalized frequency
        for (int i=0; i < phaseCount; i++)
        {
            octave[i] = 0;
            phaseDelta[i] = (i + 1) * (float)normalizedFrequency;
            int length = 1 << WaveStack::maxBits;
            while (phaseDelta[i] * length >= 1.0f)
            {
                octave[i]++;
                length >>= 1;
            }

            // frequency components beyond octave 9 must be suppressed
            if (octave[i] >= WaveStack::maxBits)
            {
                octave[i] = 0;
                level[i] = 0.0f;
            }
        }
        //printf("%f Hz oct %d\n", frequency, octave[0]);
    }

    float DrawbarsOscillator::getSample()
    {
        float sample = 0.0f;
        for (int i=0; i < phaseCount; i++)
        {
            if (level[i] == 0.0f) continue;
            sample += level[i] * pWaveStack->interp(octave[i], phase[i]);
            phase[i] += phaseDeltaMultiplier * phaseDelta[i];
            if (phase[i] >= 1.0f) phase[i] -= 1.0f;
        }
        return sample;
    }

    void DrawbarsOscillator::getSamples(float *pLeft, float *pRight, float gain)
    {
        if (gain == 0.0f) return;
        float sample = gain * getSample();
        *pLeft += sample;
        *pRight += sample;
    }
}
