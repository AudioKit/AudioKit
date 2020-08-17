// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKCoreSynth.hpp"
#include "FunctionTable.hpp"
#include "SynthVoice.hpp"
#include "WaveStack.hpp"
#include "SustainPedalLogic.hpp"

#include <math.h>
#include <list>

#define MAX_VOICE_COUNT 32      // number of voices
#define MIDI_NOTENUMBERS 128    // MIDI offers 128 distinct note numbers

struct AKCoreSynth::InternalData
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

AKCoreSynth::AKCoreSynth()
: eventCounter(0)
, masterVolume(1.0f)
, pitchOffset(0.0f)
, vibratoDepth(0.0f)
, cutoffMultiple(4.0f)
, cutoffEnvelopeStrength(20.0f)
, linearResonance(1.0f)
, data(new InternalData)
{
    for (int i=0; i < MAX_VOICE_COUNT; i++)
    {
        data->voice[i].event = 0;
        data->voice[i].noteNumber = -1;
        data->voice[i].ampEG.pParameters = &data->ampEGParameters;
        data->voice[i].filterEG.pParameters = &data->filterEGParameters;
    }
}

AKCoreSynth::~AKCoreSynth()
{
}

int AKCoreSynth::init(double sampleRate)
{
    AudioKitCore::FunctionTable waveform;
    int length = 1 << AudioKitCore::WaveStack::maxBits;
    waveform.init(length);
    waveform.sawtooth(0.2f);
    data->waveform1.initStack(waveform.pWaveTable);
    waveform.square(0.4f, 0.01f);
    data->waveform2.initStack(waveform.pWaveTable);
    waveform.triangle(0.5f);
    data->waveform3.initStack(waveform.pWaveTable);
    
    data->ampEGParameters.updateSampleRate((float)(sampleRate/AKSYNTH_CHUNKSIZE));
    data->filterEGParameters.updateSampleRate((float)(sampleRate/AKSYNTH_CHUNKSIZE));
    
    data->vibratoLFO.waveTable.sinusoid();
    data->vibratoLFO.init(sampleRate/AKSYNTH_CHUNKSIZE, 5.0f);
    
    data->voiceParameters.osc1.phases = 4;
    data->voiceParameters.osc1.frequencySpread = 25.0f;
    data->voiceParameters.osc1.panSpread = 0.95f;
    data->voiceParameters.osc1.pitchOffset = 0.0f;
    data->voiceParameters.osc1.mixLevel = 0.7f;
    
    data->voiceParameters.osc2.phases = 2;
    data->voiceParameters.osc2.frequencySpread = 15.0f;
    data->voiceParameters.osc2.panSpread = 1.0f;
    data->voiceParameters.osc2.pitchOffset = -12.0f;
    data->voiceParameters.osc2.mixLevel = 0.6f;
    
    data->voiceParameters.osc3.drawbars[0] = 0.6f;
    data->voiceParameters.osc3.drawbars[1] = 1.0f;
    data->voiceParameters.osc3.drawbars[2] = 1.0;
    data->voiceParameters.osc3.drawbars[3] = 1.0f;
    data->voiceParameters.osc3.drawbars[4] = 0.0f;
    data->voiceParameters.osc3.drawbars[5] = 0.0f;
    data->voiceParameters.osc3.drawbars[6] = 0.4f;
    data->voiceParameters.osc3.drawbars[7] = 0.0f;
    data->voiceParameters.osc3.drawbars[8] = 0.0f;
    data->voiceParameters.osc3.drawbars[8] = 0.0f;
    data->voiceParameters.osc3.drawbars[10] = 0.0f;
    data->voiceParameters.osc3.drawbars[11] = 0.0f;
    data->voiceParameters.osc3.drawbars[12] = 0.0f;
    data->voiceParameters.osc3.drawbars[13] = 0.0f;
    data->voiceParameters.osc3.drawbars[14] = 0.0f;
    data->voiceParameters.osc3.drawbars[15] = 0.0f;
    data->voiceParameters.osc3.mixLevel = 0.5f;
    
    data->voiceParameters.filterStages = 2;
    
    data->segParameters[0].initialLevel = 0.0f;   // attack: ramp quickly to 0.2
    data->segParameters[0].finalLevel = 0.2f;
    data->segParameters[0].seconds = 0.01f;
    data->segParameters[1].initialLevel = 0.2f;   // hold at 0.2 for 1 sec
    data->segParameters[1].finalLevel = 0.2;
    data->segParameters[1].seconds = 1.0f;
    data->segParameters[2].initialLevel = 0.2f;   // decay: fall to 0.0 in 0.5 sec
    data->segParameters[2].finalLevel = 0.0f;
    data->segParameters[2].seconds = 0.5f;
    data->segParameters[3].initialLevel = 0.0f;   // sustain pump up: up to 1.0 in 0.1 sec
    data->segParameters[3].finalLevel = 1.0f;
    data->segParameters[3].seconds = 0.1f;
    data->segParameters[4].initialLevel = 1.0f;   // sustain pump down: down to 0 again in 0.5 sec
    data->segParameters[4].finalLevel = 0.0f;
    data->segParameters[4].seconds = 0.5f;
    data->segParameters[5].initialLevel = 0.0f;   // release: from wherever we leave off
    data->segParameters[5].finalLevel = 0.0f;     // down to 0
    data->segParameters[5].seconds = 0.5f;        // in 0.5 sec
    
    data->envParameters.init((float)(sampleRate/AKSYNTH_CHUNKSIZE), 6, data->segParameters, 3, 0, 5);
    
    for (int i=0; i < MAX_VOICE_COUNT; i++)
    {
        data->voice[i].init(sampleRate, &data->waveform1, &data->waveform2, &data->waveform3, &data->voiceParameters, &data->envParameters);
    }
    
    return 0;   // no error
}

void AKCoreSynth::deinit()
{
}

void AKCoreSynth::playNote(unsigned noteNumber, unsigned velocity, float noteFrequency)
{
    eventCounter++;
    data->pedalLogic.keyDownAction(noteNumber);
    play(noteNumber, velocity, noteFrequency);
}

void AKCoreSynth::stopNote(unsigned noteNumber, bool immediate)
{
    eventCounter++;
    if (immediate || data->pedalLogic.keyUpAction(noteNumber))
        stop(noteNumber, immediate);
}

void AKCoreSynth::sustainPedal(bool down)
{
    eventCounter++;
    if (down) data->pedalLogic.pedalDown();
    else {
        for (int nn=0; nn < MIDI_NOTENUMBERS; nn++)
        {
            if (data->pedalLogic.isNoteSustaining(nn))
                stop(nn, false);
        }
        data->pedalLogic.pedalUp();
    }
}

AudioKitCore::SynthVoice *AKCoreSynth::voicePlayingNote(unsigned noteNumber)
{
    AudioKitCore::SynthVoice *pVoice = data->voice;
    for (int i=0; i < MAX_VOICE_COUNT; i++, pVoice++)
    {
        if (pVoice->noteNumber == noteNumber) return pVoice;
    }
    return 0;
}

void AKCoreSynth::play(unsigned noteNumber, unsigned velocity, float noteFrequency)
{
    // is any voice already playing this note?
    AudioKitCore::SynthVoice *pVoice = voicePlayingNote(noteNumber);
    if (pVoice)
    {
        // re-start the note
        pVoice->restart(eventCounter, velocity / 127.0f);
        return;
    }
    
    // find a free voice (with noteNumber < 0) to play the note
    for (int i=0; i < MAX_VOICE_COUNT; i++)
    {
        AudioKitCore::SynthVoice *pVoice = &data->voice[i];
        if (pVoice->noteNumber < 0)
        {
            // found a free voice: assign it to play this note
            pVoice->start(eventCounter, noteNumber, noteFrequency, velocity / 127.0f);
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
        AudioKitCore::SynthVoice *pVoice = &data->voice[i];
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

void AKCoreSynth::stop(unsigned noteNumber, bool immediate)
{
    AudioKitCore::SynthVoice *pVoice = voicePlayingNote(noteNumber);
    if (pVoice == 0) return;

    if (immediate)
    {
        pVoice->stop(eventCounter);
    }
    else
    {
        pVoice->release(eventCounter);
    }
}

void AKCoreSynth::render(unsigned channelCount, unsigned sampleCount, float *outBuffers[])
{
    float *pOutLeft = outBuffers[0];
    float *pOutRight = outBuffers[1];
    
    float pitchDev = pitchOffset + vibratoDepth * data->vibratoLFO.getSample();
    float phaseDeltaMultiplier = pow(2.0f, pitchDev / 12.0);
    
    AudioKitCore::SynthVoice *pVoice = &data->voice[0];
    for (int i=0; i < MAX_VOICE_COUNT; i++, pVoice++)
    {
        int nn = pVoice->noteNumber;
        if (nn >= 0)
        {
            if (pVoice->prepToGetSamples(masterVolume, phaseDeltaMultiplier, cutoffMultiple, cutoffEnvelopeStrength, linearResonance) ||
                pVoice->getSamples(sampleCount, pOutLeft, pOutRight))
            {
                stopNote(nn, true);
            }
        }
    }
}

void AKCoreSynth::setAmpAttackDurationSeconds(float value)
{
    data->ampEGParameters.setAttackDurationSeconds(value);
    for (int i = 0; i < MAX_VOICE_COUNT; i++) data->voice[i].updateAmpAdsrParameters();
}
float AKCoreSynth::getAmpAttackDurationSeconds(void)
{
    return data->ampEGParameters.getAttackDurationSeconds();
}
void  AKCoreSynth::setAmpDecayDurationSeconds(float value)
{
    data->ampEGParameters.setDecayDurationSeconds(value);
    for (int i = 0; i < MAX_VOICE_COUNT; i++) data->voice[i].updateAmpAdsrParameters();
}
float AKCoreSynth::getAmpDecayDurationSeconds(void)
{
    return data->ampEGParameters.getDecayDurationSeconds();
}
void  AKCoreSynth::setAmpSustainFraction(float value)
{
    data->ampEGParameters.sustainFraction = value;
    for (int i = 0; i < MAX_VOICE_COUNT; i++) data->voice[i].updateAmpAdsrParameters();
}
float AKCoreSynth::getAmpSustainFraction(void)
{
    return data->ampEGParameters.sustainFraction;
}
void  AKCoreSynth::setAmpReleaseDurationSeconds(float value)
{
    data->ampEGParameters.setReleaseDurationSeconds(value);
    for (int i = 0; i < MAX_VOICE_COUNT; i++) data->voice[i].updateAmpAdsrParameters();
}

float AKCoreSynth::getAmpReleaseDurationSeconds(void)
{
    return data->ampEGParameters.getReleaseDurationSeconds();
}

void  AKCoreSynth::setFilterAttackDurationSeconds(float value)
{
    data->filterEGParameters.setAttackDurationSeconds(value);
    for (int i = 0; i < MAX_VOICE_COUNT; i++) data->voice[i].updateFilterAdsrParameters();
}
float AKCoreSynth::getFilterAttackDurationSeconds(void)
{
    return data->filterEGParameters.getAttackDurationSeconds();
}
void  AKCoreSynth::setFilterDecayDurationSeconds(float value)
{
    data->filterEGParameters.setDecayDurationSeconds(value);
    for (int i = 0; i < MAX_VOICE_COUNT; i++) data->voice[i].updateFilterAdsrParameters();
}
float AKCoreSynth::getFilterDecayDurationSeconds(void)
{
    return data->filterEGParameters.getDecayDurationSeconds();
}
void  AKCoreSynth::setFilterSustainFraction(float value)
{
    data->filterEGParameters.sustainFraction = value;
    for (int i = 0; i < MAX_VOICE_COUNT; i++) data->voice[i].updateFilterAdsrParameters();
}
float AKCoreSynth::getFilterSustainFraction(void)
{
    return data->filterEGParameters.sustainFraction;
}
void  AKCoreSynth::setFilterReleaseDurationSeconds(float value)
{
    data->filterEGParameters.setReleaseDurationSeconds(value);
    for (int i = 0; i < MAX_VOICE_COUNT; i++) data->voice[i].updateFilterAdsrParameters();
}
float AKCoreSynth::getFilterReleaseDurationSeconds(void)
{
    return data->filterEGParameters.getReleaseDurationSeconds();
}
