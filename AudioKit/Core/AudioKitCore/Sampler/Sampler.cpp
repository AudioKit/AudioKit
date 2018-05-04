//
//  Sampler.cpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "Sampler.hpp"
#include <math.h>

namespace AudioKitCore {
    
    Sampler::Sampler()
    : sampleRateHz(44100.0f)    // sensible guess
    , keyMapValid(false)
    , filterEnable(false)
    , masterVolume(1.0f)
    , pitchOffset(0.0f)
    , vibratoDepth(0.0f)
    , cutoffMultiple(4.0f)
    , cutoffEgStrength(20.0f)
    , resLinear(1.0f)
    , loopThruRelease(false)
    , stoppingAllVoices(false)
    {
        for (int i=0; i < MAX_POLYPHONY; i++)
        {
            voice[i].ampEG.pParams = &ampEGParams;
            voice[i].filterEG.pParams = &filterEGParams;
        }
    }
    
    Sampler::~Sampler()
    {
    }
    
    int Sampler::init(double sampleRate)
    {
        sampleRateHz = (float)sampleRate;
        ampEGParams.updateSampleRate((float)(sampleRate/CHUNKSIZE));
        filterEGParams.updateSampleRate((float)(sampleRate/CHUNKSIZE));
        vibratoLFO.waveTable.sinusoid();
        vibratoLFO.init(sampleRate/CHUNKSIZE, 5.0f);

        for (int i=0; i<MAX_POLYPHONY; i++) voice[i].init(sampleRate);

        return 0;   // no error
    }
    
    void Sampler::deinit()
    {
        keyMapValid = false;
        for (KeyMappedSampleBuffer* pBuf : sampleBufferList) delete pBuf;
        sampleBufferList.clear();
        for (int i=0; i < MIDI_NOTENUMBERS; i++) keyMap[i].clear();
    }
    
    void Sampler::loadSampleData(AKSampleDataDescriptor& sdd)
    {
        KeyMappedSampleBuffer* pBuf = new KeyMappedSampleBuffer();
        pBuf->min_note = sdd.sampleDescriptor.minimumNoteNumber;
        pBuf->max_note = sdd.sampleDescriptor.maximumNoteNumber;
        pBuf->min_vel = sdd.sampleDescriptor.minimumVelocity;
        pBuf->max_vel = sdd.sampleDescriptor.maximumVelocity;
        sampleBufferList.push_back(pBuf);
        
        pBuf->init(sdd.sampleRate, sdd.channelCount, sdd.sampleCount);
        float* pData = sdd.data;
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
        
        pBuf->bLoop = sdd.sampleDescriptor.isLooping;
        if (pBuf->bLoop)
        {
            // loopStartPoint, loopEndPoint are usually sample indices, but values 0.0-1.0
            // are interpreted as fractions of the total sample length.
            if (sdd.sampleDescriptor.loopStartPoint > 1.0f) pBuf->loopStartPoint = sdd.sampleDescriptor.loopStartPoint;
            else pBuf->loopStartPoint = pBuf->endPoint * sdd.sampleDescriptor.loopStartPoint;
            if (sdd.sampleDescriptor.loopEndPoint > 1.0f) pBuf->loopEndPoint = sdd.sampleDescriptor.loopEndPoint;
            else pBuf->loopEndPoint = pBuf->endPoint * sdd.sampleDescriptor.loopEndPoint;
        }
    }
    
    KeyMappedSampleBuffer* Sampler::lookupSample(unsigned noteNumber, unsigned velocity)
    {
        // common case: only one sample mapped to this note - return it immediately
        if (keyMap[noteNumber].size() == 1) return keyMap[noteNumber].front();
        
        // search samples mapped to this note for best choice based on velocity
        for (KeyMappedSampleBuffer* pBuf : keyMap[noteNumber])
        {
            // if sample does not have velocity range, accept it trivially
            if (pBuf->min_vel < 0 || pBuf->max_vel < 0) return pBuf;
            
            // otherwise (common case), accept based on velocity
            if ((int)velocity >= pBuf->min_vel && (int)velocity <= pBuf->max_vel) return pBuf;
        }
        
        // return nil if no samples mapped to note (or sample velocities are invalid)
        return 0;
    }
    
    // re-compute keyMap[] so every MIDI note number is automatically mapped to the sample buffer
    // closest in pitch
    void Sampler::buildSimpleKeyMap()
    {
        // clear out the old mapping entirely
        keyMapValid = false;
        for (int i=0; i < MIDI_NOTENUMBERS; i++) keyMap[i].clear();
        
        for (int nn=0; nn < MIDI_NOTENUMBERS; nn++)
        {
            // scan loaded samples to find the minimum distance to note nn
            int minDistance = MIDI_NOTENUMBERS;
            for (KeyMappedSampleBuffer* pBuf : sampleBufferList)
            {
                int distance = abs(pBuf->noteNumber - nn);
                if (distance < minDistance)
                {
                    minDistance = distance;
                }
            }
            
            // scan again to add only samples at this distance to the list for note nn
            for (KeyMappedSampleBuffer* pBuf : sampleBufferList)
            {
                int distance = abs(pBuf->noteNumber - nn);
                if (distance == minDistance)
                {
                    keyMap[nn].push_back(pBuf);
                }
            }
        }
        keyMapValid = true;
    }
    
    // rebuild keyMap based on explicit mapping data in samples
    void Sampler::buildKeyMap(void)
    {
        // clear out the old mapping entirely
        keyMapValid = false;
        for (int i=0; i < MIDI_NOTENUMBERS; i++) keyMap[i].clear();

        for (int nn=0; nn < MIDI_NOTENUMBERS; nn++)
        {
            for (KeyMappedSampleBuffer* pBuf : sampleBufferList)
            {
                if (nn >= pBuf->min_note && nn <= pBuf->max_note)
                    keyMap[nn].push_back(pBuf);
            }
        }
        keyMapValid = true;
    }
    
    SamplerVoice* Sampler::voicePlayingNote(unsigned int noteNumber)
    {
        for (int i=0; i < MAX_POLYPHONY; i++)
        {
            SamplerVoice* pVoice = &voice[i];
            if (pVoice->noteNumber == noteNumber) return pVoice;
        }
        return 0;
    }

    void Sampler::playNote(unsigned noteNumber, unsigned velocity, float noteFrequency)
    {
        pedalLogic.keyDownAction(noteNumber);
        //if (pedalLogic.keyDownAction(noteNumber))
        //    stop(noteNumber, false);
        play(noteNumber, velocity, noteFrequency);
    }
    
    void Sampler::stopNote(unsigned noteNumber, bool immediate)
    {
        if (immediate || pedalLogic.keyUpAction(noteNumber))
            stop(noteNumber, immediate);
    }
    
    void Sampler::sustainPedal(bool down)
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
    
    void Sampler::play(unsigned noteNumber, unsigned velocity, float noteFrequency)
    {
        if (stoppingAllVoices) return;

        //printf("playNote nn=%d vel=%d %.2f Hz\n", noteNumber, velocity, noteFrequency);
        // sanity check: ensure we are initialized with at least one buffer
        if (!keyMapValid || sampleBufferList.size() == 0) return;
        
        // is any voice already playing this note?
        SamplerVoice* pVoice = voicePlayingNote(noteNumber);
        if (pVoice)
        {
            // re-start the note
            pVoice->restart(velocity / 127.0f, lookupSample(noteNumber, velocity));
            //printf("Restart note %d as %d\n", noteNumber, pVoice->noteNumber);
            return;
        }
        
        // find a free voice (with noteNumber < 0) to play the note
        for (int i=0; i < MAX_POLYPHONY; i++)
        {
            SamplerVoice* pVoice = &voice[i];
            if (pVoice->noteNumber < 0)
            {
                // found a free voice: assign it to play this note
                KeyMappedSampleBuffer* pBuf = lookupSample(noteNumber, velocity);
                if (pBuf == 0) return;  // don't crash if someone forgets to build map
                pVoice->start(noteNumber, sampleRateHz, noteFrequency, velocity / 127.0f, pBuf);
                //printf("Play note %d (%.2f Hz) vel %d as %d (%.2f Hz, voice %d pBuf %p)\n",
                //       noteNumber, noteFrequency, velocity, pBuf->noteNumber, pBuf->noteFrequency, i, pBuf);
                return;
            }
        }
        
        // all oscillators in use; do nothing
        //printf("All oscillators in use!\n");
    }
    
    void Sampler::stop(unsigned noteNumber, bool immediate)
    {
        //printf("stopNote nn=%d %s\n", noteNumber, immediate ? "immediate" : "release");
        SamplerVoice* pVoice = voicePlayingNote(noteNumber);
        if (pVoice == 0) return;
        //printf("stopNote pVoice is %p\n", pVoice);
        
        if (immediate)
        {
            pVoice->stop();
            //printf("Stop note %d immediate\n", noteNumber);
        }
        else
        {
            pVoice->release(loopThruRelease);
            //printf("Stop note %d release\n", noteNumber);
        }
    }

    void Sampler::stopAllVoices()
    {
        // Lock out starting any new notes, and tell Render() to stop all active notes
        stoppingAllVoices = true;

        // Wait until Render() has killed all active notes
        bool noteStillSounding = true;
        while (noteStillSounding)
        {
            noteStillSounding = false;
            for (int i=0; i < MAX_POLYPHONY; i++)
                if (voice[i].noteNumber >= 0) noteStillSounding = true;
        }
    }

    void Sampler::restartVoices()
    {
        // Allow starting new notes again
        stoppingAllVoices = false;
    }
    
    void Sampler::Render(unsigned channelCount, unsigned sampleCount, float *outBuffers[])
    {
        float* pOutLeft = outBuffers[0];
        float* pOutRight = outBuffers[1];
        
        float pitchDev = this->pitchOffset + vibratoDepth * vibratoLFO.getSample();
        float cutoffMul = filterEnable ? cutoffMultiple : -1.0f;
        
        SamplerVoice* pVoice = &voice[0];
        for (int i=0; i < MAX_POLYPHONY; i++, pVoice++)
        {
            int nn = pVoice->noteNumber;
            if (nn >= 0)
            {
                if (stoppingAllVoices ||
                    pVoice->prepToGetSamples(masterVolume, pitchDev, cutoffMul, cutoffEgStrength, resLinear) ||
                    pVoice->getSamples(sampleCount, pOutLeft, pOutRight))
                {
                    stopNote(nn, true);
                }
            }
        }
    }
}
