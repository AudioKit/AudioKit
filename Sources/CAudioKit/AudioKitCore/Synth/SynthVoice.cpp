// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SynthVoice.h"
#include <stdio.h>

namespace AudioKitCore
{

    void SynthVoice::init(double sampleRate,
                          WaveStack *pOsc1Stack,
                          WaveStack *pOsc2Stack,
                          WaveStack *pOsc3Stack,
                          SynthVoiceParameters *pParams,
                          EnvelopeParameters *pEnvParameters)
    {
        pParameters = pParams;
        event = 0;
        noteNumber = -1;

        osc1.init(sampleRate, pOsc1Stack);
        osc1.setPhases(pParameters->osc1.phases);
        osc1.setFreqSpread(pParameters->osc1.frequencySpread);
        osc1.setPanSpread(pParameters->osc1.panSpread);

        osc2.init(sampleRate, pOsc2Stack);
        osc2.setPhases(pParameters->osc2.phases);
        osc2.setFreqSpread(pParameters->osc2.frequencySpread);
        osc2.setPanSpread(pParameters->osc2.panSpread);

        osc3.init(sampleRate, pOsc3Stack);
        osc3.level = pParameters->osc3.drawbars;

        leftFilter.init(sampleRate);
        rightFilter.init(sampleRate);
        leftFilter.setStages(pParameters->filterStages);
        rightFilter.setStages(pParameters->filterStages);

        ampEG.init();
        filterEG.init();
        pumpEG.init(pEnvParameters);
    }

    void SynthVoice::start(unsigned evt, unsigned noteNum, float frequency, float volume)
    {
        event = evt;
        noteVolume = volume;
        osc1.setFrequency(frequency * pow(2.0f, pParameters->osc1.pitchOffset / 12.0f));
        osc2.setFrequency(frequency * pow(2.0f, pParameters->osc2.pitchOffset / 12.0f));
        osc3.setFrequency(frequency);
        ampEG.start();
        filterEG.start();
        pumpEG.start();
        
        noteFrequency = frequency;
        noteNumber = noteNum;
    }
    
    void SynthVoice::restart(unsigned evt, float volume)
    {
        event = evt;
        newNoteNumber = -1;
        newNoteVol = volume;
        ampEG.restart();
        pumpEG.restart();
    }
    
    void SynthVoice::restart(unsigned evt, unsigned noteNum, float frequency, float volume)
    {
        event = evt;
        newNoteNumber = noteNum;
        newNoteVol = volume;
        noteFrequency = frequency;
        ampEG.restart();
        pumpEG.restart();
    }

    void SynthVoice::release(unsigned evt)
    {
        event = evt;
        ampEG.release();
        filterEG.release();
        pumpEG.release();
    }
    
    void SynthVoice::stop(unsigned evt)
    {
        event = evt;
        noteNumber = -1;
        ampEG.reset();
        filterEG.reset();
        pumpEG.reset();
    }
    
    bool SynthVoice::prepToGetSamples(float masterVolume,
                                      float phaseDeltaMultiplier,
                                      float cutoffMultiple,
                                      float cutoffStrength,
                                      float resLinear)
    {
        if (ampEG.isIdle()) return true;

        if (ampEG.isPreStarting())
        {
            float ampeg = ampEG.getSample();
            tempGain = masterVolume * noteVolume * ampeg;
            if (!ampEG.isPreStarting())
            {
                noteVolume = newNoteVol;
                tempGain = masterVolume * noteVolume * ampeg;

                if (newNoteNumber >= 0)
                {
                    // restarting a "stolen" voice with a new note number
                    osc1.setFrequency(noteFrequency * pow(2.0f, pParameters->osc1.pitchOffset / 12.0f));
                    osc2.setFrequency(noteFrequency * pow(2.0f, pParameters->osc2.pitchOffset / 12.0f));
                    osc3.setFrequency(noteFrequency);
                    noteNumber = newNoteNumber;
                }
                ampEG.start();
                filterEG.start();
                pumpEG.start();
            }
        }
        else
            tempGain = masterVolume * noteVolume * ampEG.getSample();

#if 0
        // pumping effect using multi-segment EG
        float pump = pumpEG.getSample();
        double cutoffFrequency = noteFrequency * (1.0f + cutoffMultiple + cutoffStrength * pump);
#else
        // standard ADSR EG
        double cutoffFrequency = noteFrequency * (1.0f + cutoffMultiple + cutoffStrength * filterEG.getSample());
#endif
        leftFilter.setParameters(cutoffFrequency, resLinear);
        rightFilter.setParameters(cutoffFrequency, resLinear);

        osc1.phaseDeltaMultiplier = phaseDeltaMultiplier;
        osc2.phaseDeltaMultiplier = phaseDeltaMultiplier;
        osc3.phaseDeltaMultiplier = phaseDeltaMultiplier;

        return false;
    }
    
    bool SynthVoice::getSamples(int sampleCount, float *leftOutput, float *rightOutput)
    {
        for (int i=0; i < sampleCount; i++)
        {
            float leftSample = 0.0f;
            float rightSample = 0.0f;
            osc1.getSamples(&leftSample, &rightSample, pParameters->osc1.mixLevel);
            osc2.getSamples(&leftSample, &rightSample, pParameters->osc2.mixLevel);
            osc3.getSamples(&leftSample, &rightSample, pParameters->osc3.mixLevel);

            if (pParameters->filterStages == 0)
            {
                *leftOutput++ += tempGain * leftSample;
                *rightOutput++ += tempGain * rightSample;
            }
            else
            {
                *leftOutput++ += leftFilter.process(tempGain * leftSample);
                *rightOutput++ += rightFilter.process(tempGain * rightSample);
            }
        }
        return false;
    }

}
