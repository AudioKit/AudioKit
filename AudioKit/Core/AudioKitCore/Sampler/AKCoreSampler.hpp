//
//  Sampler.hpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#ifdef __cplusplus
#ifdef _WIN32
#include "AKSampler_Typedefs.h"
#include <memory>
#else
#import "AKSampler_Typedefs.h"
#import <memory>
#endif

// process samples in "chunks" this size
#define AKCORESAMPLER_CHUNKSIZE 16


namespace AudioKitCore {
    struct SamplerVoice;
    struct KeyMappedSampleBuffer;
}

class AKCoreSampler
{
public:
    AKCoreSampler();
    ~AKCoreSampler();
    
    /// returns system error code, nonzero only if a problem occurs
    int init(double sampleRate);
    
    /// call this to un-load all samples and clear the keymap
    void deinit();
    
    /// call before/after loading/unloading samples, to ensure none are in use
    void stopAllVoices();
    void restartVoices();
    
    /// call to load samples
    void loadSampleData(AKSampleDataDescriptor& sdd);

    /// call to unload samples, freeing memory
    void unloadAllSamples();
    
    // after loading samples, call one of these to build the key map
    
    /// call for noteNumber 0-127 to define tuning table (defaults to standard 12-tone equal temperament)
    void setNoteFrequency(int noteNumber, float noteFrequency);
    
    /// use this when you have full key mapping data (min/max note, vel)
    void buildKeyMap(void);
    
    /// use this when you don't have full key mapping data (min/max note, vel)
    void buildSimpleKeyMap(void);
    
    /// optionally call this to make samples continue looping after note-release
    void setLoopThruRelease(bool value) { loopThruRelease = value; }
    
    void playNote(unsigned noteNumber, unsigned velocity);
    void stopNote(unsigned noteNumber, bool immediate);
    void sustainPedal(bool down);
    
    void render(unsigned channelCount, unsigned sampleCount, float *outBuffers[]);
    
    void  setADSRAttackDurationSeconds(float value);
    float getADSRAttackDurationSeconds(void);
    void  setADSRDecayDurationSeconds(float value);
    float getADSRDecayDurationSeconds(void);
    void  setADSRSustainFraction(float value);
    float getADSRSustainFraction(void);
    void  setADSRReleaseDurationSeconds(float value);
    float getADSRReleaseDurationSeconds(void);

    void  setFilterAttackDurationSeconds(float value);
    float getFilterAttackDurationSeconds(void);
    void  setFilterDecayDurationSeconds(float value);
    float getFilterDecayDurationSeconds(void);
    void  setFilterSustainFraction(float value);
    float getFilterSustainFraction(void);
    void  setFilterReleaseDurationSeconds(float value);
    float getFilterReleaseDurationSeconds(void);

    void  setPitchAttackDurationSeconds(float value);
    float getPitchAttackDurationSeconds(void);
    void  setPitchDecayDurationSeconds(float value);
    float getPitchDecayDurationSeconds(void);
    void  setPitchSustainFraction(float value);
    float getPitchSustainFraction(void);
    void  setPitchReleaseDurationSeconds(float value);
    float getPitchReleaseDurationSeconds(void);
    
protected:
    // current sampling rate, samples/sec
    // not named sampleRate to avoid clashing with AudioKit's sampleRate
    float currentSampleRate;
    
    struct InternalData;
    std::unique_ptr<InternalData> data;
    
    bool isKeyMapValid;
    
    // simple parameters
    bool isFilterEnabled;
    
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

    // key tracking factor: 1.0 means perfect key tracking, 0.0 means none; may be e.g. -2.0 to +2.0
    float keyTracking;
    
    // how much filter EG adds on top of cutoffMultiple
    float cutoffEnvelopeStrength;
    
    /// fraction 0.0 - 1.0, scaling note volume's effect on cutoffEnvelopeStrength
    float filterEnvelopeVelocityScaling;

    // resonance [-20 dB, +20 dB] becomes linear [10.0, 0.1]
    float linearResonance;

    // how much pitch ADSR adds on top of pitch
    float pitchADSRSemitones;
    
    // sample-related parameters
    
    // if true, sample continue looping thru note release phase
    bool loopThruRelease;
    
    // temporary state
    bool stoppingAllVoices;
    
    // helper functions
    AudioKitCore::SamplerVoice *voicePlayingNote(unsigned noteNumber);
    AudioKitCore::KeyMappedSampleBuffer *lookupSample(unsigned noteNumber, unsigned velocity);
    void play(unsigned noteNumber,
              unsigned velocity,
              bool anotherKeyWasDown);
    void stop(unsigned noteNumber, bool immediate);
};

#endif
