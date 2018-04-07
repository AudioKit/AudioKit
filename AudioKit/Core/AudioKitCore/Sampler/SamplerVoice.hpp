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
        SampleBuffer* pSampleBuffer;      // a pointer to the sample buffer for that oscillator,
        ResonantLowPassFilter filterL, filterR;     // two filters (left/right),
        ADSREnvelope ampEG, filterEG;
        
        int noteNumber;     // MIDI note number, or -1 if not playing any note
        float noteHz;       // note frequency in Hz
        float noteVol;      // fraction 0.0 - 1.0, based on MIDI velocity
        
        // temporary holding variables
        float tempNoteVol;  // holds previous note volume while damping note before restarting
        SampleBuffer* pNewSampleBuffer; // holds next sample buffer to use at restart
        float tempGain;     // product of global volume, note volume, and amp EG
        bool filterEnable;  // true if filter should be used
        
        SamplerVoice() : noteNumber(-1) {}

        void init(double sampleRate);
        
        void start(unsigned noteNum, float sampleRateHz, float freqHz, float volume, SampleBuffer* pSampleBuf);
        void restart(float volume, SampleBuffer* pSampleBuf);
        void release(bool loopThruRelease);
        void stop();
        
        // return true if amp envelope is finished
        bool prepToGetSamples(float masterVol, float pitchOffset,
                              float cutoffMultiple, float cutoffEgStrength, float resLinear);

        bool getSamples(int nSamples, float* pOut);
        bool getSamples(int nSamples, float* pOutLeft, float* pOutRight);
    };

}
