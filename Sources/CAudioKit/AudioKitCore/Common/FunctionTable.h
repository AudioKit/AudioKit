// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

namespace AudioKitCore
{
    #define DEFAULT_WAVETABLE_SIZE 256

    /// FunctionTable represents a simple one-dimensional table of float values,
    /// addressable by a normalized fractional index, [0.0, 1.0), with or without wraparound.
    /// Linear interpolation is used to interpolate values between available samples.
    ///
    /// Cyclic (wraparound) addressing is useful for creating simple oscillators. In such
    /// cases, the table typically contains one or a few cycles of a periodic function.
    /// See class FunctionTableOscillator.
    ///
    /// Bounded addressing is useful for wave-shaping and fast function-approximation using
    /// tabulated functions. In such applications, the table contains function values over
    /// some bounded domain. See class WaveShaper.
    struct FunctionTable
    {
        float *pWaveTable;
        int nTableSize;
        
        FunctionTable() : pWaveTable(0), nTableSize(0) {}
        ~FunctionTable() { deinit(); }
        
        void init(int tableLength=DEFAULT_WAVETABLE_SIZE);
        void deinit();
        
        // functions for use by class FunctionTableOscillator
        void triangle(float amplitude=1.0f);
        void sawtooth(float amplitude=1.0f);
        void sinusoid(float amplitude=1.0f);
        void hammond(float amplitude=1.0f);
        void square(float amplitude=1.0f, float dutyCycle=0.5f);
        
        inline float interp_cyclic(float phase)
        {
            while (phase < 0) phase += 1.0;
            while (phase >= 1.0) phase -= 1.0f;
            
            float readIndex = phase * nTableSize;
            int ri = int(readIndex);
            float f = readIndex - ri;
            int rj = ri + 1; if (rj >= nTableSize) rj -= nTableSize;
            
            float si = pWaveTable[ri];
            float sj = pWaveTable[rj];
            return (float)((1.0 - f) * si + f * sj);
        }
        
        // functions for use by class WaveShaper (see comments in .cpp file)
        void linearCurve(float gain = 1.0f);
        void exponentialCurve(float left, float right);
        void powerCurve(float exponent);
        
        inline float interp_bounded(float phase)
        {
            if (phase < 0) return pWaveTable[0];
            if (phase >= 1.0) return pWaveTable[nTableSize-1];
            
            float readIndex = phase * (nTableSize - 1);
            int ri = int(readIndex);
            float f = readIndex - ri;
            int rj = ri + 1; if (rj >= nTableSize) rj = nTableSize - 1;
            
            float si = pWaveTable[ri];
            float sj = pWaveTable[rj];
            return (float)((1.0 - f) * si + f * sj);
        }
    };
    
    /// FunctionTableOscillator implements a simple wavetable-based oscillator. Small table sizes (as small
    /// as just 2 samples for triangle-wave) are useful for implementing LFOs using the init* functions.
    /// For audio-frequency oscillators, use larger tables, and ensure that your tabulated waveform is
    /// low-pass filtered. Power-of-two table sizes (e.g. 1024, 2048) are ideal: Perform a forward FFT,
    /// zero out high-frequency coefficients, then inverse FFT.
    struct FunctionTableOscillator
    {
        double sampleRateHz;
        float phase;
        float phaseDelta;   // normalized frequency: cycles per sample
        FunctionTable waveTable;
        
        ~FunctionTableOscillator() { deinit(); }
        void init(double sampleRate, float frequency, int tableLength=DEFAULT_WAVETABLE_SIZE);
        void deinit();
        
        void setFrequency(float frequency);
        
        // For typical LFO applications, we simply get one sample at a time.
        inline float getSample()
        {
            float sample = waveTable.interp_cyclic(phase);
            phase += phaseDelta;
            if (phase >= 1.0f) phase -= 1.0f;
            return sample;
        }

        // For stereo modulation, we need to get two samples at a time: an "in-phase"
        // sample which is the same as what getSample() above would return, plus a
        // "quadrature" sample which is 90 degrees out-of-phase with the first one.
        inline void getSamples(float *pInPhase, float *pQuadrature)
        {
            *pInPhase = waveTable.interp_cyclic(phase);
            *pQuadrature = waveTable.interp_cyclic(phase + 0.25f);
            phase += phaseDelta;
            if (phase >= 1.0f) phase -= 1.0f;
        }
    };
    
    /// WaveShaper wraps a FunctionTable and provides saved scale and offset parameters for both
    /// input (x) and output (y) values.
    struct WaveShaper
    {
        FunctionTable waveTable;
        float xScale, xOffset;
        float yScale, yOffset;
        
        WaveShaper() : xScale(1.0f), xOffset(0.0f), yScale(1.0f), yOffset(0.0f) {}
        ~WaveShaper() { deinit(); }
        void deinit() { waveTable.deinit(); }
        
        void init(int tableLength = DEFAULT_WAVETABLE_SIZE);
        
        inline float interp(float x)
        {
            return yScale * waveTable.interp_bounded((x - xOffset) * xScale) + yOffset;
        }
    };

}
