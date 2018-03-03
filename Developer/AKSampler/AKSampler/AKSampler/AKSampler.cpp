#include "AKSampler.h"
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

AKSampler::AKSampler()
: filterEnable(false)
, masterVolume(1.0f)
, pitchOffset(0.0f)
, cutoffMultiple(30.0f)
{
    for (int i=0; i < MAX_POLYPHONY; i++)
    {
        voice[i].ampEG.pParams = &ampEGParams;
        voice[i].filterEG.pParams = &filterEGParams;
    }
}

AKSampler::~AKSampler()
{
}

int AKSampler::init()
{	
    double sampleRate = 44100.0;	// preliminary guess
    
    ampEGParams.updateSampleRate((float)(sampleRate/CHUNKSIZE));
    filterEGParams.updateSampleRate((float)(sampleRate/CHUNKSIZE));
    vibratoLFO.waveTable.sinusoid();
    vibratoLFO.init(sampleRate/CHUNKSIZE, 5.0f);
    
    return 0;   // no error
}

void AKSampler::deinit()
{
    for (std::list<AKMappedSampleBuffer*>::iterator it=sampleBufferList.begin();
         it != sampleBufferList.end();
         ++it)
        delete *it;
    sampleBufferList.clear();
    for (int i=0; i < MIDI_NOTENUMBERS; i++) keyMap[i].clear();
}

// Wavpack interface
extern "C" int getWvData (int ifd, int* pNumChannels, int* pNumSamples);
extern "C" int getWvSamples (int ifd, float* pSampleBuffer);

void AKSampler::loadCompressedSampleFile(unsigned noteNumber, const char* path,
                                         int min_note, int max_note, int min_vel, int max_vel,
                                         bool bLoop, float fLoopStart, float fLoopEnd, float fStart, float fEnd)
{
    //printf("loadCompressedSampleFile: %d %s\n", noteNumber, path);
    
    int ifd = open(path, O_RDONLY);
    if (ifd < 0)
    {
        printf("Error %d opening %s\n", errno, path);
        return;
    }
    
    int numChannels, numSamples;
    int check = getWvData(ifd, &numChannels, &numSamples);
    close(ifd);
    if (check != 0)
    {
        printf("getWvData returns %d for %s\n", check, path);
        return;
    }
    
    ifd = open(path, O_RDONLY);
    float* pSampleBuffer = new float[numChannels * numSamples];
    check = getWvSamples(ifd, pSampleBuffer);
    close(ifd);

    float noteHz = 440.0f * pow(2.0f, (noteNumber - 69.0f)/12.0f);
    loadSampleData(noteNumber, noteHz, true, numChannels, numSamples, pSampleBuffer,
                   min_note, max_note, min_vel, max_vel,
                   bLoop, fLoopStart, fLoopEnd, fStart, fEnd);
    delete[] pSampleBuffer;
}

void AKSampler::loadSampleData(unsigned noteNumber, float noteHz, bool bInterleaved,
                               unsigned nChannelCount, unsigned nSampleCount, float *pData,
                               int min_note, int max_note, int min_vel, int max_vel,
                               bool bLoop, float fLoopStart, float fLoopEnd, float fStart, float fEnd)
{
    AKMappedSampleBuffer* pBuf = new AKMappedSampleBuffer();
    pBuf->min_note = min_note;
    pBuf->max_note = max_note;
    pBuf->min_vel = min_vel;
    pBuf->max_vel = max_vel;
    sampleBufferList.push_back(pBuf);

    pBuf->init(nChannelCount, nSampleCount);
    if (bInterleaved) for (unsigned i=0; i < nSampleCount; i++)
    {
        pBuf->setData(i, *pData++);
        if (nChannelCount > 1) pBuf->setData(nSampleCount + i, *pData++);
    }
    else for (unsigned i=0; i < nChannelCount * nSampleCount; i++)
    {
        pBuf->setData(i, *pData++);
    }
    pBuf->noteNumber = noteNumber;
    pBuf->noteHz = noteHz;
    
    if (fStart > 0.0f) pBuf->fStart = fStart;
    if (fEnd > 0.0f)   pBuf->fEnd = fEnd;
    
    pBuf->bLoop = bLoop;
    if (fLoopStart > 0.0f)
        pBuf->fLoopStart = fLoopStart;
    else if (bLoop)
        pBuf->fLoopStart = pBuf->fEnd * 0.25;   // testing
    if (fLoopEnd > 0.0f)
        pBuf->fLoopEnd = fLoopEnd;
    else if (bLoop)
        pBuf->fLoopEnd = pBuf->fEnd * 0.75;     // testing
}

AKMappedSampleBuffer* AKSampler::lookupSample(unsigned noteNumber, unsigned velocity)
{
    // common case: only one sample mapped to this note - return it immediately
    if (keyMap[noteNumber].size() == 1) return keyMap[noteNumber].front();
    
    // search samples mapped to this note for best choice based on velocity
    for (AKMappedSampleBuffer* pBuf : keyMap[noteNumber])
    {
        // if sample does not have velocity range, accept it trivially
        if (pBuf->min_vel < 0 || pBuf->max_vel < 0) return pBuf;
        
        // otherwise (common case), accept based on velocity
        if (velocity >= pBuf->min_vel && velocity <= pBuf->max_vel) return pBuf;
    }
    
    // return nil if no samples mapped to note (or sample velocities are invalid)
    return 0;
}

// re-compute keyMap[] so every MIDI note number is automatically mapped to the sample buffer
// closest in pitch
void AKSampler::buildSimpleKeyMap()
{
    // clear out the old mapping entirely
    for (int i=0; i < MIDI_NOTENUMBERS; i++) keyMap[i].clear();
    
    for (int nn=0; nn < MIDI_NOTENUMBERS; nn++)
    {
        // scan loaded samples to find the minimum distance to note nn
        int minDistance = MIDI_NOTENUMBERS;
        for (AKMappedSampleBuffer* pBuf : sampleBufferList)
        {
            int distance = abs(pBuf->noteNumber - nn);
            if (distance < minDistance)
            {
                minDistance = distance;
            }
        }
        
        // scan again to add only samples at this distance to the list for note nn
        for (AKMappedSampleBuffer* pBuf : sampleBufferList)
        {
            int distance = abs(pBuf->noteNumber - nn);
            if (distance == minDistance)
            {
                keyMap[nn].push_back(pBuf);
            }
        }
    }
}

// rebuild keyMap based on explicit mapping data in samples
void AKSampler::buildKeyMap(void)
{
    // clear out the old mapping entirely
    for (int i=0; i < MIDI_NOTENUMBERS; i++) keyMap[i].clear();
    
    for (int nn=0; nn < MIDI_NOTENUMBERS; nn++)
    {
        for (AKMappedSampleBuffer* pBuf : sampleBufferList)
        {
            if (nn >= pBuf->min_note && nn <= pBuf->max_note)
                 keyMap[nn].push_back(pBuf);
        }
    }
}

AKSamplerVoice* AKSampler::voicePlayingNote(unsigned int noteNumber)
{
    for (int i=0; i < MAX_POLYPHONY; i++)
    {
        AKSamplerVoice* pVoice = &voice[i];
        if (pVoice->noteNumber == noteNumber) return pVoice;
    }
    return 0;
}

void AKSampler::playNote(unsigned noteNumber, unsigned velocity, float noteHz)
{
    //printf("playNote nn=%d vel=%d %.2f Hz\n", noteNumber, velocity, noteHz);
    // sanity check: ensure we are initialized with at least one buffer
    if (sampleBufferList.size() == 0) return;
    
    // is any voice already playing this note?
    AKSamplerVoice* pVoice = voicePlayingNote(noteNumber);
    if (pVoice)
    {
        // re-start the note
        AKMappedSampleBuffer* pBuf = lookupSample(noteNumber, velocity);
        pVoice->start(noteNumber, noteHz, velocity / 127.0f, pBuf);
        //printf("Restart note %d as %d\n", noteNumber, pBuf->noteNumber);
        return;
    }
    
    // find a free voice (with noteNumber < 0) to play the note
    for (int i=0; i < MAX_POLYPHONY; i++)
    {
        AKSamplerVoice* pVoice = &voice[i];
        if (pVoice->noteNumber < 0)
        {
            // found a free voice: assign it to play this note
            AKMappedSampleBuffer* pBuf = lookupSample(noteNumber, velocity);
            pVoice->start(noteNumber, noteHz, velocity / 127.0f, pBuf);
            //printf("Play note %d (%.2f Hz) vel %d as %d (%.2f Hz, pBuf %p)\n",
            //       noteNumber, noteHz, velocity, pBuf->noteNumber, pBuf->noteHz, pBuf);
            return;
        }
    }
    
    // all oscillators in use; do nothing
}

void AKSampler::stopNote(unsigned noteNumber, bool immediate)
{
    //printf("stopNote nn=%d %s\n", noteNumber, immediate ? "immediate" : "release");
    AKSamplerVoice* pVoice = voicePlayingNote(noteNumber);
    if (pVoice == 0) return;
    //printf("stopNote pVoice is %p\n", pVoice);
    
    if (immediate)
    {
        pVoice->stop();
        //printf("Stop note %d immediate\n", noteNumber);
    }
    else
    {
        pVoice->release();
        //printf("Stop note %d release\n", noteNumber);
    }
}

void AKSampler::updateAmpADSR()
{
    ampEGParams.init(ampAttackTime, ampDecayTime, ampSustainLevel, ampReleaseTime);
}

void AKSampler::updateFilterADSR()
{
    filterEGParams.init(filterAttackTime, filterDecayTime, filterSustainLevel, filterReleaseTime);
}

void AKSampler::Render(unsigned channelCount, unsigned sampleCount, float *outBuffers[])
{
    float* pOutLeft = outBuffers[0];
    float* pOutRight = outBuffers[1];
    
    float cutoffMul = filterEnable ? cutoffMultiple : -1.0;
    
    AKSamplerVoice* pVoice = &voice[0];
    for (int i=0; i < MAX_POLYPHONY; i++, pVoice++)
    {
        int nn = pVoice->noteNumber;
        if (nn >= 0)
        {
            if (pVoice->prepToGetSamples(masterVolume, pitchOffset, cutoffMul) ||
                pVoice->getSamples(sampleCount, pOutLeft, pOutRight))
            {
                stopNote(nn, true);
            }
        }
    }
}
