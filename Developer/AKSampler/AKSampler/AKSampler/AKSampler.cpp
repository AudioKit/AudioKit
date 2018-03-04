#include "AKSampler.hpp"
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
, vibratoDepth(0.0f)
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

void AKSampler::loadSampleData(AKSampleDataDescriptor& sdd)
{
    AKMappedSampleBuffer* pBuf = new AKMappedSampleBuffer();
    pBuf->min_note = sdd.sd.min_note;
    pBuf->max_note = sdd.sd.max_note;
    pBuf->min_vel = sdd.sd.min_vel;
    pBuf->max_vel = sdd.sd.max_vel;
    sampleBufferList.push_back(pBuf);

    pBuf->init(sdd.nChannels, sdd.nSamples);
    float* pData = sdd.pData;
    if (sdd.bInterleaved) for (unsigned i=0; i < sdd.nSamples; i++)
    {
        pBuf->setData(i, *pData++);
        if (sdd.nChannels > 1) pBuf->setData(sdd.nSamples + i, *pData++);
    }
    else for (unsigned i=0; i < sdd.nChannels * sdd.nSamples; i++)
    {
        pBuf->setData(i, *pData++);
    }
    pBuf->noteNumber = sdd.sd.noteNumber;
    pBuf->noteHz = sdd.sd.noteHz;
    
    if (sdd.sd.fStart > 0.0f) pBuf->fStart = sdd.sd.fStart;
    if (sdd.sd.fEnd > 0.0f)   pBuf->fEnd = sdd.sd.fEnd;
    
    pBuf->bLoop = sdd.sd.bLoop;
    if (sdd.sd.fLoopStart > 0.0f)
        pBuf->fLoopStart = sdd.sd.fLoopStart;
    else if (sdd.sd.bLoop)
        pBuf->fLoopStart = pBuf->fEnd * 0.25;   // testing
    if (sdd.sd.fLoopEnd > 0.0f)
        pBuf->fLoopEnd = sdd.sd.fLoopEnd;
    else if (sdd.sd.bLoop)
        pBuf->fLoopEnd = pBuf->fEnd * 0.75;     // testing
}

void AKSampler::loadCompressedSampleFile(AKSampleFileDescriptor& sfd)
{
    //printf("loadCompressedSampleFile: %d %.1f Hz %s\n", sfd.sd.noteNumber, sfd.sd.noteHz, sfd.path);
    
    int ifd = open(sfd.path, O_RDONLY);
    if (ifd < 0)
    {
        printf("Error %d opening %s\n", errno, sfd.path);
        return;
    }
    
    AKSampleDataDescriptor sdd;
    sdd.sd = sfd.sd;
    
    int check = getWvData(ifd, &sdd.nChannels, &sdd.nSamples);
    close(ifd);
    if (check != 0)
    {
        printf("getWvData returns %d for %s\n", check, sfd.path);
        return;
    }
    sdd.bInterleaved = (sdd.nChannels > 1);
    
    ifd = open(sfd.path, O_RDONLY);
    sdd.pData = new float[sdd.nChannels * sdd.nSamples];
    check = getWvSamples(ifd, sdd.pData);
    close(ifd);
    
    loadSampleData(sdd);
    
    delete[] sdd.pData;
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
    if (pedalLogic.keyDownAction(noteNumber) == AKSustainPedalLogic::kStopNoteThenPlay)
        stop(noteNumber, false);
    play(noteNumber, velocity, noteHz);
}

void AKSampler::stopNote(unsigned noteNumber, bool immediate)
{
    if (immediate || pedalLogic.keyUpAction(noteNumber) == AKSustainPedalLogic::kStopNote)
        stop(noteNumber, immediate);
}

void AKSampler::sustainPedal(bool down)
{
    if (down) pedalLogic.pedalDown();
    else {
        for (int nn=0; nn < MIDI_NOTENUMBERS; nn++)
        {
            if (pedalLogic.isNoteSustaining(nn))
                stop(nn, false);
        }
        pedalLogic.pedalUp();
    }
}

void AKSampler::play(unsigned noteNumber, unsigned velocity, float noteHz)
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

void AKSampler::stop(unsigned noteNumber, bool immediate)
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
    
    float pitchDev = this->pitchOffset + vibratoDepth * vibratoLFO.getSample();
    float cutoffMul = filterEnable ? cutoffMultiple : -1.0;
    
    AKSamplerVoice* pVoice = &voice[0];
    for (int i=0; i < MAX_POLYPHONY; i++, pVoice++)
    {
        int nn = pVoice->noteNumber;
        if (nn >= 0)
        {
            if (pVoice->prepToGetSamples(masterVolume, pitchDev, cutoffMul) ||
                pVoice->getSamples(sampleCount, pOutLeft, pOutRight))
            {
                stopNote(nn, true);
            }
        }
    }
}
