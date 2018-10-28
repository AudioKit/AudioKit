//
//  Sampler.cpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKCoreSampler.hpp"
#include "SamplerVoice.hpp"
#include "FunctionTable.hpp"
#include "SustainPedalLogic.hpp"

#include <math.h>
#include <list>

// number of voices
#define MAX_POLYPHONY 64

// MIDI offers 128 distinct note numbers
#define MIDI_NOTENUMBERS 128

struct AKCoreSampler::_Internal {
    // list of (pointers to) all loaded samples
    std::list<AudioKitCore::KeyMappedSampleBuffer*> sampleBufferList;
    
    // maps MIDI note numbers to "closest" samples (all velocity layers)
    std::list<AudioKitCore::KeyMappedSampleBuffer*> keyMap[MIDI_NOTENUMBERS];
    
    AudioKitCore::ADSREnvelopeParameters adsrEnvelopeParameters;
    AudioKitCore::ADSREnvelopeParameters filterEnvelopeParameters;
    
    // table of voice resources
    AudioKitCore::SamplerVoice voice[MAX_POLYPHONY];
    
    // one vibrato LFO shared by all voices
    AudioKitCore::FunctionTableOscillator vibratoLFO;
    
    AudioKitCore::SustainPedalLogic pedalLogic;
};

AKCoreSampler::AKCoreSampler()
: sampleRate(44100.0f)    // sensible guess
, isKeyMapValid(false)
, isFilterEnabled(false)
, masterVolume(1.0f)
, pitchOffset(0.0f)
, vibratoDepth(0.0f)
, glideRate(0.0f)   // 0 sec/octave means "no glide"
, isMonophonic(false)
, isLegato(false)
, portamentoRate(1.0f)
, cutoffMultiple(4.0f)
, cutoffEnvelopeStrength(20.0f)
, linearResonance(0.5f)
, loopThruRelease(false)
, stoppingAllVoices(false)
, _private(new _Internal)
{
    AudioKitCore::SamplerVoice *pVoice = _private->voice;
    for (int i=0; i < MAX_POLYPHONY; i++, pVoice++)
    {
        pVoice->adsrEnvelope.pParameters = &_private->adsrEnvelopeParameters;
        pVoice->filterEnvelope.pParameters = &_private->filterEnvelopeParameters;
        pVoice->noteFrequency = 0.0f;
        pVoice->glideSecPerOctave = &glideRate;
    }
}

AKCoreSampler::~AKCoreSampler()
{
}

int AKCoreSampler::init(double sampleRate)
{
    sampleRate = (float)sampleRate;
    _private->adsrEnvelopeParameters.updateSampleRate((float)(sampleRate/AKCORESAMPLER_CHUNKSIZE));
    _private->filterEnvelopeParameters.updateSampleRate((float)(sampleRate/AKCORESAMPLER_CHUNKSIZE));
    _private->vibratoLFO.waveTable.sinusoid();
    _private->vibratoLFO.init(sampleRate/AKCORESAMPLER_CHUNKSIZE, 5.0f);
    
    for (int i=0; i<MAX_POLYPHONY; i++)
        _private->voice[i].init(sampleRate);
    
    return 0;   // no error
}

void AKCoreSampler::deinit()
{
    isKeyMapValid = false;
    for (AudioKitCore::KeyMappedSampleBuffer *pBuf : _private->sampleBufferList)
        delete pBuf;
    _private->sampleBufferList.clear();
    for (int i=0; i < MIDI_NOTENUMBERS; i++)
        _private->keyMap[i].clear();
}

void AKCoreSampler::loadSampleData(AKSampleDataDescriptor& sdd)
{
    AudioKitCore::KeyMappedSampleBuffer *pBuf = new AudioKitCore::KeyMappedSampleBuffer();
    pBuf->minimumNoteNumber = sdd.sampleDescriptor.minimumNoteNumber;
    pBuf->maximumNoteNumber = sdd.sampleDescriptor.maximumNoteNumber;
    pBuf->minimumVelocity = sdd.sampleDescriptor.minimumVelocity;
    pBuf->maximumVelocity = sdd.sampleDescriptor.maximumVelocity;
    _private->sampleBufferList.push_back(pBuf);
    
    pBuf->init(sdd.sampleRate, sdd.channelCount, sdd.sampleCount);
    float *pData = sdd.data;
    if (sdd.isInterleaved) for (int i=0; i < sdd.sampleCount; i++)
    {
        pBuf->setData(i, *pData++);
        if (sdd.channelCount > 1) pBuf->setData(sdd.sampleCount + i, *pData++);
    }
    else for (int i=0; i < sdd.channelCount * sdd.sampleCount; i++)
    {
        pBuf->setData(i, *pData++);
    }
    pBuf->noteNumber = sdd.sampleDescriptor.noteNumber;
    pBuf->noteFrequency = sdd.sampleDescriptor.noteFrequency;
    
    if (sdd.sampleDescriptor.startPoint > 0.0f) pBuf->startPoint = sdd.sampleDescriptor.startPoint;
    if (sdd.sampleDescriptor.endPoint > 0.0f)   pBuf->endPoint = sdd.sampleDescriptor.endPoint;
    
    pBuf->isLooping = sdd.sampleDescriptor.isLooping;
    if (pBuf->isLooping)
    {
        // loopStartPoint, loopEndPoint are usually sample indices, but values 0.0-1.0
        // are interpreted as fractions of the total sample length.
        if (sdd.sampleDescriptor.loopStartPoint > 1.0f) pBuf->loopStartPoint = sdd.sampleDescriptor.loopStartPoint;
        else pBuf->loopStartPoint = pBuf->endPoint * sdd.sampleDescriptor.loopStartPoint;
        if (sdd.sampleDescriptor.loopEndPoint > 1.0f) pBuf->loopEndPoint = sdd.sampleDescriptor.loopEndPoint;
        else pBuf->loopEndPoint = pBuf->endPoint * sdd.sampleDescriptor.loopEndPoint;
    }
}

AudioKitCore::KeyMappedSampleBuffer *AKCoreSampler::lookupSample(unsigned noteNumber, unsigned velocity)
{
    // common case: only one sample mapped to this note - return it immediately
    if (_private->keyMap[noteNumber].size() == 1)
        return _private->keyMap[noteNumber].front();
    
    // search samples mapped to this note for best choice based on velocity
    for (AudioKitCore::KeyMappedSampleBuffer *pBuf : _private->keyMap[noteNumber])
    {
        // if sample does not have velocity range, accept it trivially
        if (pBuf->minimumVelocity < 0 || pBuf->maximumVelocity < 0) return pBuf;
        
        // otherwise (common case), accept based on velocity
        if ((int)velocity >= pBuf->minimumVelocity && (int)velocity <= pBuf->maximumVelocity) return pBuf;
    }
    
    // return nil if no samples mapped to note (or sample velocities are invalid)
    return 0;
}

// re-compute keyMap[] so every MIDI note number is automatically mapped to the sample buffer
// closest in pitch
void AKCoreSampler::buildSimpleKeyMap()
{
    // clear out the old mapping entirely
    isKeyMapValid = false;
    for (int i=0; i < MIDI_NOTENUMBERS; i++)
        _private->keyMap[i].clear();
    
    for (int nn=0; nn < MIDI_NOTENUMBERS; nn++)
    {
        // scan loaded samples to find the minimum distance to note nn
        int minDistance = MIDI_NOTENUMBERS;
        for (AudioKitCore::KeyMappedSampleBuffer *pBuf : _private->sampleBufferList)
        {
            int distance = abs(pBuf->noteNumber - nn);
            if (distance < minDistance)
            {
                minDistance = distance;
            }
        }
        
        // scan again to add only samples at this distance to the list for note nn
        for (AudioKitCore::KeyMappedSampleBuffer *pBuf : _private->sampleBufferList)
        {
            int distance = abs(pBuf->noteNumber - nn);
            if (distance == minDistance)
            {
                _private->keyMap[nn].push_back(pBuf);
            }
        }
    }
    isKeyMapValid = true;
}

// rebuild keyMap based on explicit mapping data in samples
void AKCoreSampler::buildKeyMap(void)
{
    // clear out the old mapping entirely
    isKeyMapValid = false;
    for (int i=0; i < MIDI_NOTENUMBERS; i++) _private->keyMap[i].clear();
    
    for (int nn=0; nn < MIDI_NOTENUMBERS; nn++)
    {
        for (AudioKitCore::KeyMappedSampleBuffer *pBuf : _private->sampleBufferList)
        {
            if (nn >= pBuf->minimumNoteNumber && nn <= pBuf->maximumNoteNumber)
                _private->keyMap[nn].push_back(pBuf);
        }
    }
    isKeyMapValid = true;
}

AudioKitCore::SamplerVoice *AKCoreSampler::voicePlayingNote(unsigned noteNumber)
{
    for (int i=0; i < MAX_POLYPHONY; i++)
    {
        AudioKitCore::SamplerVoice *pVoice = &_private->voice[i];
        if (pVoice->noteNumber == noteNumber) return pVoice;
    }
    return 0;
}

void AKCoreSampler::playNote(unsigned noteNumber, unsigned velocity, float noteFrequency)
{
    bool anotherKeyWasDown = _private->pedalLogic.isAnyKeyDown();
    _private->pedalLogic.keyDownAction(noteNumber);
    play(noteNumber, velocity, noteFrequency, anotherKeyWasDown);
}

void AKCoreSampler::stopNote(unsigned noteNumber, bool immediate)
{
    if (immediate || _private->pedalLogic.keyUpAction(noteNumber))
        stop(noteNumber, immediate);
}

void AKCoreSampler::sustainPedal(bool down)
{
    if (down) _private->pedalLogic.pedalDown();
    else {
        for (int nn=0; nn < MIDI_NOTENUMBERS; nn++)
        {
            if (_private->pedalLogic.isNoteSustaining(nn))
                stop(nn, false);
        }
        _private->pedalLogic.pedalUp();
    }
}

void AKCoreSampler::play(unsigned noteNumber, unsigned velocity, float noteFrequency, bool anotherKeyWasDown)
{
    if (stoppingAllVoices) return;
    
    //printf("playNote nn=%d vel=%d %.2f Hz\n", noteNumber, velocity, noteFrequency);
    // sanity check: ensure we are initialized with at least one buffer
    if (!isKeyMapValid || _private->sampleBufferList.size() == 0) return;
    
    if (isMonophonic)
    {
        if (isLegato && anotherKeyWasDown)
        {
            // is our one and only voice playing some note?
            AudioKitCore::SamplerVoice *pVoice = &_private->voice[0];
            if (pVoice->noteNumber >= 0)
            {
                //printf("restart %d as %d\n", pVoice->noteNumber, noteNumber);
                pVoice->restart(noteNumber, sampleRate, noteFrequency);
            }
            else
            {
                AudioKitCore::KeyMappedSampleBuffer *pBuf = lookupSample(noteNumber, velocity);
                if (pBuf == 0) return;  // don't crash if someone forgets to build map
                pVoice->start(noteNumber, sampleRate, noteFrequency, velocity / 127.0f, pBuf);
            }
            lastPlayedNoteNumber = noteNumber;
            return;
        }
        else
        {
            // monophonic but not legato: always start a new note
            AudioKitCore::SamplerVoice *pVoice = &_private->voice[0];
            AudioKitCore::KeyMappedSampleBuffer *pBuf = lookupSample(noteNumber, velocity);
            if (pBuf == 0) return;  // don't crash if someone forgets to build map
            pVoice->start(noteNumber, sampleRate, noteFrequency, velocity / 127.0f, pBuf);
            lastPlayedNoteNumber = noteNumber;
            return;
        }
    }
    
    else // polyphonic
    {
        // is any voice already playing this note?
        AudioKitCore::SamplerVoice *pVoice = voicePlayingNote(noteNumber);
        if (pVoice)
        {
            // re-start the note
            pVoice->restart(velocity / 127.0f, lookupSample(noteNumber, velocity));
            //printf("Restart note %d as %d\n", noteNumber, pVoice->noteNumber);
            return;
        }
        
        // find a free voice (with noteNumber < 0) to play the note
        int polyphony = isMonophonic ? 1 : MAX_POLYPHONY;
        for (int i = 0; i < polyphony; i++)
        {
            AudioKitCore::SamplerVoice *pVoice = &_private->voice[i];
            if (pVoice->noteNumber < 0)
            {
                // found a free voice: assign it to play this note
                AudioKitCore::KeyMappedSampleBuffer *pBuf = lookupSample(noteNumber, velocity);
                if (pBuf == 0) return;  // don't crash if someone forgets to build map
                pVoice->start(noteNumber, sampleRate, noteFrequency, velocity / 127.0f, pBuf);
                lastPlayedNoteNumber = noteNumber;
                //printf("Play note %d (%.2f Hz) vel %d as %d (%.2f Hz, voice %d pBuf %p)\n",
                //       noteNumber, noteFrequency, velocity, pBuf->noteNumber, pBuf->noteFrequency, i, pBuf);
                return;
            }
        }
        
        // all oscillators in use; do nothing
        //printf("All oscillators in use!\n");
    }
}

#define NOTE_HZ(midiNoteNumber) ( 440.0f * pow(2.0f, ((midiNoteNumber) - 69.0f)/12.0f) )

void AKCoreSampler::stop(unsigned noteNumber, bool immediate)
{
    //printf("stopNote nn=%d %s\n", noteNumber, immediate ? "immediate" : "release");
    AudioKitCore::SamplerVoice *pVoice = voicePlayingNote(noteNumber);
    if (pVoice == 0) return;
    //printf("stopNote pVoice is %p\n", pVoice);
    
    if (immediate)
    {
        pVoice->stop();
        //printf("Stop note %d immediate\n", noteNumber);
    }
    else if (isMonophonic)
    {
        int key = _private->pedalLogic.firstKeyDown();
        if (key < 0) pVoice->release(loopThruRelease);
        else if (isLegato) pVoice->restart((unsigned)key, sampleRate, NOTE_HZ(key));
        else
        {
            unsigned velocity = 100;
            AudioKitCore::KeyMappedSampleBuffer *pBuf = lookupSample(key, velocity);
            if (pBuf == 0) return;  // don't crash if someone forgets to build map
            pVoice->start(key, sampleRate, NOTE_HZ(key), velocity / 127.0f, pBuf);
        }
    }
    else
    {
        pVoice->release(loopThruRelease);
        //printf("Stop note %d release\n", noteNumber);
    }
}

void AKCoreSampler::stopAllVoices()
{
    // Lock out starting any new notes, and tell Render() to stop all active notes
    stoppingAllVoices = true;
    
    // Wait until Render() has killed all active notes
    bool noteStillSounding = true;
    while (noteStillSounding)
    {
        noteStillSounding = false;
        for (int i=0; i < MAX_POLYPHONY; i++)
            if (_private->voice[i].noteNumber >= 0) noteStillSounding = true;
    }
}

void AKCoreSampler::restartVoices()
{
    // Allow starting new notes again
    stoppingAllVoices = false;
}

void AKCoreSampler::render(unsigned channelCount, unsigned sampleCount, float *outBuffers[])
{
    float *pOutLeft = outBuffers[0];
    float *pOutRight = outBuffers[1];
    
    float pitchDev = this->pitchOffset + vibratoDepth * _private->vibratoLFO.getSample();
    float cutoffMul = isFilterEnabled ? cutoffMultiple : -1.0f;
    
    bool allowSampleRunout = !(isMonophonic && isLegato);

    AudioKitCore::SamplerVoice *pVoice = &_private->voice[0];
    for (int i=0; i < MAX_POLYPHONY; i++, pVoice++)
    {
        int nn = pVoice->noteNumber;
        if (nn >= 0)
        {
            if (stoppingAllVoices ||
                pVoice->prepToGetSamples(sampleCount, masterVolume, pitchDev, cutoffMul,
                                         cutoffEnvelopeStrength, linearResonance) ||
                (pVoice->getSamples(sampleCount, pOutLeft, pOutRight) && allowSampleRunout))
            {
                stopNote(nn, true);
            }
        }
    }
}

void  AKCoreSampler::setADSRAttackDurationSeconds(float value)
{
    _private->adsrEnvelopeParameters.setAttackDurationSeconds(value);
    for (int i = 0; i < MAX_POLYPHONY; i++) _private->voice[i].updateAmpAdsrParameters();
}

float AKCoreSampler::getADSRAttackDurationSeconds(void)
{
    return _private->adsrEnvelopeParameters.getAttackDurationSeconds();
}

void  AKCoreSampler::setADSRDecayDurationSeconds(float value)
{
    _private->adsrEnvelopeParameters.setDecayDurationSeconds(value);
    for (int i = 0; i < MAX_POLYPHONY; i++) _private->voice[i].updateAmpAdsrParameters();
}

float AKCoreSampler::getADSRDecayDurationSeconds(void)
{
    return _private->adsrEnvelopeParameters.getDecayDurationSeconds();
}

void  AKCoreSampler::setADSRSustainFraction(float value)
{
    _private->adsrEnvelopeParameters.sustainFraction = value;
    for (int i = 0; i < MAX_POLYPHONY; i++) _private->voice[i].updateAmpAdsrParameters();
}

float AKCoreSampler::getADSRSustainFraction(void)
{
    return _private->adsrEnvelopeParameters.sustainFraction;
}

void  AKCoreSampler::setADSRReleaseDurationSeconds(float value)
{
    _private->adsrEnvelopeParameters.setReleaseDurationSeconds(value);
    for (int i = 0; i < MAX_POLYPHONY; i++) _private->voice[i].updateAmpAdsrParameters();
}

float AKCoreSampler::getADSRReleaseDurationSeconds(void)
{
    return _private->adsrEnvelopeParameters.getReleaseDurationSeconds();
}

void  AKCoreSampler::setFilterAttackDurationSeconds(float value)
{
    _private->filterEnvelopeParameters.setAttackDurationSeconds(value);
    for (int i = 0; i < MAX_POLYPHONY; i++) _private->voice[i].updateFilterAdsrParameters();
}

float AKCoreSampler::getFilterAttackDurationSeconds(void)
{
    return _private->filterEnvelopeParameters.getAttackDurationSeconds();
}

void  AKCoreSampler::setFilterDecayDurationSeconds(float value)
{
    _private->filterEnvelopeParameters.setDecayDurationSeconds(value);
    for (int i = 0; i < MAX_POLYPHONY; i++) _private->voice[i].updateFilterAdsrParameters();
}

float AKCoreSampler::getFilterDecayDurationSeconds(void)
{
    return _private->filterEnvelopeParameters.getDecayDurationSeconds();
}

void  AKCoreSampler::setFilterSustainFraction(float value)
{
    _private->filterEnvelopeParameters.sustainFraction = value;
    for (int i = 0; i < MAX_POLYPHONY; i++) _private->voice[i].updateFilterAdsrParameters();
}

float AKCoreSampler::getFilterSustainFraction(void)
{
    return _private->filterEnvelopeParameters.sustainFraction;
}

void  AKCoreSampler::setFilterReleaseDurationSeconds(float value)
{
    _private->filterEnvelopeParameters.setReleaseDurationSeconds(value);
    for (int i = 0; i < MAX_POLYPHONY; i++) _private->voice[i].updateFilterAdsrParameters();
}

float AKCoreSampler::getFilterReleaseDurationSeconds(void)
{
    return _private->filterEnvelopeParameters.getReleaseDurationSeconds();
}
