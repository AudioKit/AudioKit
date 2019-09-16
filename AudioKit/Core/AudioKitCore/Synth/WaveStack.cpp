//
//  WaveStack.cpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "WaveStack.hpp"
#include "kiss_fftr.h"

namespace AudioKitCore
{

    WaveStack::WaveStack()
    {
        int length = 1 << maxBits;                  // length of level-0 data
        pData[0] = new float[2 * length];           // 2x is enough for all levels
        for (int i=1; i<maxBits; i++)
        {
            pData[i] = pData[i - 1] + length;
            length >>= 1;
        }
    }

    WaveStack::~WaveStack()
    {
        delete[] pData[0];
    }

    void WaveStack::initStack(float *pWaveData, int maxHarmonic)
    {
        // setup
        const int fftLength = 1 << maxBits;
        float *buf = new float[fftLength];
        kiss_fftr_cfg fwd = kiss_fftr_alloc(fftLength, 0, 0, 0);
        kiss_fftr_cfg inv = kiss_fftr_alloc(fftLength, 1, 0, 0);

        // copy supplied wave data for octave 0
        for (int i=0; i < fftLength; i++) pData[0][i] = pWaveData[i];

        // perform initial forward FFT to get spectrum
        kiss_fft_cpx spectrum[fftLength / 2 + 1];
        kiss_fftr(fwd, pData[0], spectrum);

        float scaleFactor = 1.0f / (fftLength / 2);

        for (int octave = (maxHarmonic==512) ? 1 : 0; octave < maxBits; octave++)
        {
            // zero all harmonic coefficients above new Nyquist limit
            int maxHarm = 1 << (maxBits - octave - 1);
            if (maxHarm > maxHarmonic) maxHarm = maxHarmonic;
            for (int h=maxHarm; h <= fftLength/2; h++)
            {
                spectrum[h].r = 0.0f;
                spectrum[h].i = 0.0f;
            }

            // perform inverse FFT to get filtered waveform
            kiss_fftri(inv, spectrum, buf);

            // resample filtered waveform
            int skip = 1 << octave;
            float *pOut = pData[octave];
            for (int i=0; i < fftLength; i += skip) *pOut++ = scaleFactor * buf[i];
        }

        // teardown
        kiss_fftr_free(inv);
        kiss_fftr_free(fwd);
        delete[] buf;
    }

    void WaveStack::init()
    {
    }
    
    void WaveStack::deinit()
    {
    }

    float WaveStack::interp(int octave, float phase)
    {
        while (phase < 0) phase += 1.0;
        while (phase >= 1.0) phase -= 1.0f;

        int nTableSize = 1 << (maxBits - octave);
        float readIndex = phase * nTableSize;
        int ri = int(readIndex);
        float f = readIndex - ri;
        int rj = ri + 1; if (rj >= nTableSize) rj -= nTableSize;

        float *pWaveTable = pData[octave];
        float si = pWaveTable[ri];
        float sj = pWaveTable[rj];
        return (float)((1.0 - f) * si + f * sj);
    }

}

