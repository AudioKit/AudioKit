//
//  DrawbarsOscillator.hpp
//  AudioKit
//
//  Created by Shane Dunne on 2018-04-02.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#include "FunctionTable.hpp"
#include "WaveStack.hpp"

namespace AudioKitCore
{

    // DrawbarsOscillator is WaveStack-based oscillator which implements multiple simultaneous
    // waveform-readout phases, whose frequencies are related as a harmonic series, as in a
    // traditional "drawbar" organ.

    struct DrawbarsOscillator
    {
        // current output sample rate
        double sampleRateHz;

        // pointer to shared WaveStack
        WaveStack *pWaveStack;

        // per-phase variables
        static constexpr int phaseCount = 16;

        // WaveStack octave used by this phase
        int octave[phaseCount];

        // Fraction of the way through waveform
        float phase[phaseCount];

        // normalized frequency: cycles per sample
        float phaseDelta[phaseCount];

        // relative level of each phase (fraction)
        float *level;
        float safetyLevels[phaseCount];

        // performance variables

        // phaseDelta multiplier for pitchbend, vibrato
        float phaseDeltaMultiplier;

        void init(double sampleRate, WaveStack* pStack);
        void setFrequency(float frequency);

        float getSample();
        void getSamples(float *pLeft, float *pRight, float gain);

        // 9 Hammond-like drawbars mapped to level[] indices
        static const int drawBarMap[9];
    };

}
