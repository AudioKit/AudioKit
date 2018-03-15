//
//  Sampler.hpp
//  AudioKit Core
//
//  Created by Shane Dunne on 2018-02-21.
//  Copyright © 2018 AudioKit. All rights reserved.
//

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
        
        // call these to load samples
        void loadSampleData(AKSampleDataDescriptor& sdd);
#ifndef WIN32
        void loadCompressedSampleFile(AKSampleFileDescriptor& sfd);
#endif
        
        // after loading samples, call one of these to build the key map
        void buildKeyMap(void);         // use this when you have full key mapping data (min/max note, vel)
        void buildSimpleKeyMap(void);   // or this when you don't
        
        void playNote(unsigned noteNumber, unsigned velocity, float noteHz);
        void stopNote(unsigned noteNumber, bool immediate);
        void sustainPedal(bool down);
        
        void Render(unsigned channelCount, unsigned sampleCount, float *outBuffers[]);
        
    protected:
        // current sampling rate, samples/sec
        float sampleRateHz;
        
        // list of (pointers to) all loaded samples
        std::list<KeyMappedSampleBuffer*> sampleBufferList;
        
        // maps MIDI note numbers to "closest" samples (all velocity layers)
        std::list<KeyMappedSampleBuffer*> keyMap[MIDI_NOTENUMBERS];
        
        SamplerVoice voice[MAX_POLYPHONY];                // table of voice resources
        
        FunctionTableOscillator vibratoLFO;               // one vibrato LFO shared by all voices
        
        SustainPedalLogic pedalLogic;
        
        // simple parameters
        //float ampAttackTime, ampDecayTime, ampSustainLevel, ampReleaseTime;
        //float filterAttackTime, filterDecayTime, filterSustainLevel, filterReleaseTime;
        bool filterEnable;
        ADSREnvelopeParams ampEGParams;
        ADSREnvelopeParams filterEGParams;
        
        // performance parameters
        float masterVolume, pitchOffset, vibratoDepth, cutoffMultiple, resonanceDb;
        
        // helper functions
        SamplerVoice* voicePlayingNote(unsigned noteNumber);
        KeyMappedSampleBuffer* lookupSample(unsigned noteNumber, unsigned velocity);
        void play(unsigned noteNumber, unsigned velocity, float noteHz);
        void stop(unsigned noteNumber, bool immediate);
    };
}

