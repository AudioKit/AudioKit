//
//  AKCoreSynth.hpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#ifdef __cplusplus
#import <memory>

#define AKSYNTH_CHUNKSIZE 16            // process samples in "chunks" this size

namespace AudioKitCore
{
    struct SynthVoice;
}

class AKCoreSynth
{
public:
    AKCoreSynth();
    ~AKCoreSynth();
    
    /// returns system error code, nonzero only if a problem occurs
    int init(double sampleRate);
    
    /// call this to un-load all samples and clear the keymap
    void deinit();
    
    void playNote(unsigned noteNumber, unsigned velocity, float noteFrequency);
    void stopNote(unsigned noteNumber, bool immediate);
    void sustainPedal(bool down);
    
    void  setAmpAttackDurationSeconds(float value);
    float getAmpAttackDurationSeconds(void);
    void  setAmpDecayDurationSeconds(float value);
    float getAmpDecayDurationSeconds(void);
    void  setAmpSustainFraction(float value);
    float getAmpSustainFraction(void);
    void  setAmpReleaseDurationSeconds(float value);
    float getAmpReleaseDurationSeconds(void);
    
    void  setFilterAttackDurationSeconds(float value);
    float getFilterAttackDurationSeconds(void);
    void  setFilterDecayDurationSeconds(float value);
    float getFilterDecayDurationSeconds(void);
    void  setFilterSustainFraction(float value);
    float getFilterSustainFraction(void);
    void  setFilterReleaseDurationSeconds(float value);
    float getFilterReleaseDurationSeconds(void);
    
    void render(unsigned channelCount, unsigned sampleCount, float *outBuffers[]);
    
protected:
 
    struct InternalData;
    std::unique_ptr<InternalData> data;
    
    /// "event" counter for voice-stealing (reallocation)
    unsigned eventCounter;
    
    // performance parameters
    float masterVolume, pitchOffset, vibratoDepth;
    
    // filter parameters
    
    /// multiple of note frequency - 1.0 means cutoff at fundamental
    float cutoffMultiple;
    
    /// how much filter EG adds on top of cutoffMultiple
    float cutoffEnvelopeStrength;
    
    /// resonance [-20 dB, +20 dB] becomes linear [10.0, 0.1]
    float linearResonance;
    
    void play(unsigned noteNumber, unsigned velocity, float noteFrequency);
    void stop(unsigned noteNumber, bool immediate);
    
    AudioKitCore::SynthVoice *voicePlayingNote(unsigned noteNumber);
};

#endif

