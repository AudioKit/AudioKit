//
//  Synth.cpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKSynth.hpp"
#include "FunctionTable.hpp"
#include "SynthVoice.hpp"
#include "WaveStack.hpp"
#include "SustainPedalLogic.hpp"

#include <math.h>
#include <list>

#define MAX_VOICE_COUNT 32      // number of voices
#define MIDI_NOTENUMBERS 128    // MIDI offers 128 distinct note numbers

struct AKSynth::_Internal
{
    /// array of voice resources
    AudioKitCore::SynthVoice voice[MAX_VOICE_COUNT];
    
    AudioKitCore::WaveStack waveform1, waveform2, waveform3;      // WaveStacks are shared by all voice oscillators
    AudioKitCore::FunctionTableOscillator vibratoLFO;             // one vibrato LFO shared by all voices
    AudioKitCore::SustainPedalLogic pedalLogic;
    
    // simple parameters
    AudioKitCore::SynthVoiceParameters voiceParameters;
    AudioKitCore::ADSREnvelopeParameters ampEGParameters;
    AudioKitCore::ADSREnvelopeParameters filterEGParameters;
    
    AudioKitCore::EnvelopeSegmentParameters segParameters[8];
    AudioKitCore::EnvelopeParameters envParameters;
};

AKSynth::AKSynth()
: eventCounter(0)
, masterVolume(1.0f)
, pitchOffset(0.0f)
, vibratoDepth(0.0f)
, cutoffMultiple(4.0f)
, cutoffStrength(20.0f)
, resLinear(1.0f)
, _private(new _Internal)
{
    for (int i=0; i < MAX_VOICE_COUNT; i++)
    {
        _private->voice[i].event = 0;
        _private->voice[i].noteNumber = -1;
        _private->voice[i].ampEG.pParameters = &_private->ampEGParameters;
        _private->voice[i].filterEG.pParameters = &_private->filterEGParameters;
    }
}

AKSynth::~AKSynth()
{
}

int AKSynth::init(double sampleRate)
{
    AudioKitCore::FunctionTable waveform;
    int length = 1 << AudioKitCore::WaveStack::maxBits;
    waveform.init(length);
    waveform.sawtooth(0.2f);
    _private->waveform1.initStack(waveform.pWaveTable);
    waveform.square(0.4f, 0.01f);
    _private->waveform2.initStack(waveform.pWaveTable);
    waveform.triangle(0.5f);
    _private->waveform3.initStack(waveform.pWaveTable);
    
    _private->ampEGParameters.updateSampleRate((float)(sampleRate/AKSYNTH_CHUNKSIZE));
    _private->filterEGParameters.updateSampleRate((float)(sampleRate/AKSYNTH_CHUNKSIZE));
    
    _private->vibratoLFO.waveTable.sinusoid();
    _private->vibratoLFO.init(sampleRate/AKSYNTH_CHUNKSIZE, 5.0f);
    
    _private->voiceParameters.osc1.phases = 4;
    _private->voiceParameters.osc1.frequencySpread = 25.0f;
    _private->voiceParameters.osc1.panSpread = 0.95f;
    _private->voiceParameters.osc1.pitchOffset = 0.0f;
    _private->voiceParameters.osc1.mixLevel = 0.7f;
    
    _private->voiceParameters.osc2.phases = 2;
    _private->voiceParameters.osc2.frequencySpread = 15.0f;
    _private->voiceParameters.osc2.panSpread = 1.0f;
    _private->voiceParameters.osc2.pitchOffset = -12.0f;
    _private->voiceParameters.osc2.mixLevel = 0.6f;
    
    _private->voiceParameters.osc3.drawbars[0] = 0.6f;
    _private->voiceParameters.osc3.drawbars[1] = 1.0f;
    _private->voiceParameters.osc3.drawbars[2] = 1.0;
    _private->voiceParameters.osc3.drawbars[3] = 1.0f;
    _private->voiceParameters.osc3.drawbars[4] = 0.0f;
    _private->voiceParameters.osc3.drawbars[5] = 0.0f;
    _private->voiceParameters.osc3.drawbars[6] = 0.4f;
    _private->voiceParameters.osc3.drawbars[7] = 0.0f;
    _private->voiceParameters.osc3.drawbars[8] = 0.0f;
    _private->voiceParameters.osc3.drawbars[8] = 0.0f;
    _private->voiceParameters.osc3.drawbars[10] = 0.0f;
    _private->voiceParameters.osc3.drawbars[11] = 0.0f;
    _private->voiceParameters.osc3.drawbars[12] = 0.0f;
    _private->voiceParameters.osc3.drawbars[13] = 0.0f;
    _private->voiceParameters.osc3.drawbars[14] = 0.0f;
    _private->voiceParameters.osc3.drawbars[15] = 0.0f;
    _private->voiceParameters.osc3.mixLevel = 0.5f;
    
    _private->voiceParameters.filterStages = 2;
    
    _private->segParameters[0].initialLevel = 0.0f;   // attack: ramp quickly to 0.2
    _private->segParameters[0].finalLevel = 0.2f;
    _private->segParameters[0].seconds = 0.01f;
    _private->segParameters[1].initialLevel = 0.2f;   // hold at 0.2 for 1 sec
    _private->segParameters[1].finalLevel = 0.2;
    _private->segParameters[1].seconds = 1.0f;
    _private->segParameters[2].initialLevel = 0.2f;   // decay: fall to 0.0 in 0.5 sec
    _private->segParameters[2].finalLevel = 0.0f;
    _private->segParameters[2].seconds = 0.5f;
    _private->segParameters[3].initialLevel = 0.0f;   // sustain pump up: up to 1.0 in 0.1 sec
    _private->segParameters[3].finalLevel = 1.0f;
    _private->segParameters[3].seconds = 0.1f;
    _private->segParameters[4].initialLevel = 1.0f;   // sustain pump down: down to 0 again in 0.5 sec
    _private->segParameters[4].finalLevel = 0.0f;
    _private->segParameters[4].seconds = 0.5f;
    _private->segParameters[5].initialLevel = 0.0f;   // release: from wherever we leave off
    _private->segParameters[5].finalLevel = 0.0f;     // down to 0
    _private->segParameters[5].seconds = 0.5f;        // in 0.5 sec
    
    _private->envParameters.init((float)(sampleRate/AKSYNTH_CHUNKSIZE), 6, _private->segParameters, 3, 0, 5);
    
    for (int i=0; i < MAX_VOICE_COUNT; i++)
    {
        _private->voice[i].init(sampleRate, &_private->waveform1, &_private->waveform2, &_private->waveform3, &_private->voiceParameters, &_private->envParameters);
    }
    
    return 0;   // no error
}

void AKSynth::deinit()
{
}

void AKSynth::playNote(unsigned noteNumber, unsigned velocity, float noteFrequency)
{
    eventCounter++;
    _private->pedalLogic.keyDownAction(noteNumber);
    play(noteNumber, velocity, noteFrequency);
}

void AKSynth::stopNote(unsigned noteNumber, bool immediate)
{
    eventCounter++;
    if (immediate || _private->pedalLogic.keyUpAction(noteNumber))
        stop(noteNumber, immediate);
}

void AKSynth::sustainPedal(bool down)
{
    eventCounter++;
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

AudioKitCore::SynthVoice *AKSynth::voicePlayingNote(unsigned noteNumber)
{
    AudioKitCore::SynthVoice *pVoice = _private->voice;
    for (int i=0; i < MAX_VOICE_COUNT; i++, pVoice++)
    {
        if (pVoice->noteNumber == noteNumber) return pVoice;
    }
    return 0;
}

void AKSynth::play(unsigned noteNumber, unsigned velocity, float noteFrequency)
{
    //printf("playNote nn=%d vel=%d %.2f Hz\n", noteNumber, velocity, noteFrequency);
    
    // is any voice already playing this note?
    AudioKitCore::SynthVoice *pVoice = voicePlayingNote(noteNumber);
    if (pVoice)
    {
        // re-start the note
        pVoice->restart(eventCounter, velocity / 127.0f);
        //printf("Restart note %d as %d\n", noteNumber, pVoice->noteNumber);
        return;
    }
    
    // find a free voice (with noteNumber < 0) to play the note
    for (int i=0; i < MAX_VOICE_COUNT; i++)
    {
        AudioKitCore::SynthVoice *pVoice = &_private->voice[i];
        if (pVoice->noteNumber < 0)
        {
            // found a free voice: assign it to play this note
            pVoice->start(eventCounter, noteNumber, noteFrequency, velocity / 127.0f);
            //printf("Play note %d (%.2f Hz) vel %d\n", noteNumber, noteFrequency, velocity);
            return;
        }
    }
    
    // all oscillators in use: find "stalest" voice to steal
    unsigned greatestDiffOfAll = 0;
    AudioKitCore::SynthVoice *pStalestVoiceOfAll = 0;
    unsigned greatestDiffInRelease = 0;
    AudioKitCore::SynthVoice *pStalestVoiceInRelease = 0;
    for (int i=0; i < MAX_VOICE_COUNT; i++)
    {
        AudioKitCore::SynthVoice *pVoice = &_private->voice[i];
        unsigned diff = eventCounter - pVoice->event;
        if (pVoice->ampEG.isReleasing())
        {
            if (diff > greatestDiffInRelease)
            {
                greatestDiffInRelease = diff;
                pStalestVoiceInRelease = pVoice;
            }
        }
        if (diff > greatestDiffOfAll)
        {
            greatestDiffOfAll = diff;
            pStalestVoiceOfAll = pVoice;
        }
    }
    
    if (pStalestVoiceInRelease != 0)
    {
        // We have a stalest note in its release phase: restart that one
        pStalestVoiceInRelease->restart(eventCounter, noteNumber, noteFrequency, velocity / 127.0f);
    }
    else
    {
        // No notes in release phase: restart the "stalest" one we could find
        pStalestVoiceOfAll->restart(eventCounter, noteNumber, noteFrequency, velocity / 127.0f);
    }
}

void AKSynth::stop(unsigned noteNumber, bool immediate)
{
    //printf("stopNote nn=%d %s\n", noteNumber, immediate ? "immediate" : "release");
    AudioKitCore::SynthVoice *pVoice = voicePlayingNote(noteNumber);
    if (pVoice == 0) return;
    //printf("stopNote pVoice is %p\n", pVoice);
    
    if (immediate)
    {
        pVoice->stop(eventCounter);
        //printf("Stop note %d immediate\n", noteNumber);
    }
    else
    {
        pVoice->release(eventCounter);
        //printf("Stop note %d release\n", noteNumber);
    }
}

void AKSynth::render(unsigned channelCount, unsigned sampleCount, float *outBuffers[])
{
    float *pOutLeft = outBuffers[0];
    float *pOutRight = outBuffers[1];
    
    float pitchDev = pitchOffset + vibratoDepth * _private->vibratoLFO.getSample();
    float phaseDeltaMultiplier = pow(2.0f, pitchDev / 12.0);
    
    AudioKitCore::SynthVoice *pVoice = &_private->voice[0];
    for (int i=0; i < MAX_VOICE_COUNT; i++, pVoice++)
    {
        int nn = pVoice->noteNumber;
        if (nn >= 0)
        {
            if (pVoice->prepToGetSamples(masterVolume, phaseDeltaMultiplier, cutoffMultiple, cutoffStrength, resLinear) ||
                pVoice->getSamples(sampleCount, pOutLeft, pOutRight))
            {
                stopNote(nn, true);
            }
        }
    }
}

void AKSynth::setAmpAttackDurationSeconds(float value)
{
    _private->ampEGParameters.setAttackDurationSeconds(value);
    for (int i = 0; i < MAX_VOICE_COUNT; i++) _private->voice[i].updateAmpAdsrParameters();
}
float AKSynth::getAmpAttackDurationSeconds(void)
{
    return _private->ampEGParameters.getAttackDurationSeconds();
}
void  AKSynth::setAmpDecayDurationSeconds(float value)
{
    _private->ampEGParameters.setDecayDurationSeconds(value);
    for (int i = 0; i < MAX_VOICE_COUNT; i++) _private->voice[i].updateAmpAdsrParameters();
}
float AKSynth::getAmpDecayDurationSeconds(void)
{
    return _private->ampEGParameters.getDecayDurationSeconds();
}
void  AKSynth::setAmpSustainFraction(float value)
{
    _private->ampEGParameters.sustainFraction = value;
    for (int i = 0; i < MAX_VOICE_COUNT; i++) _private->voice[i].updateAmpAdsrParameters();
}
float AKSynth::getAmpSustainFraction(void)
{
    return _private->ampEGParameters.sustainFraction;
}
void  AKSynth::setAmpReleaseDurationSeconds(float value)
{
    _private->ampEGParameters.setReleaseDurationSeconds(value);
    for (int i = 0; i < MAX_VOICE_COUNT; i++) _private->voice[i].updateAmpAdsrParameters();
}

float AKSynth::getAmpReleaseDurationSeconds(void)
{
    return _private->ampEGParameters.getReleaseDurationSeconds();
}

void  AKSynth::setFilterAttackDurationSeconds(float value)
{
    _private->filterEGParameters.setAttackDurationSeconds(value);
    for (int i = 0; i < MAX_VOICE_COUNT; i++) _private->voice[i].updateFilterAdsrParameters();
}
float AKSynth::getFilterAttackDurationSeconds(void)
{
    return _private->filterEGParameters.getAttackDurationSeconds();
}
void  AKSynth::setFilterDecayDurationSeconds(float value)
{
    _private->filterEGParameters.setDecayDurationSeconds(value);
    for (int i = 0; i < MAX_VOICE_COUNT; i++) _private->voice[i].updateFilterAdsrParameters();
}
float AKSynth::getFilterDecayDurationSeconds(void)
{
    return _private->filterEGParameters.getDecayDurationSeconds();
}
void  AKSynth::setFilterSustainFraction(float value)
{
    _private->filterEGParameters.sustainFraction = value;
    for (int i = 0; i < MAX_VOICE_COUNT; i++) _private->voice[i].updateFilterAdsrParameters();
}
float AKSynth::getFilterSustainFraction(void)
{
    return _private->filterEGParameters.sustainFraction;
}
void  AKSynth::setFilterReleaseDurationSeconds(float value)
{
    _private->filterEGParameters.setReleaseDurationSeconds(value);
    for (int i = 0; i < MAX_VOICE_COUNT; i++) _private->voice[i].updateFilterAdsrParameters();
}
float AKSynth::getFilterReleaseDurationSeconds(void)
{
    return _private->filterEGParameters.getReleaseDurationSeconds();
}
