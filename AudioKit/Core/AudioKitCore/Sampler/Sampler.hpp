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

#define MAX_POLYPHONY 64        // number of voices
#define MIDI_NOTENUMBERS 128    // MIDI offers 128 distinct note numbers
#define CHUNKSIZE 16            // process samples in "chunks" this size

namespace AudioKitCore
{
    
    class Sampler
    {
    public:
        Sampler();
        ~Sampler();
        
        int init(double sampleRate);    // returns system error code, nonzero only if a problem occurs
        void deinit();                  // call this to un-load all samples and clear the keymap

        // call before/after loading/unloading samples, to ensure none are in use
        void stopAllVoices();
        void restartVoices();

        // call to load samples
        void loadSampleData(AKSampleDataDescriptor& sdd);
        
        // after loading samples, call one of these to build the key map
        void buildKeyMap(void);         // use this when you have full key mapping data (min/max note, vel)
        void buildSimpleKeyMap(void);   // or this when you don't
        
        // optionally call this to make samples continue looping after note-release
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
        
        SamplerVoice voice[MAX_POLYPHONY];                // table of voice resources
        
        FunctionTableOscillator vibratoLFO;               // one vibrato LFO shared by all voices
        
        SustainPedalLogic pedalLogic;
        
        // simple parameters
        bool isFilterEnabled;
        ADSREnvelopeParameters adsrEnvelopeParameters;
        ADSREnvelopeParameters filterEnvelopeParameters;
        
        // performance parameters
        float masterVolume, pitchOffset, vibratoDepth;

        // per-voice filter parameters
        float cutoffMultiple;   // multiple of note frequency - 1.0 means cutoff at fundamental
        float cutoffEnvelopeStrength; // how much filter EG adds on top of cutoffMultiple
        float linearResonance;        // resonance [-20 dB, +20 dB] becomes linear [10.0, 0.1]
        
        // sample-related parameters
        bool loopThruRelease;   // if true, sample continue looping thru note release phase

        // temporary state
        bool stoppingAllVoices;
        
        // helper functions
        SamplerVoice* voicePlayingNote(unsigned noteNumber);
        KeyMappedSampleBuffer* lookupSample(unsigned noteNumber, unsigned velocity);
        void play(unsigned noteNumber, unsigned velocity, float noteFrequency);
        void stop(unsigned noteNumber, bool immediate);
    };
}
#endif
