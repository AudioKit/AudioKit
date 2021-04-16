// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once
#include <math.h>

#include "SampleBuffer.h"
#include "SampleOscillator.h"
#include "ADSREnvelope.h"
#include "AHDSHREnvelope.h"
#include "FunctionTable.h"
#include "ResonantLowPassFilter.h"
#include "LinearRamper.h"

// process samples in "chunks" this size
#define CORESAMPLER_CHUNKSIZE 16 // should probably be set elsewhere - currently only use this for setting up lfo

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
        AHDSHREnvelope ampEnvelope;
        ADSREnvelope filterEnvelope, pitchEnvelope;

        // per-voice vibrato LFO
        FunctionTableOscillator vibratoLFO;

        // restart phase of per-voice vibrato LFO
        bool restartVoiceLFO;

        /// common glide rate, seconds per octave
        float *glideSecPerOctave;

        /// MIDI note number, or -1 if not playing any note
        int noteNumber;

        /// (target) note frequency in Hz
        float noteFrequency;

        /// will reduce to zero during glide
        float glideSemitones;

        /// amount of semitone change via pitch envelope
        float pitchEnvelopeSemitones;

        /// amount of semitone change via voice lfo
        float voiceLFOSemitones;

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

        void updateAmpAdsrParameters() { ampEnvelope.updateParams(); }
        void updateFilterAdsrParameters() { filterEnvelope.updateParams(); }
        void updatePitchAdsrParameters() { pitchEnvelope.updateParams(); }
        
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
                              float resLinear,
                              float pitchADSRSemitones,
                              float voiceLFOFrequencyHz,
                              float voiceLFODepthSemitones);

        bool getSamples(int sampleCount, float *leftOutput, float *rightOutput);

    private:
        bool hasStartedVoiceLFO;
        void restartVoiceLFOIfNeeded();
    };

}
