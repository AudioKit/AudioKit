// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once
namespace AudioKitCore
{

    // SampleBuffer represents an array of sample data, which can be addressed with a real-valued
    // "index" via linear interpolation.
    
    struct SampleBuffer
    {
        float *samples;
        float sampleRate;
        int channelCount;
        int sampleCount;
        float startPoint, endPoint;
        bool isLooping;
        float loopStartPoint, loopEndPoint;
        float noteFrequency;
        
        SampleBuffer();
        ~SampleBuffer();
        
        void init(float sampleRate, int channelCount, int sampleCount);
        void deinit();
        
        void setData(unsigned index, float data);
        
        // Use double for the real-valued index, because oscillators will need the extra precision.
        inline float interp(double fIndex, float gain)
        {
            if (samples == 0 || sampleCount == 0) return 0.0f;
            
            int ri = int(fIndex);
            double f = fIndex - ri;
            int rj = ri + 1;
            
            float si = ri < sampleCount ? samples[ri] : 0.0f;
            float sj = rj < sampleCount ? samples[rj] : 0.0f;
            return (float)(gain * ((1.0 - f) * si + f * sj));
        }
        
        inline void interp(double fIndex, float *leftOutput, float *rightOutput, float gain)
        {
            if (samples == 0 || sampleCount == 0)
            {
                *leftOutput = *rightOutput = 0.0f;
                return;
            }
            if (channelCount == 1)
            {
                *leftOutput = *rightOutput = interp(fIndex, gain);
                return;
            }
            
            int ri = int(fIndex);
            double f = fIndex - ri;
            int rj = ri + 1;
            
            float si = ri < sampleCount ? samples[ri] : 0.0f;
            float sj = rj < sampleCount ? samples[rj] : 0.0f;
            *leftOutput = (float)(gain * ((1.0 - f) * si + f * sj));
            si = ri < sampleCount ? samples[sampleCount + ri] : 0.0f;
            sj = rj < sampleCount ? samples[sampleCount + rj] : 0.0f;
            *rightOutput = (float)(gain * ((1.0f - f) * si + f * sj));
        }
    };
    
    // KeyMappedSampleBuffer is a derived version with added MIDI note-number and velocity ranges
    struct KeyMappedSampleBuffer : public SampleBuffer
    {
        // Any of these members may be negative, meaning "no value assigned"
        int noteNumber;     // closest MIDI note-number to this sample's frequency (noteFrequency)
        int minimumNoteNumber, maximumNoteNumber;     // bounding note numbers for mapping
        int minimumVelocity, maximumVelocity;       // min/max MIDI velocities for mapping
    };

}
