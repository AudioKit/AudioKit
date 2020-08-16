// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once
#include <math.h>

#include "EnsembleOscillator.hpp"
#include "DrawbarsOscillator.hpp"
#include "ADSREnvelope.hpp"
#include "Envelope.hpp"
#include "MultiStageFilter.hpp"

namespace AudioKitCore
{

    struct SynthOscParameters
    {
        int phases;             // 1 to 10, or 0 to disable oscillator
        float frequencySpread;  // cents
        float panSpread;        // fraction 0 = no spread, 1 = max spread
        float pitchOffset;      // semitones, relative to MIDI note
        float mixLevel;         // fraction
    };

    struct OrganParameters
    {
        float drawbars[DrawbarsOscillator::phaseCount];
        float mixLevel;
    };

    struct SynthVoiceParameters
    {
        SynthOscParameters osc1, osc2;
        OrganParameters osc3;
        /// 1 to 4, or 0 to disable filter
        int filterStages;
    };

    struct SynthVoice
    {
        SynthVoiceParameters *pParameters;

        EnsembleOscillator osc1, osc2;
        DrawbarsOscillator osc3;
        MultiStageFilter leftFilter, rightFilter;            // two filters (left/right)
        ADSREnvelope ampEG, filterEG;
        Envelope pumpEG;

        unsigned event;     // last "event number" associated with this voice
        int noteNumber;     // MIDI note number, or -1 if not playing any note
        float noteFrequency;// note frequency in Hz
        float noteVolume;      // fraction 0.0 - 1.0, based on MIDI velocity
        
        // temporary holding variables
        int newNoteNumber;  // holds new note number while damping note before restarting
        float newNoteVol;   // holds new note volume while damping note before restarting
        float tempGain;     // product of global volume, note volume, and amp EG

        SynthVoice() : noteNumber(-1) {}

        void init(double sampleRate,
                  WaveStack *pOsc1Stack,
                  WaveStack *pOsc2Stack,
                  WaveStack *pOsc3Stack,
                  SynthVoiceParameters *pParameters,
                  EnvelopeParameters *pEnvParameters);
        
        void updateAmpAdsrParameters() { ampEG.updateParams(); }
        void updateFilterAdsrParameters() { filterEG.updateParams(); }
        
        void start(unsigned evt, unsigned noteNumber, float frequency, float volume);
        void restart(unsigned evt, float volume);
        void restart(unsigned evt, unsigned noteNumber, float frequency, float volume);
        void release(unsigned evt);
        void stop(unsigned evt);
        
        // return true if amp envelope is finished
        bool prepToGetSamples(float masterVol,
                              float phaseDeltaMultiplier,
                              float cutoffMultiple,
                              float cutoffStrength,
                              float resLinear);
        bool getSamples(int sampleCount, float *leftOuput, float *rightOutput);
    };

}
