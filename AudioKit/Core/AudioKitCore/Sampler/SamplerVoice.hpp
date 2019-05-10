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
#include "LinearRamper.hpp"

namespace AudioKitCore
{

    struct SamplerVoice
    {
        float samplingRate;
        /// every voice has 1 oscillator
        SampleOscillator oscillator;

        /// a pointer to the sample buffer for that oscillator
        SampleBuffer *sampleBuffer;

        /// two filters (left/right)
        ResonantLowPassFilter leftFilter, rightFilter;
        ADSREnvelope adsrEnvelope, filterEnvelope;

        /// common glide rate, seconds per octave
        float *glideSecPerOctave;

        /// MIDI note number, or -1 if not playing any note
        int noteNumber;

        /// (target) note frequency in Hz
        float noteFrequency;

        /// will reduce to zero during glide
        float glideSemitones;

        /// fraction 0.0 - 1.0, based on MIDI velocity
        float noteVolume;

        // temporary holding variables

        /// Previous note volume while damping note before restarting
        float tempNoteVolume;

        /// Next sample buffer to use at restart
        SampleBuffer *newSampleBuffer;

        /// product of global volume, note volume
        float tempGain;

        /// ramper to smooth subsampled output of adsrEnvelope
        LinearRamper volumeRamper;

        /// true if filter should be used
        bool isFilterEnabled;
        
        SamplerVoice() : noteNumber(-1) {}

        void init(double sampleRate);

        void updateAmpAdsrParameters() { adsrEnvelope.updateParams(); }
        void updateFilterAdsrParameters() { filterEnvelope.updateParams(); }
        
        void start(unsigned noteNumber,
                   float sampleRate,
                   float frequency,
                   float volume,
                   SampleBuffer *sampleBuffer);
        void restartNewNote(unsigned noteNumber, float sampleRate, float frequency, float volume, SampleBuffer *buffer);
        void restartNewNoteLegato(unsigned noteNumber, float sampleRate, float frequency);
        void restartSameNote(float volume, SampleBuffer *sampleBuffer);
        void release(bool loopThruRelease);
        void stop();
        
        // return true if amp envelope is finished
        bool prepToGetSamples(int sampleCount,
                              float masterVolume,
                              float pitchOffset,
                              float cutoffMultiple,
                              float keyTracking,
                              float cutoffEnvelopeStrength,
                              float cutoffEnvelopeVelocityScaling,
                              float resLinear);

        bool getSamples(int sampleCount, float *leftOutput, float *rightOutput);
    };

}
