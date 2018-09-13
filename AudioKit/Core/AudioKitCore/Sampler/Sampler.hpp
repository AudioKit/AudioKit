//
//  Sampler.hpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#ifdef __cplusplus
#include "AKSampler_Typedefs.h"
#include "SamplerVoice.hpp"
#include "FunctionTable.hpp"
#include "SustainPedalLogic.hpp"

#include <list>

// number of voices
#define MAX_POLYPHONY 64

// MIDI offers 128 distinct note numbers
#define MIDI_NOTENUMBERS 128

// process samples in "chunks" this size
#define CHUNKSIZE 16

namespace AudioKitCore
{
    
    class Sampler
    {
    public:
        Sampler();
        ~Sampler();

        /// returns system error code, nonzero only if a problem occurs
        int init(double sampleRate);

        /// call this to un-load all samples and clear the keymap
        void deinit();

        /// call before/after loading/unloading samples, to ensure none are in use
        void stopAllVoices();
        void restartVoices();

        /// call to load samples
        void loadSampleData(AKSampleDataDescriptor& sdd);
        
        // after loading samples, call one of these to build the key map

        /// use this when you have full key mapping data (min/max note, vel)
        void buildKeyMap(void);

        /// use this when you don't have full key mapping data (min/max note, vel)
        void buildSimpleKeyMap(void);
        
        /// optionally call this to make samples continue looping after note-release
        void setLoopThruRelease(bool value) { loopThruRelease = value; }
        
        void playNote(unsigned noteNumber, unsigned velocity, float noteFrequency);
        void stopNote(unsigned noteNumber, bool immediate);
        void sustainPedal(bool down);
        
        void render(unsigned channelCount, unsigned sampleCount, float *outBuffers[]);
        
    protected:
        // current sampling rate, samples/sec
        float sampleRate;
        
        // list of (pointers to) all loaded samples
        std::list<KeyMappedSampleBuffer*> sampleBufferList;
        
        // maps MIDI note numbers to "closest" samples (all velocity layers)
        std::list<KeyMappedSampleBuffer*> keyMap[MIDI_NOTENUMBERS];
        bool isKeyMapValid;

        // table of voice resources
        SamplerVoice voice[MAX_POLYPHONY];

        // one vibrato LFO shared by all voices
        FunctionTableOscillator vibratoLFO;
        
        SustainPedalLogic pedalLogic;
        
        // simple parameters
        bool isFilterEnabled;
        ADSREnvelopeParameters adsrEnvelopeParameters;
        ADSREnvelopeParameters filterEnvelopeParameters;
        
        // performance parameters
        float masterVolume, pitchOffset, vibratoDepth, glideRate;

        // parameters for mono-mode only

        // default false
        bool isMonophonic;

        // true if notes shouldn't retrigger in mono mode
        bool isLegato;

        // semitones/sec
        float portamentoRate;

        // mono-mode state
        unsigned lastPlayedNoteNumber;
        float lastPlayedNoteFrequency;

        // per-voice filter parameters

        // multiple of note frequency - 1.0 means cutoff at fundamental
        float cutoffMultiple;

        // how much filter EG adds on top of cutoffMultiple
        float cutoffEnvelopeStrength;

        // resonance [-20 dB, +20 dB] becomes linear [10.0, 0.1]
        float linearResonance;
        
        // sample-related parameters

        // if true, sample continue looping thru note release phase
        bool loopThruRelease;

        // temporary state
        bool stoppingAllVoices;
        
        // helper functions
        SamplerVoice *voicePlayingNote(unsigned noteNumber);
        KeyMappedSampleBuffer *lookupSample(unsigned noteNumber, unsigned velocity);
        void play(unsigned noteNumber,
                  unsigned velocity,
                  float noteFrequency,
                  bool anotherKeyWasDown);
        void stop(unsigned noteNumber, bool immediate);
    };
}
#endif
