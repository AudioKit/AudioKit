//#include "AKSamplerDefs.h"
#include "AKSamplerVoice.hpp"
#include "AKFunctionTable.hpp"

#include <list>

#define MAX_POLYPHONY 64        // number of voices
#define MIDI_NOTENUMBERS 128    // MIDI offers 128 distinct note numbers
#define CHUNKSIZE 16            // process samples in "chunks" this size

class AKSampler
{
public:
	AKSampler();
	~AKSampler();
				
	int init();		// returns system error code, nonzero only if a problem occurs
	void deinit();

    // call these to load samples
    void loadSampleData(unsigned noteNumber, float noteHz, bool bInterleaved,
                        unsigned nChannelCount, unsigned nSampleCount, float *pData,
                        int min_note=-1, int max_note=-1, int min_vel=-1, int max_vel=-1,
                        bool bLoop=true, float fLoopStart=0.0f, float fLoopEnd=0.0f, float fStart=0.0f, float fEnd=0.0f);
    void loadCompressedSampleFile(unsigned noteNumber, const char* path,
                                  int min_note=-1, int max_note=-1, int min_vel=-1, int max_vel=-1,
                                  bool bLoop=true, float fLoopStart=0.0f, float fLoopEnd=0.0f, float fStart=0.0f, float fEnd=0.0f);
    
    // after loading samples, call one of these to build the key map
    void buildKeyMap(void);         // use this when you have full key mapping data (min/max note, vel)
    void buildSimpleKeyMap(void);   // or this when you don't

    void playNote(unsigned noteNumber, unsigned velocity, float noteHz);
    void stopNote(unsigned noteNumber, bool immediate);
    
    void Render(unsigned channelCount, unsigned sampleCount, float *outBuffers[]);

protected:
    // list of (pointers to) all loaded samples
    std::list<AKMappedSampleBuffer*> sampleBufferList;
    
    // maps MIDI note numbers to "closest" samples (all velocity layers)
    std::list<AKMappedSampleBuffer*> keyMap[MIDI_NOTENUMBERS];
    
    AKSamplerVoice voice[MAX_POLYPHONY];                // table of voice resources
    
    AKFunctionTableOscillator vibratoLFO;               // one vibrato LFO shared by all voices
    
    // simple parameters
    float ampAttackTime, ampDecayTime, ampSustainLevel, ampReleaseTime;
    float filterAttackTime, filterDecayTime, filterSustainLevel, filterReleaseTime;
    bool filterEnable;
    AKEnvelopeGeneratorParams ampEGParams;
    AKEnvelopeGeneratorParams filterEGParams;
    
    // performance parameters
    float masterVolume, pitchOffset, cutoffMultiple;
    
    // helper functions
    void updateAmpADSR();
    void updateFilterADSR();
    AKSamplerVoice* voicePlayingNote(unsigned noteNumber);
    AKMappedSampleBuffer* lookupSample(unsigned noteNumber, unsigned velocity);
};
