//
//  SamplerVoice.hpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
#include <math.h>

#include "SampleBuffer.hpp"
#include "SampleOscillator.hpp"
#include "ADSREnvelope.hpp"
#include "ResonantLowPassFilter.hpp"

namespace AudioKitCore
{

    struct SamplerVoice
    {
        SampleOscillator oscillator;      // every voice has 1 oscillator,
        SampleBuffer* sampleBuffer;      // a pointer to the sample buffer for that oscillator,
        ResonantLowPassFilter leftFilter, rightFilter;     // two filters (left/right),
        ADSREnvelope adsrEnvelope, filterEnvelope;
        
        int noteNumber;     // MIDI note number, or -1 if not playing any note
        float noteFrequency;// note frequency in Hz
        float noteVolume;      // fraction 0.0 - 1.0, based on MIDI velocity
        
        // temporary holding variables
        float tempNoteVolume;  // holds previous note volume while damping note before restarting
        SampleBuffer* newSampleBuffer; // holds next sample buffer to use at restart
        float tempGain;     // product of global volume, note volume, and amp EG
        bool isFilterEnabled;  // true if filter should be used
        
        SamplerVoice() : noteNumber(-1) {}

        void init(double sampleRate);
        
        void start(unsigned noteNumber, float sampleRate, float frequency, float volume, SampleBuffer* sampleBuffer);
        void restart(float volume, SampleBuffer* sampleBuffer);
        void release(bool loopThruRelease);
        void stop();
        
        // return true if amp envelope is finished
        bool prepToGetSamples(float masterVolume, float pitchOffset,
                              float cutoffMultiple, float cutoffEnvelopeStrength, float resLinear);

        bool getSamples(int sampleCount, float* output);
        bool getSamples(int sampleCount, float* leftOutput, float* rightOutput);
    };

}
