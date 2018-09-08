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
        double sampleRateHz;            // current output sample rate
        WaveStack *pWaveStack;          // pointer to shared WaveStack

        // per-phase variables
        static constexpr int numPhases = 16;
        int octave[numPhases];          // WaveStack octave used by this phase
        float phase[numPhases];         // Fraction of the way through waveform
        float phaseDelta[numPhases];    // normalized frequency: cycles per sample
        float level[numPhases];         // relative level of this phase (fraction)

        // performance variables
        float phaseDeltaMul;            // phaseDelta multiplier for pitchbend, vibrato

        void init(double sampleRate, WaveStack* pStack);
        void setDrawbars(float levels[]);
        void setFrequency(float frequency);

        float getSample();
        void getSamples(float *pLeft, float *pRight, float gain);
    };

}
