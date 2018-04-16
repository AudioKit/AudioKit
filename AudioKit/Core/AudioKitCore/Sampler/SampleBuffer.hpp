//
//  SampleBuffer.hpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
namespace AudioKitCore
{

    // SampleBuffer represents an array of sample data, which can be addressed with a real-valued
    // "index" via linear interpolation.
    
    struct SampleBuffer
    {
        float *pSamples;
        float sampleRateHz;
        int nChannelCount;
        int nSampleCount;
        float fStart, fEnd;
        bool bLoop;
        float fLoopStart, fLoopEnd;
        float noteHz;
        
        SampleBuffer();
        ~SampleBuffer();
        
        void init(float sampleRate, int nChannelCount, int sampleCount);
        void deinit();
        
        void setData(unsigned nIndex, float data);
        
        // Use double for the real-valued index, because oscillators will need the extra precision.
        inline float interp(double fIndex, float gain)
        {
            if (pSamples == 0 || nSampleCount == 0) return 0.0f;
            
            int ri = int(fIndex);
            double f = fIndex - ri;
            int rj = ri + 1;
            
            float si = ri < nSampleCount ? pSamples[ri] : 0.0f;
            float sj = rj < nSampleCount ? pSamples[rj] : 0.0f;
            return (float)(gain * ((1.0 - f) * si + f * sj));
        }
        
        inline void interp(double fIndex, float* pOutLeft, float* pOutRight, float gain)
        {
            if (pSamples == 0 || nSampleCount == 0)
            {
                *pOutLeft = *pOutRight = 0.0f;
                return;
            }
            if (nChannelCount == 1)
            {
                *pOutLeft = *pOutRight = interp(fIndex, gain);
                return;
            }
            
            int ri = int(fIndex);
            double f = fIndex - ri;
            int rj = ri + 1;
            
            float si = ri < nSampleCount ? pSamples[ri] : 0.0f;
            float sj = rj < nSampleCount ? pSamples[rj] : 0.0f;
            *pOutLeft = (float)(gain * ((1.0 - f) * si + f * sj));
            si = ri < nSampleCount ? pSamples[nSampleCount + ri] : 0.0f;
            sj = rj < nSampleCount ? pSamples[nSampleCount + rj] : 0.0f;
            *pOutRight = (float)(gain * ((1.0f - f) * si + f * sj));
        }
    };
    
    // KeyMappedSampleBuffer is a derived version with added MIDI note-number and velocity ranges
    struct KeyMappedSampleBuffer : public SampleBuffer
    {
        // Any of these members may be negative, meaning "no value assigned"
        int noteNumber;     // closest MIDI note-number to this sample's frequency (noteHz)
        int min_note, max_note;     // minimum and maximum note numbers for mapping
        int min_vel, max_vel;       // min/max MIDI velocities for mapping
    };

}
